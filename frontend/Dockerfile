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
# Stage 2: Production Runtime
########################################
FROM nginx:alpine-slim

RUN apk update && apk upgrade --no-cache

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/css /usr/share/nginx/html/css
COPY --from=builder /app/js /usr/share/nginx/html/js

COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["nginx", "-t"]

STOPSIGNAL SIGQUIT

ENTRYPOINT ["nginx", "-g", "daemon off;"]