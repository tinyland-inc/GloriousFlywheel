import { describe, it, expect, vi } from "vitest";
import { cached, invalidate } from "./cache";

describe("cached", () => {
  it("should call fetcher on first invocation", async () => {
    const fetcher = vi.fn().mockResolvedValue("data");
    invalidate(); // Clear cache

    const result = await cached("test-key", 1000, fetcher);
    expect(result).toBe("data");
    expect(fetcher).toHaveBeenCalledTimes(1);
  });

  it("should return cached value on second call", async () => {
    const fetcher = vi.fn().mockResolvedValue("data");
    invalidate();

    await cached("cache-key-2", 10000, fetcher);
    await cached("cache-key-2", 10000, fetcher);
    expect(fetcher).toHaveBeenCalledTimes(1);
  });

  it("should re-fetch after TTL expires", async () => {
    const fetcher = vi.fn().mockResolvedValue("data");
    invalidate();

    await cached("ttl-key", 1, fetcher); // 1ms TTL
    await new Promise((r) => setTimeout(r, 10));
    await cached("ttl-key", 1, fetcher);
    expect(fetcher).toHaveBeenCalledTimes(2);
  });
});

describe("invalidate", () => {
  it("should clear all entries without pattern", async () => {
    const fetcher = vi.fn().mockResolvedValue("data");
    invalidate();

    await cached("a", 10000, fetcher);
    await cached("b", 10000, fetcher);
    invalidate();
    await cached("a", 10000, fetcher);
    await cached("b", 10000, fetcher);
    expect(fetcher).toHaveBeenCalledTimes(4);
  });

  it("should clear only matching entries with pattern", async () => {
    const fetcher = vi.fn().mockResolvedValue("data");
    invalidate();

    await cached("runners-list", 10000, fetcher);
    await cached("metrics-cpu", 10000, fetcher);
    invalidate("runners");
    await cached("runners-list", 10000, fetcher);
    await cached("metrics-cpu", 10000, fetcher);
    // runners-list was invalidated (refetched), metrics-cpu was not
    expect(fetcher).toHaveBeenCalledTimes(3);
  });
});
