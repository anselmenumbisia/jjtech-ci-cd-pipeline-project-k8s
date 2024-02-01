# Deploy Prometheus and Grafana to eks/kubernetes

## Prerequisites:
1. helm v3 installled. To verify, run helm version
2. eks cluster

## Deploy Prometheus

1. Create namespace for prometheus
```bash
kubectl create namespace prometheus 
```

2. verify namespace was created. i.e verify that prometheus namespace exists
```bash
kubectl get ns
```

3. get the prometheus repo from artifacthub
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
and update the helm repo

```bash
helm repo update
```

4. install helm release for prometheus in the prometheus namespace
```bash
helm install monitoring prometheus-community/kube-prometheus-stack -n prometheus
```

5. check all resources by deployed by helm
```bash
kubectl get all -n prometheus
```

6. Edit the prometheus and grafana services by changing service type to **LoadBalancer**
```bash
kubectl edit svc monitoring-grafana
kubectl edit svc monitoring-prometheus
```
7. To access grafana, grab Loadbalancer endpoint for grafana and run on your browser of choice
username: admin
password: prom-operator

The secret can be retrieved by running
```bash 
kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

8. To access prometheus, grab prometheus loadbalancer endpoint and run on browser. Add **:9090**


9. Add a dashboard to grafana
click on + symbol on left sidebar > import and enter *12740*digit and click on load > select prometheus as default datasource







ignore:

helm install prometheus prometheus-community/prometheus \
--namespace prometheus \
--set server.service.type=LoadBalancer \
--set alertmanager.persistentVolume.storageClass="gp2" \
--set server.persistentVolume.storageClass="gp2"