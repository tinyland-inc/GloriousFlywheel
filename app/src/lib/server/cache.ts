interface CacheEntry<T> {
  data: T;
  expires: number;
}

const store = new Map<string, CacheEntry<unknown>>();

export function cached<T>(
  key: string,
  ttlMs: number,
  fetcher: () => Promise<T>,
): Promise<T> {
  const entry = store.get(key) as CacheEntry<T> | undefined;
  if (entry && Date.now() < entry.expires) {
    return Promise.resolve(entry.data);
  }

  return fetcher().then((data) => {
    store.set(key, { data, expires: Date.now() + ttlMs });
    return data;
  });
}

export function invalidate(pattern?: string) {
  if (!pattern) {
    store.clear();
    return;
  }
  for (const key of store.keys()) {
    if (key.includes(pattern)) {
      store.delete(key);
    }
  }
}
