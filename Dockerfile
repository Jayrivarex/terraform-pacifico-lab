FROM nginx:alpine

RUN echo "<h1>Banco Pacifico - DevOps Pipeline OK</h1>" > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]