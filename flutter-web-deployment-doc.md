# 🚀 Déploiement de l'application Flutter Web avec Kubernetes (k3s), Traefik, Docker et HTTPS
## 🗺️ Objectif

Déployer une application Flutter Web sur un VPS via Kubernetes (k3s), avec HTTPS via Let's Encrypt, et un backend Go exposé sous un domaine personnalisé.

---

## Stack utilisée

- **VPS Linux (Ubuntu)**
- **k3s (Kubernetes léger)**
- **Traefik (Ingress Controller)**
- **Cert-Manager**
- **Docker**
- **Flutter Web**
- **Go (API backend)**

---

## Étapes de déploiement

### 1. Installation de Docker sur le VPS

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

---

### 2. Build et Push de l’image Flutter Web

Sur **la machine locale** :

```bash
flutter build web --release
docker build -t ilan916/onlyflick-web:latest .
docker push ilan916/onlyflick-web:latest
```

**Dockerfile utilisé :**

```Dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
```

---

### 3. Fichier de déploiement `onlyflick-web-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: onlyflick-web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: onlyflick-web
  template:
    metadata:
      labels:
        app: onlyflick-web
    spec:
      containers:
        - name: onlyflick-web
          image: ilan916/onlyflick-web:latest
          ports:
            - containerPort: 80
```

---

### 4. Fichier de service `onlyflick-web-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: onlyflick-web-service
spec:
  selector:
    app: onlyflick-web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

---

### 5. Fichier d'ingress `onlyflick-web-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: onlyflick-web-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls.certresolver: letsencrypt
spec:
  rules:
    - host: app.onlyflick.fun
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: onlyflick-web-service
                port:
                  number: 80
  tls:
    - hosts:
        - app.onlyflick.fun
      secretName: onlyflick-web-tls
```

---

### 6. Fichier certificat `onlyflick-web-certificate.yaml`

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: onlyflick-web-tls
  namespace: default
spec:
  secretName: onlyflick-web-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: app.onlyflick.fun
  dnsNames:
    - app.onlyflick.fun
```

---

## Résultat final

- Backend Go accessible via : `https://onlyflick.fun`
- Application Flutter Web accessible via : `https://app.onlyflick.fun`
- Certificats HTTPS valides émis par Let's Encrypt via cert-manager

---

## Astuce : Pour vérifier le certificat

```bash
kubectl get certificate -A
kubectl describe certificate onlyflick-web-tls
```

---

## Sécurité

- Accès HTTPS complet
- Certificat Let's Encrypt automatique
- CORS géré côté backend (mise à jour de `CORS_ALLOWED_ORIGINS`)

---

