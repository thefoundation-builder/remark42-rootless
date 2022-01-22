#!/bin/bash

## e.g.
## echo GIT_REPO_PUBKEY=$(base64 -w0 .ssh/id_rsa.pub ) >> /tmp/.env
## echo GIT_REPO_PUBKEY=$(bae64 -w0 .ssh/id_rsa.pub ) >> /tmp/env
echo "INIT"


[[ -z "$SLEEPINTER" ]]        &&  SLEEPINTER=90
[[ -z "$GIT_REPO_KEY" ]]      &&  echo "NO KEY ;CANNOT RUN"
[[ -z "$GIT_REPO_KEY" ]]      &&  exit 1
[[ -z "$GIT_REPO_PUBKEY" ]]   &&  echo "NO PuBKEY ;CANNOT RUN"
[[ -z "$GIT_REPO_PUBKEY" ]]   &&  exit 1
[[ -z "$GIT_REPO_SYNC" ]]     &&  echo "NO REPO;CANNOT RUN"
[[ -z "$GIT_REPO_SYNC" ]]     &&  exit 1

[[ -z "$BACKUP_PATH" ]] &&    BACKUP_PATH=/tmp/backup
[[ -z "$BACKUP_PATH" ]] &&    BACKUP_PATH=/tmp/backup
[[ -z "STORE_BOLT_PATH" ]] && STORE_BOLT_PATH=/srv/var
mkdir ~/.ssh -p
#apk add --no-cache git bash openssh-client
[[ -z "$GITPATH" ]] && export  GITPATH=/srv/
echo "$GIT_REPO_PUBKEY"|base64 -d > ~/.ssh/id_rsa.pub
echo "$GIT_REPO_KEY"   |base64 -d > ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa.pub ~/.ssh/id_rsa
## keyscan
oneline() { tr -d '\n' ; } ;
[[ -z "$GITPATH" ]] && GITPATH=/srv/
test -e $GITPATH || mkdir  -p "$GITPATH"
ssh-keyscan  gitlab.com >>  ~/.ssh/known_hosts 2>&1 | oneline
ssh-keyscan  github.com >>  ~/.ssh/known_hosts  2>&1 | oneline


myclone() {
export GIT_SSH_COMMAND='/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts'
echo git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts" $@ ;
git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts" $@  2>&1|grep -v -e "Warning: Permanently added the RSA host key for IP address "  ; } ;

git config --global user.name "remarks42rootless" &>/dev/null
git config --global user.email "you@example.com"  &>/dev/null

mypush() {
export GIT_SSH_COMMAND='/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts'
git config user.name "remarks42rootless" &>/dev/null
git config user.email "you@example.com" &>/dev/null
git add -A  ;git commit -m $(date +%F_%T)"auto";
git push $@ 2>&1|grep -v -e "Warning: Permanently added the RSA host key for IP address " -e "To "; } ;


#myclone ${GIT_REPO_SYNC}  ${GITPATH} || mkdir -p  ${GITPATH}
#DO NOT RUN WITHOUT STORAGE FROM GIT 
myclone ${GIT_REPO_SYNC} /tmp/gitstorage 
[[ -z "$GITPATH" ]] || mkdir -p "$GITPATH"
( echo "init:copyDir  ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -type d|grep -v ".git"|while read mydir ;do mkdir -p  ${GITPATH}/"$mydir" ;done)
( echo "init:copyFile ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -type f|grep -v ".git"|while read myfile;do diff --brief "$myfile" ${GITPATH}/"$myfile"  || cp -v  "$myfile" ${GITPATH}/"$myfile" ;done)

[[ -z "$GITPATH" ]] || ( cd "${GITPATH}" && git pull )
[[ -z "$GIT_REPO_BACKUP" ]] || myclone ${GIT_REPO_BACKUP} "$BACKUP_PATH" 

mkdir -p ${STORE_BOLT_PATH}
test -e /srv/var || mkdir -p /srv/var
( sleep 10;  while (true);do ( 
                             
                             [[ -z "$GITPATH" ]] || ( 
                                     cd ${GITPATH} ; pwd ;
                                     find -type d|grep -v ".git"|while read mydir ;do test -e /tmp/gitstorage/"$mydir"  || mkdir -p test /tmp/gitstorage/"$mydir" ;done
                                     find -type f|grep -v ".git"|grep -v "^./remark42$" |while read myfile;do cp -v  "$myfile" /tmp/gitstorage/"$myfile" ;done
                                     cd /tmp/gitstorage/ ;
                                     mypush
                                     )
                            
                            [[ -z "$GIT_REPO_BACKUP" ]] || ( cd "$BACKUP_PATH" ; pwd git add -A  ;git commit -m $(date +%F_%T)"auto" ;mypush )    ) ; sleep 90; done
 ) &  

echo "PREP"
#cat /init.orig.sh
printenv
echo "FORKING nginx"
while (true);do nginx -g "daemon off;" ;sleep 5;done &


echo "FORKING MAIL UI"
while (true);do su -s /bin/bash -c /usr/local/bin/MailHog mailhog ;sleep 5;done &

[[ -z "$URL" ]] && URL=localhost.lan
[[ -z "$JWTSECRET" ]] && JWTSECRET=$(cat /dev/urandom|tr -cd '[:alnum:]' |head -n 10 )$RANDOM
echo "FORKING WEBMENTIOND"
while (true);do 
##att multiline ahead
  MAIL_NO_TLS=true MAIL_FROM=webmention-ui.local MAIL_PORT=1025 MAIL_HOST=127.0.0.1   SERVER_AUTH_JWT_SECRET=$JWTSECRET \
   /usr/local/bin/webmentiond serve \
   --public-url=$URL/webmentions    \
   --allowed-target-domains "mydomain.lan" \
   --auth-admin-emails "admina@abc.de"     \
   --database-migrations /var/lib/webmentiond/migrations \
   --database /srv/webmentiond.sqlite  \
   --verification-timeout=120s \
   --verification-max-redirects=5


/usr/local/bin/webmentiond serve --database-migrations /var/lib/webmentiond/migrations --database /data/webmentiond.sqlite;sleep 5;done &
echo "STARTING  REMARK42"
export REMARK_PORT=8081
bash /init.orig.sh /srv/remark42 server
#ls -lh1 /srv/remark42 /srv/remark42 server
