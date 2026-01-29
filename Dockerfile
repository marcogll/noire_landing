# Etapa de producción - aplicación estática
FROM nginx:alpine

# Instalar el usuario appuser y establecer permisos
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copiar archivos estáticos directamente
COPY . /usr/share/nginx/html

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