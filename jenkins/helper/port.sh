#!/bin/bash
TIMEOUT=360 # in minutes
PORTDIR=/var/tmp/ports

mkdir -p $PORTDIR

if test "$1" == "--clean"; then
  shift

  while test $# -gt 0; do
    echo "freeing port $1"
    rm -f $PORTDIR/$1
    shift
  done

  exit
fi

port=9000
INCR=1

find $PORTDIR -type f -cmin +$TIMEOUT -exec rm "{}" ";"

if test "$1" == "--cluster" ; then
  shift
  portfiles=()
  while ! ((set -o noclobber ; date > $PORTDIR/$port && portfiles+=("$PORTDIR/$port") &&\
                               date > $PORTDIR/`expr $port + 1` && portfiles+=("$PORTDIR/`expr $port + 1`") &&\
                               date > $PORTDIR/`expr $port + 2` && portfiles+=("$PORTDIR/`expr $port + 2`") &&\
                               date > $PORTDIR/`expr $port + 3` && portfiles+=("$PORTDIR/`expr $port + 3`") &&\
                               date > $PORTDIR/`expr $port + 10` && portfiles+=("$PORTDIR/`expr $port + 10`") &&\
                               date > $PORTDIR/`expr $port + 11` && portfiles+=("$PORTDIR/`expr $port + 11`") &&\
                               date > $PORTDIR/`expr $port + 12` && portfiles+=("$PORTDIR/`expr $port + 12`") &&\
                               date > $PORTDIR/`expr $port + 13` && portfiles+=("$PORTDIR/`expr $port + 13`") &&\
                               date > $PORTDIR/`expr $port + 20` && portfiles+=("$PORTDIR/`expr $port + 20`") &&\
                               date > $PORTDIR/`expr $port + 21` && portfiles+=("$PORTDIR/`expr $port + 21`") &&\
                               date > $PORTDIR/`expr $port + 22` && portfiles+=("$PORTDIR/`expr $port + 22`") &&\
                               date > $PORTDIR/`expr $port + 23` && portfiles+=("$PORTDIR/`expr $port + 23`")) 2> /dev/null); do
    rm -f ${portfiles[@]}
    sleep 1
    port=`expr $port + $INCR`
  done

  echo "`expr $port + 1` `expr $port + 11` `expr $port + 21`" > ports

  echo "$port `expr $port + 1` `expr $port + 2` `expr $port + 3`\
        `expr $port + 10` `expr $port + 11` `expr $port + 12` `expr $port + 13`\
        `expr $port + 20` `expr $port + 21` `expr $port + 22` `expr $port + 23`"
else
  portfiles=()
  while ! ((set -o noclobber ; date > $PORTDIR/$port && portfiles+=("$PORTDIR/$port") &&\
                               date > $PORTDIR/`expr $port + 1` && portfiles+=("$PORTDIR/`expr $port + 1`")) 2> /dev/null); do
    rm -f ${portfiles[@]}
    sleep 1
    port=`expr $port + $INCR`
  done

  echo "`expr $port + 1`" > ports
  
  echo "$port `expr $port + 1`"
fi
