# Stage 1: Construcción de la aplicación Angular
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration=production

# Stage 2: Servidor Nginx Unprivileged para producción
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

# Copiar el output estático de Angular al directorio de Nginx
COPY --from=builder --chown=nginx:nginx /app/dist/casino-frontend /browser/usr/share/nginx/html/

# Copiar el archivo nginx.conf a la carpeta de plantillas (Exigencia para envsubst)
COPY --chown=nginx:nginx nginx.conf /etc/nginx/templates/default.conf.template

USER nginx
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
