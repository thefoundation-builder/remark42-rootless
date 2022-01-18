FROM umputun/remark42:latest
#RUN apk add --no-cache git bash jq 
#RUN apk add --no-cache curl findutils  psmisc psutils
#RUN apk add --no-cache openssh-client
RUN apk add curl findutils  psmisc psutils git bash jq  openssh-client 
RUN mv /init.sh /init.orig.sh
#RUN ln -sf /run/start.sh /init.sh
#RUN ln -sf /start/init.sh /srv/init.sh 
copy run/start.sh /init.sh
#copy run/start.sh /srv/init.sh
RUN chmod +x /init.sh
