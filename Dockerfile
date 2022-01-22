
## integrate mailhog
FROM mailhog/mailhog AS mailhog
RUN echo hi


### integrate webmentiond

#FROM alpine:3.14
FROM zerok/webmentiond as webmention
RUN echo heyhey


## build from remark42
FROM umputun/remark42:latest
USER 0
RUN apk add --no-cache sqlite-dev # golang
#VOLUME ["/data"]
#RUN adduser -u 1500 -h /data -H -D webmentiond && \
RUN    mkdir -p /var/lib/webmentiond/frontend
COPY --from=webmention /var/lib/webmentiond/migrations /var/lib/webmentiond/migrations
COPY --from=webmention /usr/local/bin/webmentiond /usr/local/bin/webmentiond 
COPY --from=webmention /var/lib/webmentiond/frontend/dist /var/lib/webmentiond/frontend/dist
COPY --from=webmention /var/lib/webmentiond/frontend/css /var/lib/webmentiond/frontend/css
COPY --from=webmention /var/lib/webmentiond/frontend/index.html  /var/lib/webmentiond/frontend/index.html
COPY --from=webmention /var/lib/webmentiond/frontend/demo.html  /var/lib/webmentiond/frontend/demo.html
WORKDIR /var/lib/webmentiond
#USER 1500
#ENTRYPOINT ["/usr/local/bin/webmentiond", "serve", "--database-migrations", "/var/lib/webmentiond/migrations", "--database", "/data/webmentiond.sqlite"]

RUN adduser -D -u 1000 mailhog
COPY --from=mailhog /usr/local/bin/MailHog /usr/local/bin/MailHog

### Expose the SMTP and HTTP ports:
##EXPOSE 1025 8025

COPY default.conf /etc/nginx/http.d/
#RUN apk add --no-cache git bash jq 
#RUN apk add --no-cache curl findutils  psmisc psutils
#RUN apk add --no-cache openssh-client
RUN apk add curl findutils git bash jq  openssh-client inotify-tools nginx apache2-utils
RUN mv /init.sh /init.orig.sh
#RUN ln -sf /run/start.sh /init.sh
#RUN ln -sf /start/init.sh /srv/init.sh 
copy run/start.sh /init.sh
#copy run/start.sh /srv/init.sh
VOLUME ["/srv"]
RUN /usr/local/bin/webmentiond  --help || true 
RUN /srv/remark42 --help 2>&1 |grep avatar
RUN chmod +x /init.sh
EXPOSE 8080
