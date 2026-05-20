########################################
# Stage 1: Prepare static assets
########################################
FROM nginx:1.28-alpine AS builder

WORKDIR /app

COPY index.html .
COPY css ./css
COPY js ./js
COPY nginx.conf ./nginx.conf

########################################
# Stage 2: Secure Production Runtime
########################################
FROM nginx:alpine-slim

# Switch to root
USER root

# Update vulnerable Alpine packages
RUN apk update && apk upgrade --no-cache

# Remove default content
RUN rm -rf /usr/share/nginx/html/*

# Copy application assets
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/css /usr/share/nginx/html/css
COPY --from=builder /app/js /usr/share/nginx/html/js

# Copy nginx config
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

# Fix ownership
RUN chown -R 101:101 /usr/share/nginx/html \
    && chown -R 101:101 /etc/nginx/conf.d

# Drop privileges
USER 101:101

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["nginx", "-t"]

STOPSIGNAL SIGQUIT

ENTRYPOINT ["nginx", "-g", "daemon off;"]
