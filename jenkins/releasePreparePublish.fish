#!/usr/bin/env fish
if test (count $argv) -lt 1
  echo usage: (status current-filename) "<destination>"
  exit 1
end

if test -z "$RELEASE_TAG"
  echo "RELEASE_TAG required"
  exit 1
end

umask 000

source jenkins/helper.jenkins.fish ; prepareOskar

lockDirectory ; updateOskar ; clearResults ; cleanWorkspace

switchBranches "$RELEASE_TAG" "$RELEASE_TAG" true
and findArangoDBVersion

set -xg SRC $argv[1]/stage1/$RELEASE_TAG
set -xg DST $argv[1]/stage2/$ARANGODB_PACKAGES

and set -g SP_PACKAGES $DST
and set -g SP_SNIPPETS_CO $DST/snippets/Community
and set -g SP_SNIPPETS_EN $DST/snippets/Enterprise
and set -g SP_SOURCE $DST/source
and set -g WS_PACKAGES $SRC/release/packages
and set -g WS_SNIPPETS $SRC/release/snippets
and set -g WS_SOURCE $SRC/release/source

and echo "checking packages source directory '$WS_PACKAGES'"
and test -d $WS_PACKAGES
and echo "checking snippets source directory '$WS_SNIPPETS'"
and test -d $WS_SNIPPETS
and echo "checking source source directory '$WS_SOURCE'"
and test -d $WS_SOURCE
and echo "creating destination directory '$DST'"
and mkdir -p $DST
and echo "creating community snippets destination directory '$SP_SNIPPETS_CO'"
and mkdir -p $SP_SNIPPETS_CO
and echo "creating enterprise snippets destination directory '$SP_SNIPPETS_EN'"
and mkdir -p $SP_SNIPPETS_EN
and echo "creating source destination directory '$SP_SOURCE'"
and mkdir -p $SP_SOURCE

and echo "========== COPYING PACKAGES =========="
and tar -C $SRC/release -c -f - packages | tar -C $DST -x -v -f -
and echo "========== COPYING SOURCE =========="
and tar -C $WS_SOURCE -c -f - . | tar -C $SP_SOURCE -x -v -f -
and echo "========== COPYING SNIPPETS =========="
and cp -v $WS_SNIPPETS/download-arangodb3-debian.html   $SP_SNIPPETS_CO/download-debian.html
and cp -v $WS_SNIPPETS/download-arangodb3-debian.html   $SP_SNIPPETS_CO/download-ubuntu.html
and cp -v $WS_SNIPPETS/download-arangodb3-rpm.html      $SP_SNIPPETS_CO/download-centos.html
and cp -v $WS_SNIPPETS/download-arangodb3-rpm.html      $SP_SNIPPETS_CO/download-fedora.html
and cp -v $WS_SNIPPETS/download-arangodb3-suse.html     $SP_SNIPPETS_CO/download-opensuse.html
and cp -v $WS_SNIPPETS/download-arangodb3-rpm.html      $SP_SNIPPETS_CO/download-redhat.html
and cp -v $WS_SNIPPETS/download-arangodb3-suse.html     $SP_SNIPPETS_CO/download-sle.html
and cp -v $WS_SNIPPETS/download-arangodb3-linux.html    $SP_SNIPPETS_CO/download-linux-general.html
and cp -v $WS_SNIPPETS/download-arangodb3-macosx.html   $SP_SNIPPETS_CO/download-macosx.html
and cp -v $WS_SNIPPETS/download-docker-community.html   $SP_SNIPPETS_CO/download-docker.html
and cp -v $WS_SNIPPETS/download-k8s-community.html      $SP_SNIPPETS_CO/download-k8s.html
and cp -v $WS_SNIPPETS/download-source.html             $SP_SNIPPETS_CO/download-source.html

and cp -v $WS_SNIPPETS/download-arangodb3e-debian.html  $SP_SNIPPETS_EN/download-debian.html
and cp -v $WS_SNIPPETS/download-arangodb3e-debian.html  $SP_SNIPPETS_EN/download-ubuntu.html
and cp -v $WS_SNIPPETS/download-arangodb3e-rpm.html     $SP_SNIPPETS_EN/download-centos.html
and cp -v $WS_SNIPPETS/download-arangodb3e-rpm.html     $SP_SNIPPETS_EN/download-fedora.html
and cp -v $WS_SNIPPETS/download-arangodb3e-suse.html    $SP_SNIPPETS_EN/download-opensuse.html
and cp -v $WS_SNIPPETS/download-arangodb3e-rpm.html     $SP_SNIPPETS_EN/download-redhat.html
and cp -v $WS_SNIPPETS/download-arangodb3e-suse.html    $SP_SNIPPETS_EN/download-sle.html
and cp -v $WS_SNIPPETS/download-arangodb3e-linux.html   $SP_SNIPPETS_EN/download-linux-general.html
and cp -v $WS_SNIPPETS/download-arangodb3e-macosx.html  $SP_SNIPPETS_EN/download-macosx.html
and cp -v $WS_SNIPPETS/download-docker-enterprise.html  $SP_SNIPPETS_EN/download-docker.html
and cp -v $WS_SNIPPETS/download-k8s-enterprise.html     $SP_SNIPPETS_EN/download-k8s.html

and recode UTF8..latin1 < $WS_SNIPPETS/download-windows-enterprise.html > $SP_SNIPPETS_EN/download-windows.html
and recode UTF8..latin1 < $WS_SNIPPETS/download-windows-community.html  > $SP_SNIPPETS_CO/download-windows.html

set -l s $status
cd "$HOME/$NODE_NAME/$OSKAR" ; unlockDirectory
exit $s
