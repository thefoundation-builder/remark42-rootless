#!/bin/bash

## e.g.
## echo GIT_REPO_PUBKEY=$(base64 -w0 .ssh/id_rsa.pub ) >> /tmp/.env
## echo GIT_REPO_PUBKEY=$(bae64 -w0 .ssh/id_rsa.pub ) >> /tmp/env
echo "INIT"
                   

[[ -z "$REMARK_URL" ]] && export REMARK_URL=http://127.0.0.1:8080
[[ -z "$SLEEPINTER" ]]        &&  SLEEPINTER=90


[[ -z "$GIT_REPO_SYNC" ]]     &&  echo "NO REPO;CANNOT RUN"
[[ -z "$GIT_REPO_SYNC" ]]     &&  exit 1
[[ -z "$GIT_REPO_KEY" ]]      &&  echo "NO KEY ;CANNOT RUN"
[[ -z "$GIT_REPO_KEY" ]]      &&  exit 1

[[ -z "$GIT_REPO_PUBKEY" ]]   &&  echo "NO PuBKEY ;CANNOT RUN"
[[ -z "$GIT_REPO_PUBKEY" ]]   &&  exit 1

[[ -z "$BACKUP_PATH" ]] &&    BACKUP_PATH=/tmp/backup
[[ -z "$BACKUP_PATH" ]] &&    BACKUP_PATH=/tmp/backup
[[ -z "STORE_BOLT_PATH" ]] && STORE_BOLT_PATH=/srv/varmodify
[[ -z "$ALLOWED_DOMAINS" ]] && export ALLOWED_DOMAINS=mydomain.lan

mkdir ~/.ssh -p
#apk add --no-cache git bash openssh-clientSECRET=
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
echo "CLONED"
find /tmp/gitstorage |grep -v /tmp/gitstorage/.git/ |sed 's/$/|/g' |tr -d '\n'

