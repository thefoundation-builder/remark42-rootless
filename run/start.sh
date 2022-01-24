#!/bin/bash



## e.g.
## echo GIT_REPO_PUBKEY=$(base64 -w0 .ssh/id_rsa.pub ) >> /tmp/.env
## echo GIT_REPO_PUBKEY=$(bae64 -w0 .ssh/id_rsa.pub ) >> /tmp/env
[[ -z "$GIT_REPO_SYNC" ]]      &&   echo "NO REPO;CANNOT RUN"
[[ -z "$GIT_REPO_SYNC" ]]      &&   exit 1
[[ -z "$GIT_REPO_KEY" ]]       &&   echo "NO KEY ;CANNOT RUN"
[[ -z "$GIT_REPO_KEY" ]]       &&   exit 1

[[ -z "$GIT_REPO_PUBKEY" ]]    &&  echo "NO PuBKEY ;CANNOT RUN"
[[ -z "$GIT_REPO_PUBKEY" ]]    &&  exit 1

oneline() { tr -d '\n' ; } ;
[[ -z "$GITPATH" ]] && export   GITPATH=/srv/
test -e $GITPATH || {echo mkdir $GITPATH;mkdir  -p "$GITPATH" ; } ;


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

echo "INIT"
[[ -z "$GITPATH" ]] && export  GITPATH=/srv/

(
mkdir ~/.ssh -p
#apk add --no-cache git bash openssh-clientSECRET=
echo "$GIT_REPO_PUBKEY"|base64 -d > ~/.ssh/id_rsa.pub
echo "$GIT_REPO_KEY"   |base64 -d > ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa.pub ~/.ssh/id_rsa
ssh-keyscan  gitlab.com >>  ~/.ssh/known_hosts 2>&1 | oneline
ssh-keyscan  github.com >>  ~/.ssh/known_hosts  2>&1 | oneline
myclone ${GIT_REPO_SYNC} /tmp/gitstorage 
[[ -z "${GITPATH}" ]] || mkdir -p "${GITPATH}" &
echo "CLONED";

#find /tmp/gitstorage |grep -v /tmp/gitstorage/.git/ |sed 's/$/|/g' |tr -d '\n' &


( echo "init:copyDirs  /tmp/gitstorage  ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -mindepth 1 -type d |grep -v ".git"|grep -v ^$|while read mydir ;do 
    mkdir -p  ${GITPATH}/"$mydir" ;done 2>&1 )  |sed 's/$/|/g' |tr -d '\n'
( echo "init:copyFile  /tmp/gitstorage  ${GITPATH}/" ;cd /tmp/gitstorage/ ;find -mindepth 1 -type f |grep -v ".git"|grep -v ^$|while read myfile;do 
    diff --brief "$myfile" ${GITPATH}/"$myfile" 2>&1 || cp -v  "$myfile" ${GITPATH}/"$myfile" ;done 2>&1 )  |sed 's/diff: can.t stat.\+/diff: cannott stat .. /g;s/$/|/g' |tr -d '\n'

chown -R app /${GITPATH}

#[[ -z "$GITPATH" ]] || ( cd "${GITPATH}" && git pull )
[[ -z "$GIT_REPO_BACKUP" ]] || myclone ${GIT_REPO_BACKUP} "$BACKUP_PATH" 

) &       

[[ -z "$REMARK_URL" ]]        && export REMARK_URL=http://127.0.0.1:8080
[[ -z "$SLEEPINTER" ]]        && SLEEPINTER=90

[[ -z "$NOTIFY_ADMINS=emai" ]] && NOTIFY_ADMINS=email
[[ -z "$ADMIN_SHARED_EMAIL" ]] && ADMIN_SHARED_EMAIL=publicvisible@site.local


[[ -z "$ADMIN_MAIL" ]]         && ADMIN_MAIL=admin@site.local

