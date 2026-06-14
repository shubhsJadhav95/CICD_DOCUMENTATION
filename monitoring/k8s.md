#### Monitoring setup using grafana and prometheus

```
kubectl create namespcace monitoring
```
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm install my-metrics-server metrics-server/metrics-server --version 3.13.0 -n monitoring
```

```
vim grafana-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    alb.ingress.kubernetes.io/group.name: neocare-app-lb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/backend-protocol-version: HTTP1
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'

    # 🚨 TEMP FIX: REMOVE SSL REDIRECT (IMPORTANT)
    # alb.ingress.kubernetes.io/ssl-redirect: '443'

    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:347026173735:certificate/51f1a255-0a49-4f90-aa79-4e43e20b9da8

spec:
  ingressClassName: alb
  rules:
  - host: grafana.neocare.devcloudzone.store
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-kube-prometheus-stack-grafana
            port:
              number: 80
```
```
vim prometheus-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    alb.ingress.kubernetes.io/group.name: neocare-app-lb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/backend-protocol-version: HTTP1
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'

    # 🚨 TEMP FIX: REMOVE SSL REDIRECT (IMPORTANT)
    # alb.ingress.kubernetes.io/ssl-redirect: '443'

    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:347026173735:certificate/51f1a255-0a49-4f90-aa79-4e43e20b9da8

spec:
  ingressClassName: alb
  rules:
  - host: prometheus.neocare.devcloudzone.store
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-kube-prometheus-stack-prometheus
            port:
              number: 9090
```

```
vim alertmanager.yml
```
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: alertmanager-ingress
  namespace: monitoring
  annotations:
    alb.ingress.kubernetes.io/group.name: neocare-app-lb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/backend-protocol-version: HTTP1
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'

    # Uncomment if you want to force HTTPS
    # alb.ingress.kubernetes.io/ssl-redirect: '443'

    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:347026173735:certificate/51f1a255-0a49-4f90-aa79-4e43e20b9da8

spec:
  ingressClassName: alb
  rules:
    - host: alertmanager.neocare.devcloudzone.store
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-kube-prometheus-stack-alertmanager
                port:
                  number: 9093
```
#### Allow respective port in SG

```
k get po -n monitoring
```

```
kubectl --namespace monitoring get secrets my-kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
```
