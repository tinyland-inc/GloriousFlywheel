# GitLab Runner Module - Enrollment and Operational Alerts
#
# Additional alerts for runner pool self-service operations.

resource "kubernetes_manifest" "enrollment_alerts" {
  count = var.service_monitor_enabled && var.enrollment_alerts_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"

    metadata = {
      name      = "${var.runner_name}-enrollment-alerts"
      namespace = var.namespace
      labels = merge(local.common_labels, var.service_monitor_labels, {
        "app.kubernetes.io/component" = "enrollment-alerting"
      })
    }

    spec = {
      groups = [
        {
          name = "gitlab-runner-${var.runner_name}-enrollment"

          rules = [
            {
              alert = "RunnerResourceQuotaExhausted"
              expr  = "kube_resourcequota{namespace=\"${var.namespace}\", type=\"used\"} / kube_resourcequota{namespace=\"${var.namespace}\", type=\"hard\"} > 0.9"
              for   = "5m"
              labels = {
                severity = "warning"
                runner   = var.runner_name
              }
              annotations = {
                summary     = "Runner namespace quota usage above 90%"
                description = "ResourceQuota in namespace {{ $labels.namespace }} is at {{ $value | humanizePercentage }} utilization for resource {{ $labels.resource }}."
              }
            },
            {
              alert = "RunnerNamespaceLeaked"
              expr  = "count(kube_namespace_labels{namespace=~\"ci-job-.*\"}) - count(kube_pod_info{namespace=~\"ci-job-.*\"}) > 0"
              for   = "2h"
              labels = {
                severity = "warning"
                runner   = var.runner_name
              }
              annotations = {
                summary     = "Orphaned ci-job-* namespaces detected"
                description = "There are {{ $value }} ci-job-* namespaces with no running pods, older than 2 hours. Cleanup cronjob may need investigation."
              }
            },
            {
              alert = "RunnerJobQueueBacklog"
              expr  = "sum(gitlab_runner_jobs{state=\"pending\", namespace=\"${var.namespace}\"}) > 10"
              for   = "5m"
              labels = {
                severity = "warning"
                runner   = var.runner_name
              }
              annotations = {
                summary     = "Runner job queue backlog growing"
                description = "More than 10 pending jobs in the runner pool for over 5 minutes. HPA may need tuning or cluster capacity is insufficient."
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [helm_release.gitlab_runner]
}
