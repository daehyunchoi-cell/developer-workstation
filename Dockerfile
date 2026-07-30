FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
COPY site/ /usr/share/nginx/html/