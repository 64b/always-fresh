#!/usr/bin/bash

OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

if [ "${OS}" = "SunOS" ] ; then
  OS=Solaris
  ARCH=`uname -p`
  OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
elif [ "${OS}" = "AIX" ] ; then
  OSSTR="${OS} `oslevel` (`oslevel -r`)"
elif [ "${OS}" = "Linux" ] ; then
  KERNEL=`uname -r`
  if [ -f /etc/redhat-release ] ; then
    DIST=$(cat /etc/redhat-release | awk '{print $1}')
    if [ "${DIST}" = "CentOS" ]; then
      DIST="CentOS"
    elif [ "${DIST}" = "Mandriva" ]; then
      DIST="Mandriva"
      PSEUDONAME=`cat /etc/mandriva-release | sed s/.*\(// | sed s/\)//`
      REV=`cat /etc/mandriva-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ "${DIST}" = "Fedora" ]; then
      DIST="Fedora"
    else
      DIST="RedHat"
    fi

    PSEUDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
    REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
  elif [ -f /etc/SuSE-release ] ; then
    DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
    REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
  elif [ -f /etc/mandrake-release ] ; then
    DIST='Mandrake'
    PSEUDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
    REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
  elif [ -f /etc/debian_version ] ; then
    if [ -f /etc/mailcleaner/etc/mailcleaner/version.def ] ; then
      DIST="MailCleaner"
      REV=`cat /etc/mailcleaner/etc/mailcleaner/version.def`
    else
      DIST="Debian `cat /etc/debian_version`"
      REV=""
    fi
  fi

  if [ -f /etc/UnitedLinux-release ] ; then
    DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
  fi

  if [ -f /etc/slackware-version ] ; then
    DIST="Slackware";
    REV=$(cat /etc/slackware-version | awk '{print $2}')
  fi

  if [ -f /etc/lsb-release ] ; then
    LSB_DIST="`cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2`"
    LSB_REV="`cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2`"
    if [ "$LSB_DIST" != "" ] ; then
      DIST=$LSB_DIST
      REV=$LSB_REV
    fi
  fi

#  OSSTR="${OS} ${DIST} ${REV}(${PSEUDONAME} ${KERNEL} ${MACH})"
  OSSTR="${DIST} ${REV}"
elif [ "${OS}" = "Darwin" ] ; then
  if [ -f /usr/bin/sw_vers ] ; then
    OSSTR=`/usr/bin/sw_vers|grep -v Build|sed 's/^.*:.//'| tr "\n" ' '`
  fi
fi

echo ${OSSTR}

declare x=`docker ps --filter "name=nginx-proxy" --format "{{.ID}}" | tail -n 1`
if [[ $x ]]; then
  echo "Your port 443 is bound to an existing proxy container.  You must first remove any existing proxies to launch a new nginx-proxy...  run:"
  echo "-------- "
 echo docker rm -f `docker ps --filter "name=nginx-proxy" --format "{{.ID}}" | tail -n 1 `\
  "   && ./proxy.sh"
else
  echo "Instantiating a reverse proxy container bound to 80 and 443";
  docker run -d --name nginx-proxy --restart=always -p 80:80 -p 443:443 -v /etc/nginx/vhost.d \
   -v /usr/share/nginx/html \
   -v /etc/nginx/ssl:/etc/nginx/certs \
   -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy:alpine
  docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --env "DEFAULT_EMAIL=jane@janedoe.com" \
    jrcs/letsencrypt-nginx-proxy-companion
fi
