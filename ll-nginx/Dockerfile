FROM nginx
ARG domain_name
ENV DOMAIN_NAME=${domain_name:-placeholder.name}

COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

WORKDIR /etc/nginx/conf.d/

RUN sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" default.conf.template

RUN mv default.conf.template default.conf

CMD ["nginx", "-g", "daemon off;"]