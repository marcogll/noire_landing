# Etapa de construcción
FROM node:18-alpine AS builder

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de package
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar archivos del proyecto
COPY . .

# Construir CSS de Tailwind si es necesario
RUN npm run build || true

# Etapa de producción
FROM nginx:alpine

# Instalar el usuario appuser y establecer permisos
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copiar archivos de construcción estáticos
COPY --from=builder /app /usr/share/nginx/html

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Establecer permisos correctos
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

# Cambiar al usuario appuser
USER appuser

# Exponer puerto 8080 en lugar de 80 para evitar conflictos
EXPOSE 8080

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]