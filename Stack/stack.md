**Alerting to Slack** 

Create a new workspace in slack, create a new channel e.g. “#alerts”

go to https://api.slack.com/apps to create the webhook.

1. create an app “alertmanager”
2. go to incoming webhook
3. create a webhook and copy it.

modify the helm values.

```jsx
config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['namespace']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'slack-notification'
      routes:
      - receiver: 'slack-notification'
        matchers:
          - severity = "critical"
    receivers:
    - name: 'slack-notification'
      slack_configs:
          - api_url: ''
            channel: '#alerts'
            send_resolved: true
    templates:
    - '/etc/alertmanager/config/*.tmpl'
```

Note: you can refer this DOCs for the slack configuration. “https://prometheus.io/docs/alerting/latest/configuration/#slack_config” 

upgrade the chart

```jsx
helm upgrade my-kube-prometheus-stack prometheus-community/kube-prometheus-stack -f kube-prom-stack.yaml -n monitoring
```


You would get the notification in the slack’s respective channel.