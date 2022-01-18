#!/bin/bash
echo "INIT"
[[ -z "$SLEEPINTER" ]]        &&  SLEEPINTER=90
[[ -z "$GIT_REPO_KEY" ]]      &&  echo "NO KEY ;CANNOT RUN"
[[ -z "$GIT_REPO_KEY" ]]      &&  exit 1
[[ -z "$GIT_REPO_PUBKEY" ]]   &&  echo "NO PuBKEY ;CANNOT RUN"
[[ -z "$GIT_REPO_PUBKEY" ]]   &&  exit 1
[[ -z "$GIT_REPO_SYNC" ]]     &&  echo "NO REPO;CANNOT RUN"
[[ -z "$GIT_REPO_SYNC" ]]     &&  exit 1

[[ -z "$BACKUP_PATH" ]] && BACKUP_PATH=/tmp/backup
[[ -z "$BACKUP_PATH" ]] && BACKUP_PATH=/tmp/backup

mkdir ~/.ssh -p
#apk add --no-cache git bash openssh-client
[[ -z "$GITPATH" ]] && export  GITPATH=/srv/var
echo "$GIT_REPO_PUBKEY"|base64 -d > ~/.ssh/id_rsa.pub
echo "$GIT_REPO_KEY"   |base64 -d > ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa.pub ~/.ssh/id_rsa
## keyscan
oneline() { tr -d '\n' ; } ;

test -e $GITPATH || mkdir  -p "$GITPATH"
ssh-keyscan  gitlab.com >>  ~/.ssh/known_hosts 2>&1 | oneline
ssh-keyscan  github.com >>  ~/.ssh/known_hosts  2>&1 | oneline


myclone() {
export GIT_SSH_COMMAND='/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts'
echo git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts" $@ ;
git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts" $@  2>&1|grep -v -e "Warning: Permanently added the RSA host key for IP address "  ; } ;
mypush() {
export GIT_SSH_COMMAND='/usr/bin/ssh -i ~/.ssh/id_rsa -o UserKnownHostsFile=~/.ssh/known_hosts'
git config --global user.name "rootless" &>/dev/null
git config --global user.email "you@example.com"  &>/dev/null
git config user.name "rootless" &>/dev/null
git config user.email "you@example.com" &>/dev/null
git add -A  ;git commit -m $(date +%F_%T)"auto";
git push $@  2>&1|grep -v -e "Warning: Permanently added the RSA host key for IP address " -e "To "; } ;


#myclone ${GIT_REPO_SYNC}  ${GITPATH} || mkdir -p  ${GITPATH}
#DO NOT RUN WITHOUT STORAGE FROM GIT 
myclone ${GIT_REPO_SYNC}  ${GITPATH}
[[ -z "$GITPATH" ]] || ( cd "${GITPATH}" && git pull )
[[ -z "$GIT_REPO_BACKUP" ]] || myclone ${GIT_REPO_BACKUP} "$BACKUP_PATH" 
mkdir -p ${STORE_BOLT_PATH}
( sleep 10;  while (true);do ( cd ${GITPATH} ; pwd; mypush ) ; [[ -z "$GIT_REPO_BACKUP" ]] || ( cd "$BACKUP_PATH" ; pwd git add -A  ;git commit -m $(date +%F_%T)"auto" ;mypush )  ; [[ -z "$SLEEPINTER" ]]   &&  export SLEEPINTER=90;sleep $SLEEPINTER ; done ) &  

echo "PREP"
#cat /init.orig.sh
echo STARTING
bash /init.orig.sh /srv/remark42 server
#ls -lh1 /srv/remark42 /srv/remark42 server
