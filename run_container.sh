#!/bin/bash

# PHP71
container_name="vp_php71"
expose_port=8100
config_dir="~/vpgame/config"
code_dir="~/vpgame"
docker run \
--name ${container_name} \
-p ${expose_port}:80 \
--privileged=true \
-v ${config_dir}/nginx_conf/${container_name}:/etc/nginx/conf.d  \
-v $code_dir:/app \
-v ${config_dir}/log/${container_name}:/var/log/nginx \
-v ${config_dir}/log/${container_name}/vpgame:/var/log/das \
--add-host="jv.api.league.dev.vpgme.com:127.0.0.1" \
--dns=202.96.209.5 \
--dns=114.114.114.114 \
--link mysql56 \
-it \
-d \
jvphp/nginx_php719:php719;