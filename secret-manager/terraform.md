#### Terraform issue and pod issue 

 MountVolume.SetUp failed for volume "secrets-store" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod one8pulse/one8pulse-configserver-5bf5d9f456-kkcbc, err: rpc error: code = Unknown desc = Failed to fetch secret from all regions. Verify secret exists and required permissions are granted for: stage/one8pulse

#### Get an OIDC URL

```
aws eks describe-cluster --name <YOUR-CLUSTER-NAME> --query "cluster.identity.oidc.issuer" --output text
```

 #### Create an Policy 

 ```
 cat > /tmp/trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::797111435256:oidc-provider/YOUR_ACTUAL_OIDC_URL_HERE"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "YOUR_ACTUAL_OIDC_URL_HERE:sub": "system:serviceaccount:one8pulse:aws-csi-secret-manager",
          "YOUR_ACTUAL_OIDC_URL_HERE:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
```
#### Edit for Any Changes
```
nano /tmp/trust.json
```

#### Check is really OIDC Provide Exit

```
aws iam list-open-id-connect-providers
```

#### Get an Secret Manager Role

```
kubectl get sa -n one8pulse aws-csi-secret-manager -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}'
echo
```

#### Update ROle 
```
aws iam update-assume-role-policy \
  --role-name <paste-role-name-here> \
  --policy-document file:///tmp/trust.json
```

```
kubectl delete pod -n one8pulse one8pulse-configserver-5bf5d9f456-kkcbc one8pulse-configserver-5bf5d9f456-sl6lc
kubectl get pods -n one8pulse -w
```