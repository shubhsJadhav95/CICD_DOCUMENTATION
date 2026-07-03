#### Create an Jenkins ingess vi helm

```
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
  --namespace jenkins --create-namespace \
  --set controller.serviceType=ClusterIP
```

### **Install the EBS CSI driver refering the below docs link**<br/>
```
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html#eksctl_store_app_data
```
```
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster neocare-dev \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --role-only \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --region us-east-1 \
  --override-existing-serviceaccounts
        

```
### Deploy Driver Documentation

```
https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
```
```
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

```
## Upload Role ebs-csi-driver
```
helm show values aws-ebs-csi-driver/aws-ebs-csi-driver > ebs-driver.yaml
```

```
vim ebs-driver.yaml
```

```
controller:
  serviceAccount:
    create: true
    name: ebs-csi-controller-sa
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::347026173735:role/AmazonEKS_EBS_CSI_DriverRole
```
```
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  -f ebs-driver.yaml
```

#### Update to bound jenkins

```
helm upgrade jenkins jenkins/jenkins \
  -n jenkins \
  --reuse-values \
  --set controller.persistence.storageClass=gp3
```

#### Create StorageClass 

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  type: gp3
```

#### Create Ingress for jenkins

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:797111435256:certificate/d83e36ad-c6b5-43da-aefe-844cf88a67de
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443},{"HTTP":80}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/group.name: one8pulse-internet-lb
spec:
  ingressClassName: alb
  rules:
    - host: jenkins.one8pulse.devcloudzone.store
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins
                port:
                  number: 8080
```

```
kubectl get secret jenkins -n jenkins -o jsonpath="{.data.jenkins-admin-user}" | base64 --decode && echo
```

```
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```