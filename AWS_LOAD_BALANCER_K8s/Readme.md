** Install AWS application load balancer refering the below docs link**<br/>
```
https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
```

```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
```

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

```
eksctl create iamserviceaccount \
    --cluster=tws-eks-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::347026173735:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region us-esat-1 \
    --approve
```

```
helm repo add eks https://aws.github.io/eks-charts

```

```
helm repo update eks
```
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=tws-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=vpc-04150f6b634154f45 \
  --version 1.14.0
```