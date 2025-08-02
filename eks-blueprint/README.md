# Adding IAM users to platform team to serve CLuster Admins

1. After deploying EKS blusprint using terraform, a platform assume role is created with name **team-platform-xxxx**
2. create a new IAM user, attach **team-platform-xxxxx** to the user
3. Get programmatic access credentials and update ~/.aws/credentials and config files by creating a new profile
4. edit ~/.aws/config using text editor and have the new profile added above assume the role team-platform-xxxx
```bash
[profile PROFILE_NAME]
role_arn = arn:aws:iam::AWS_ACCOUNT_ID:role/team-platform-xxxx
source_profile = SOURCE_PROFILE_NAME

example:

[profile cluster-admin]
role_arn = arn:aws:iam::account-id:role/team-platform-xxxx
source_profile = test-user
```

5. Update aws-auth configmap by adding the following input to eks terraform module
```bash
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::account-id:role/team-platform-xxxx"
      username = "cluster-admin"
      groups   = ["system:masters"]
    },
  ]

  ```
  Verify the aws-auth configmap to see if the role has been added by running 

  ```bash
  kubectl describe configmap aws-auth -n kube-system
  ```

5. switch user access using AWS CLI by running 
```bash
export AWS_PROFILE=PROFILE_NAME (as found in the config and not credential file)
```

6. update kubeconfig 

```bash
aws eks --region REGION update-kubeconfig --name CLUSTE-NAME --profile PROFILE_NAME e.g(cluster-admin)
```
7. run the command below to ensure you can assume the role
```bash
aws sts get-caller-identity --profile PROFILE_NAME e.g(cluster-admin)
```

8. Run command below to check authorization level in cluster

```bash
k auth can-i get po -A
k auth can-i delete po -A
```

9. To return to inital profile that created cluster, run 
```bash
aws eks --region REGION update-kubeconfig --name CLUSTE-NAME
export AWS_PROFILE=PROFILE_NAME
```