[[ -z "$SMTP_HOST" ]]          && export SMTP_HOST=127.0.0.1
[[ -z "$SMTP_PORT" ]]          && export SMTP_PORT=1025
[[ -z "$SMTP_TLS" ]]           && export SMTP_TLS=false
[[ -z "$SMTP_USERNAME" ]]      && export SMTP_USERNAME=postmaster@local.lan
[[ -z "$SMTP_PASSWORD" ]]      && export SMTP_PASSWORD=secretpassword
[[ -z "$AUTH_EMAIL_FROM" ]]    && export AUTH_EMAIL_FROM=notify@local.lan
[[ -z "$NOTIFY_EMAIL_FROM" ]]  && export NOTIFY_EMAIL_FROM=notify@local.lan
[[ -z "$BACKUP_PATH" ]]        && export BACKUP_PATH=/tmp/backup
[[ -z "$BACKUP_PATH" ]]        && export BACKUP_PATH=/tmp/backup
[[ -z "STORE_BOLT_PATH" ]]     && export STORE_BOLT_PATH=/srv/varmodify

[[ -z "$ALLOWED_DOMAINS" ]]    && export ALLOWED_DOMAINS=$(echo "$REMARK_URL" |cut -d"/" -f3|cut -d: -f1)

## inverse logic
export MAIL_NO_TLS=false
[[ "$SMTP_TLS" = "false" ]]    && export=MAIL_NO_TLS=true

## keyscan


#myclone ${GIT_REPO_SYNC}  ${GITPATH} || mkdir -p  ${GITPATH}
#DO NOT RUN WITHOUT STORAGE FROM GIT 

mkdir -p ${STORE_BOLT_PATH}
test -e /$GITPATH/var || mkdir -p /$GITPATH/var
chown -R app /srv
chmod ug+w /srv
wait
echo "PREP"
(sleep 20;pwd;echo ENV ;env|grep -v -e _KEY -e ADMINPASS ) &
[[ -z "$MENTION_ADMINPASS" ]] && { MENTION_ADMINPASS=$RANDOM_$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 23);echo "YOU DID NOT SET A ADMIN PASS FOR WEBMENTIONS IT IS NOW $MENTION_ADMINPASS " ; } ;
[[ -z "$MENTION_ADMIN" ]] && MENTION_ADMIN=site_admin
test -e /${GITPATH}/htpass.mail && rm /${GITPATH}/htpass.mail
echo $MENTION_ADMINPASS |htpasswd -cBi  /${GITPATH}/htpass.mail "$MENTION_ADMIN"



( 
  sed -i 's~/var/log/php7/.\+\.log~/dev/stderr~g' $(find  /etc/php* -type f ) &  
  mkdir -p /var/log/php7 ; 
  ln -sf /dev/stderr /var/log/php7/access.log & ln -sf /dev/stderr /var/log/php7/arror.log ; chown -R app:app /var/log/php7 &
  wait  ;echo "FORKING FPM"; while (true);do su -s /bin/bash app -c "php-fpm7 --nodaemonize --force-stderr -d 'error_log = /dev/stderr;'";sleep 3;done 
) & #end php-fpm


(
test -e ${GITPATH}/mailhog_maildir || mkdir ${GITPATH}/mailhog_maildir   &
test -e ${GITPATH}/mailhog_config  || mkdir ${GITPATH}/mailhog_config    &
wait
 echo "FORKING MAIL UI"
while (true);do su -s /bin/bash -c "MH_MAILDIR_PATH=${GITPATH}/mailhog_maildir MH_STORAGE=maildir /usr/local/bin/MailHog mailhog" 2>&1 |grep -e API -e "To:" -e "Subject:" -e " Found " -e Message-Id  ;sleep 5;done 
) & ##end mailhog





