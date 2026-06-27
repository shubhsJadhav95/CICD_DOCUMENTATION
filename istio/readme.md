#### Istio Installation

```
curl -L https://istio.io/downloadIstio | sh -
```
```
cd istio-1.26.1
```

```
export PATH=$PWD/bin:$PATH
```

```
istioctl install --set profile=demo -y
```

#### Installs 
#### - Istio Control plane
#### - Istio-ingressgateway (default gateway)

#### For Personilized addions Visit

```
https://istio.io/latest/docs/ops/integrations/
```
#### -Prometheus
#### -Grafana
#### -Kiali
#### -Jeagar
