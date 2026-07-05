#### https://github.com/aws/secrets-store-csi-driver-provider-aws/blob/main/README.md

```
k create namespace secret-manager
```

#### Secrets Store CSI driver installed
```
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
  --namespace kube-system \
  --set syncSecret.enabled=true \
  --set enableSecretRotation=true
```

#### 
```
kubectl patch csidriver secrets-store.csi.k8s.io --type=merge -p '{
  "spec": {
    "tokenRequests": [
      {"audience": "sts.amazonaws.com"},
      {"audience": "pods.eks.amazonaws.com"}
    ]
  }
}'
```
```
kubectl rollout restart deployment/backend -n neocare
kubectl get pods -n neocare -
```
#### Installing the AWS Provider and Config Provider (ASCP)

```
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

#### Create an Policy for secrets
```
vim secret_policy.json
```
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "arn:aws:secretsmanager:*:797111435256:secret:*"
        }
    ]
}
```
#### Create an policy
```
aws iam create-policy \
    --policy-name EksSecretManagerPolicy \
    --policy-document file://secret_policy.json

```

```
 aws iam delete-policy --policy-arn arn:aws:iam::797111435256:policy/EksSecretManagerPolicy
```
####  the IAM OIDC provider for the cluster if you have not already done so
```
 eksctl utils associate-iam-oidc-provider --region=us-east-2 --cluster=costspike --approve
```

#### Next, create the service account to be used by the pod and associate the above IAM policy with that service account. For this example we use nginx-irsa-deployment-sa for the service account name:

#### add your name space for secret-manager
```
eksctl create iamserviceaccount \
    --cluster=neocare-dev-eks \
    --namespace=neocare \
    --name=aws-csi-secret-manager \
    --attach-policy-arn=arn:aws:iam::797111435256:policy/EksSecretManagerPolicy \
    --override-existing-serviceaccounts \
    --region us-east-1 \
    --approve
```
```
k get sa -n <namespace>
```
#### The SecretProviderClass has the following format:

```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: neocare-secrets
  namespace: neocare

spec:
  provider: aws

  parameters:
    objects: |
      - objectName: "dev/postgres"
        objectType: "secretsmanager"

  secretObjects:
    - secretName: backend-secret
      type: Opaque
      data:
        - objectName: DB_HOST
          key: DB_HOST
        - objectName: DB_PASSWORD
          key: DB_PASSWORD
        - objectName: JWT_SECRET
          key: JWT_SECRET
        - objectName: EMAIL_PASS
          key: EMAIL_PASS
        
  ```
  ```
  apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: neocare

spec:
  replicas: 2

  selector:
    matchLabels:
      app: backend

  template:
    metadata:
      labels:
        app: backend

    spec:
      serviceAccountName: aws-csi-secret-manager

      containers:
        - name: backend
          image: shubhsjadhav95/neocare-backend:v12
          ports:
            - containerPort: 5000

          envFrom:
            - configMapRef:
                name: backend-config
            - secretRef:
                name: backend-secret

          volumeMounts:
            - name: secrets-store
              mountPath: "/mnt/secrets"
              readOnly: true

      volumes:
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "neocare-secrets"
```

  ```
  k apply -f secretProvider.yml
  ```
#### 
```
kubectl exec -n neocare -it backend-7fc8cdf46b-4vw96 -- ls /mnt/secrets/
```

```
kubectl exec -n neocare -it backend-7fc8cdf46b-4vw96 -- env | grep -E "DB_|JWT_|EMAIL_"
```