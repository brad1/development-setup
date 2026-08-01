# EKS Tracer Final
WIP

## Cluster Checklist
```
aws login
aws eks update-kubeconfig --region us-east-1 --name $CLUSTER_NAME 
kubectl get pods -A #  two metrics pods from metrics replicaset to start
echo "Node Groups"
kubectl get nodes 
aws iam list-attached-role-policies --role-name DefaultNodeGroupRole
aws eks describe-nodegroup \
  --cluster-name $CLUSTER_NAME \
  --nodegroup-name DefaultNodeGroup \
  --query 'nodegroup.{status:status,health:health}'
```
