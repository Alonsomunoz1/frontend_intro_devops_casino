# syntax=docker/dockerfile:1
# ============================================================
# casino-frontend  -  build de Angular servido por nginx-unprivileged (8080)
# ============================================================

# ---- Stage 1: build de producción de Angular ----
FROM node:20-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build   # genera dist/casino-frontend (ver angular.json)

# ---- Stage 2: nginx-unprivileged (no root, puerto 8080) ----
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
# Config de reverse-proxy hacia los servicios internos
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copia el build de Angular al docroot de nginx
COPY --from=build /app/dist/casino-frontend /usr/share/nginx/html
EXPOSE 8080
# La imagen base ya corre como usuario 'nginx' sin privilegios
