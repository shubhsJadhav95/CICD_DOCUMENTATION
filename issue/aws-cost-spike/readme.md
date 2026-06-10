

### 1. always container port == service targetport,service port == ingress port 

### 2. ingress.yml certificate id in annotation

### 3. fronend nginx.config for backend must consist a k8s/backend service ex-backend-service:80


### 4. Corp must include domain name in backend url

### alb healthcheck added in backend

### one resp api for an alb health check return 200 ex- get-xyz.com/api/files/health