( echo "PREP WEBMENTIOND"
test -e /${GITPATH}/htpass.webmentions && rm /${GITPATH}/htpass.webmentions
ln -s /${GITPATH}/htpass.mail /${GITPATH}/htpass.webmentions
URL=$REMARK_URL
[[ -z "$JWTSECRET" ]] && JWTSECRET=$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 10 )$RANDOM
echo "FORKING WEBMENTIOND"
export MAIL_NO_TLS=true
echo "RUN: "'MAIL_NO_TLS='$MAIL_NO_TLS' MAIL_PASSWORD='$SMTP_PASSWORD' MAIL_USER='$SMTP_USERNAME'  MAIL_FROM='$NOTIFY_EMAIL_FROM' MAIL_PORT='$SMTP_PORT' EMAIL_HOST='$SMTP_HOST' MAIL_HOST='$SMTP_HOST'   SERVER_AUTH_JWT_SECRET='$JWTSECRET' /usr/local/bin/webmentiond serve    --public-url='$URL'/webmentions      --addr 127.0.0.1:8023 --allowed-target-domains "'$ALLOWED_DOMAINS'"    --auth-admin-emails "'$ADMIN_MAIL'"        --database-migrations /var/lib/webmentiond/migrations    --database /'${GITPATH}'/webmentiond.sqlite     --verification-timeout=120s    --verification-max-redirects=5 '
while (true);do 
##att multiline ahead
su -s /bin/bash -c 'MAIL_NO_TLS='$MAIL_NO_TLS' MAIL_PASSWORD='$SMTP_PASSWORD' MAIL_USER='$SMTP_USERNAME'  MAIL_FROM='$NOTIFY_EMAIL_FROM' MAIL_PORT='$SMTP_PORT' EMAIL_HOST='$SMTP_HOST' MAIL_HOST='$SMTP_HOST'   SERVER_AUTH_JWT_SECRET='$JWTSECRET' /usr/local/bin/webmentiond serve    --public-url='$URL'/webmentions      --addr 127.0.0.1:8023 --allowed-target-domains "'$ALLOWED_DOMAINS'"    --auth-admin-emails "'$ADMIN_MAIL'"        --send-notifications --database-migrations /var/lib/webmentiond/migrations    --database /'${GITPATH}'/webmentiond.sqlite     --verification-timeout=120s    --verification-max-redirects=5 ' app;sleep 5;done &
##[[ -z "$SECRET" ]] && echo no secret set
##[[ -z "$SECRET" ]] && SECRET=$(cat /dev/urandom|tr -cd '[:alnum:]' |head -c 10 )$RANDOM 
##export SECRET=${SECRET}
) & ##end webmentiond

#cat /init.orig.sh
#printenv
echo "FORKING nginx"
while (true);do nginx -g "daemon off;" ;sleep 5;done &
chown -R app /${GITPATH}

### git push loop 
( sleep 60;  while (true);do ( 
                             
                             [[ -z "$GITPATH" ]] || ( 
                               cd /tmp/gitstorage
                               git config user.name "remarks42rootless" &>/dev/null
                               git config user.email "you@example.com" &>/dev/null
                               git status
                              # git pull  --ff-only;
                                     cd ${GITPATH} ; pwd ;
                                     find -type d -mindepth 1|grep -v ".git"|while read mydir ;do test -e /tmp/gitstorage/"$mydir"  || mkdir -p test /tmp/gitstorage/"$mydir" ;done
                                     find -type f -mindepth 1 |grep -v -e  "^/.git" -e "^./remark42$" -e "^./web/" |while read myfile;do cp -v  "$myfile" /tmp/gitstorage/"$myfile" ;done 
                                     cd /tmp/gitstorage/ ;
                                     
                                     git add -A
                                     mypush --force
                                     ) |sed 's/$/|/g' |tr -d '\n'
                            
                            [[ -z "$GIT_REPO_BACKUP" ]] || ( cd "$BACKUP_PATH" ; pwd git add -A  ;git commit -m $(date +%F_%T)"auto" ;mypush )    ) ; 
                            cd $GITPATH; sleep 30;inotifywait -e delete -e create -e move -e move_self -e modify -e attrib $(find $GITPATH)  ; done
 ) &


 ## local quick tests
(sleep 30;
echo "testing interfaces" ;curl -kLv 127.0.0.1:8081/web/embed.js 2>&1|grep -v 'function()'|grep -e HTTP -e GET -e Error -e error -e Fail -e fail -e timeout -e 502  -e 404 ;echo "###";curl -kLv 127.0.0.1:8023/ui/ 2>&1|grep -v 'function()'|grep -e HTTP -e GET -e Error -e error -e Fail -e fail -e timeout -e 502  -e 404 ;
echo "testing interfaces (nginx)" ;curl -kLv 127.0.0.1:8080/web/embed.js 2>&1|grep -v 'function()'|grep -e HTTP -e GET -e Error -e error -e Fail -e fail -e timeout -e 502  -e 404 ;echo "###";curl -kLv 127.0.0.1:8080/webmentions/ui/ 2>&1|grep -v 'function()'|grep -e HTTP -e GET -e Error -e error -e Fail -e fail -e timeout -e 502  -e 404 ;
 ) &
cd /srv
echo "STARTING  REMARK42 with  /srv/remark42 server --secret $SECRET"
export REMARK_PORT=8081
bash /init.orig.sh /srv/remark42 server
#ls -lh1 /srv/remark42 /srv/remark42 server
