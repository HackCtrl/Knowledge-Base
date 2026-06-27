```
# Используем базовый образ Nginx
FROM nginx:alpine

# Копируем файл index.html внутрь образа
COPY index.html /usr/share/nginx/html/index.html
```