[[ -z "$GITPATH" ]] || mkdir -p "$GITPATH"
( echo "init:copyDirs  /tmp/gitstorage  ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -mindepth 1 -type d |grep -v ".git"|while read mydir ;do mkdir -p  ${GITPATH}/"$mydir" ;done 2>&1 )  |sed 's/$/|/g' |tr -d '\n'
( echo "init:copyFile  /tmp/gitstorage  ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -mindepth 1 -type f |grep -v ".git"|while read myfile;do diff --brief "$myfile" ${GITPATH}/"$myfile" 2>&1 || cp -v  "$myfile" ${GITPATH}/"$myfile" ;done 2>&1 )  |sed 's/$/|/g' |tr -d '\n'

chown -R app /${GITPATH}

#[[ -z "$GITPATH" ]] || ( cd "${GITPATH}" && git pull )
[[ -z "$GIT_REPO_BACKUP" ]] || myclone ${GIT_REPO_BACKUP} "$BACKUP_PATH" 

mkdir -p ${STORE_BOLT_PATH}
test -e /srv/var || mkdir -p /srv/var
( sleep 60;  while (true);do ( 
                             
                             [[ -z "$GITPATH" ]] || ( 
                               cd /tmp/gitstorage
                               git config user.name "remarks42rootless" &>/dev/null
                               git config user.email "you@example.com" &>/dev/null
                               git pull  --ff-only;
                                     cd ${GITPATH} ; pwd ;
                                     find -type d -mindepth 1|grep -v ".git"|while read mydir ;do test -e /tmp/gitstorage/"$mydir"  || mkdir -p test /tmp/gitstorage/"$mydir" ;done
                                     find -type f -mindepth 1 |grep -v -e  "^/.git" -e "^./remark42$" -e "^./web/" |while read myfile;do cp -v  "$myfile" /tmp/gitstorage/"$myfile" ;done 
                                     cd /tmp/gitstorage/ ;
                                     
                                     git add -A
                                     mypush --force
                                     ) |sed 's/$/|/g' |tr -d '\n'
                            
                            [[ -z "$GIT_REPO_BACKUP" ]] || ( cd "$BACKUP_PATH" ; pwd git add -A  ;git commit -m $(date +%F_%T)"auto" ;mypush )    ) ; 
                            cd $GITPATH; sleep 30;inotifywatch -e delete -e create -e move -e move_self -e modify -e attrib $(find $GITPATH)  ; done
 ) &
 
echo "PREP"

[[ -z "$MENTION_ADMINPASS" ]] && { MENTION_ADMINPASS=$RANDOM_$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 23);echo "YOU DID NOT SET A ADMIN PASS FOR WEBMENTIONS IT IS NOW $MENTION_ADMINPASS " ; } ;
test -e /${GITPATH}/htpass.mail && rm /${GITPATH}/htpass.mail
echo $MENTION_ADMINPASS |htpasswd -cBi  /${GITPATH}/htpass.mail mention_admin

#cat /init.orig.sh
#printenv
echo "FORKING nginx"
while (true);do nginx -g "daemon off;" ;sleep 5;done &
chown -R app /srv

echo "FORKING MAIL UI"
while (true);do su -s /bin/bash -c /usr/local/bin/MailHog mailhog ;sleep 5;done &
echo "PREP WEBMENTIOND"
URL=$REMARK_URL
[[ -z "$JWTSECRET" ]] && JWTSECRET=$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 10 )$RANDOM
echo "FORKING WEBMENTIOND"
export MAIL_NO_TLS=true
echo "RUN: "'MAIL_NO_TLS=true MAIL_PASSWORD=doesnotmatter MAIL_USER=mails@webmention-ui.local MAIL_FROM=mails@webmention-ui.local MAIL_PORT=1025 EMAIL_HOST=127.0.0.1 MAIL_HOST=127.0.0.1   SERVER_AUTH_JWT_SECRET='$JWTSECRET' /usr/local/bin/webmentiond serve    --public-url='$URL'/webmentions      --addr 127.0.0.1:8023 --allowed-target-domains "'$ALLOWED_DOMAINS'"    --auth-admin-emails "admina@webmention-ui.local"        --database-migrations /var/lib/webmentiond/migrations    --database /'${GITPATH}'/webmentiond.sqlite     --verification-timeout=120s    --verification-max-redirects=5 --verbose'
while (true);do 
##att multiline ahead
  su -s /bin/bash -c 'MAIL_NO_TLS=true MAIL_PASSWORD=doesnotmatter MAIL_USER=mails@webmention-ui.local  MAIL_FROM=mails@webmention-ui.local MAIL_PORT=1025 EMAIL_HOST=127.0.0.1 MAIL_HOST=127.0.0.1   SERVER_AUTH_JWT_SECRET='$JWTSECRET' /usr/local/bin/webmentiond serve    --public-url='$URL'/webmentions      --addr 127.0.0.1:8023 --allowed-target-domains "'$ALLOWED_DOMAINS'"    --auth-admin-emails "admina@abc.de"        --send-notifications --database-migrations /var/lib/webmentiond/migrations    --database /'${GITPATH}'/webmentiond.sqlite     --verification-timeout=120s    --verification-max-redirects=5 --verbose' app;sleep 5;done &
##[[ -z "$SECRET" ]] && echo no secret set
##[[ -z "$SECRET" ]] && SECRET=$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 10 )$RANDOM 
##export SECRET=${SECRET}
chown -R app /srv
chmod ug+w /srv
pwd
(sleep 30;
echo "testing interfaces" ;curl -kLv 127.0.0.1:8081/web/embed.js > /dev/null;echo "###";curl -kLv 127.0.0.1:8023/ui/ > /dev/null;
echo "testing interfaces (nginx)" ;curl -kLv 127.0.0.1:8080/web/embed.js > /dev/null;echo "###";curl -kLv 127.0.0.1:8080/webmentions/ui/ > /dev/null;
 ) &
cd /srv
echo "STARTING  REMARK42 with  /srv/remark42 server --secret $SECRET"
export REMARK_PORT=8081
bash /init.orig.sh /srv/remark42 server
#ls -lh1 /srv/remark42 /srv/remark42 server
