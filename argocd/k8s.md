### K8s Approach
```
kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
#### This disables Argo CD forcing HTTPS internally 
```
kubectl edit configmap argocd-cmd-params-cm -n argocd

data:
  server.insecure: "true"

```
#### ingress.yml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    alb.ingress.kubernetes.io/group.name: costspike-app-lb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/backend-protocol-version: HTTP1
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'

    # 🚨 TEMP FIX: REMOVE SSL REDIRECT (IMPORTANT)
    # alb.ingress.kubernetes.io/ssl-redirect: '443'

    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:797111435256:certificate/6c33d96f-ba4a-4cdb-ac0b-d431a1a52439

spec:
  ingressClassName: alb
  rules:
  - host: argocd.devcloudzone.store
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 8080 

```


#### After in case port change to 80
```
kubectl rollout restart deployment argocd-server -n argocd
kubectl rollout status deployment argocd-server -n argocd
```


#### CHECK PORT SOMETIME ITS 80 or 8080
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echoavB
```