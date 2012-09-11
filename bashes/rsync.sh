#!/bin/bash

LOCK=/tmp/rsyncing
ROOT=/storage/mirror

[ -f $LOCK ] && exit 0

touch $LOCK

function count {
   find $ROOT/$1 | wc -l > $ROOT/.$1.count
   du -bs $ROOT/$1 | awk '{print $1}' > $ROOT/.$1.size
   date "+%Y-%m-%d %H:%M:%S %Z" > $ROOT/.$1.timestamp
}

function rsync {
   echo -1 > $ROOT/.$1.status
   /usr/bin/rsync -aq --delete-delay --timeout=900 $2 $ROOT/$1/ > /dev/null
   RESULT=$?
   echo $RESULT > $ROOT/.$1.status
   if [ $RESULT -eq 0 ]; then
      count $1
   fi
}

# centos
rsync centos mirrors.kernel.org::centos
unset RESULT

# epel
rsync epel mirrors.kernel.org::fedora-epel
if [ $RESULT -eq 0 ]; then
   /usr/bin/report_mirror > /dev/null
fi
unset RESULT

# repoforge
rsync repoforge apt.sw.be::pub/freshrpms/pub/dag/
unset RESULT

# ubuntu
rsync ubuntu mirrors.kernel.org::ubuntu
unset RESULT

# ubuntu-release
rsync ubuntu-releases mirrors.kernel.org::ubuntu-releases
unset RESULT

# archlinux
rsync archlinux mirrors.kernel.org::archlinux
unset RESULT

# gentoo
rsync gentoo mirrors.kernel.org::gentoo
unset RESULT

# gentoo-portage
rsync gentoo-portage mirrors.kernel.org::gentoo-portage
unset RESULT

# cpan
rsync cpan mirrors.kernel.org::CPAN
unset RESULT

# pypi
echo -1 > $ROOT/.pypi.status
/usr/bin/pep381run -q $ROOT/pypi/ > /dev/null
RESULT=$?
echo $RESULT > $ROOT/.pypi.status
if [ $RESULT -eq 0 ]; then
   count $1
else
   /usr/bin/pep381checkfiles $ROOT/pypi/ > /dev/null
fi
unset RESULT

# apache
rsync apache rsync.apache.org::apache-dist
unset RESULT

# cygwin
rsync cygwin mirrors.kernel.org::sourceware/cygwin/
unset RESULT

# eclipse
rsync eclipse download.eclipse.org::eclipseMirror
unset RESULT

# putty
rsync putty rsync.chiark.greenend.org.uk::ftp/users/sgtatham/putty-website-mirror/
unset RESULT

rm -f $LOCK
