import type { RangeResult, InstantResult } from "./client";
import type { TimeSeriesData, MetricValue } from "$lib/types";

/**
 * Transform Prometheus range query results into Chart.js-friendly format
 */
export function toTimeSeries(results: RangeResult[]): TimeSeriesData[] {
  return results.map((r) => ({
    label: formatLabel(r.metric),
    timestamps: r.values.map(([ts]) => new Date(ts * 1000).toISOString()),
    values: r.values.map(([, v]) => parseFloat(v)),
  }));
}

/**
 * Transform Prometheus instant query result to a single metric value
 */
export function toMetricValue(
  results: InstantResult[],
  defaultValue: number = 0,
): MetricValue {
  if (results.length === 0) {
    return { value: defaultValue, timestamp: new Date().toISOString() };
  }
  const [ts, val] = results[0].value;
  return {
    value: parseFloat(val),
    timestamp: new Date(ts * 1000).toISOString(),
  };
}

/**
 * Transform instant results to a map of label -> value
 */
export function toValueMap(
  results: InstantResult[],
  labelKey: string = "pod",
): Record<string, number> {
  const map: Record<string, number> = {};
  for (const r of results) {
    const key = r.metric[labelKey] ?? "unknown";
    map[key] = parseFloat(r.value[1]);
  }
  return map;
}

function formatLabel(metric: Record<string, string>): string {
  // Prefer pod name, then runner name, then full label set
  if (metric.pod) return metric.pod;
  if (metric.runner) return metric.runner;
  if (metric.horizontalpodautoscaler) return metric.horizontalpodautoscaler;
  const entries = Object.entries(metric).filter(([k]) => k !== "__name__");
  if (entries.length === 0) return "value";
  return entries.map(([k, v]) => `${k}=${v}`).join(", ");
}
