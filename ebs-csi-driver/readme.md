### **Install the EBS CSI driver refering the below docs link**<br/>
```
https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html#eksctl_store_app_data
```
```
eksctl create iamserviceaccount \
        --name ebs-csi-controller-sa \
        --namespace kube-system \
        --cluster tws-eks-cluster \
        --role-name AmazonEKS_EBS_CSI_DriverRole \
        --role-only \
        --attach-policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2 \
        --approve \
        --region us-east-1
        

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
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver
```

```
k describe po ebs-csi-controller-77bb9cb4c6-vxbcv  -n kube-system | grep role

```
```
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```

```
helm uninstall aws-ebs-csi-driver -n kube-system

```