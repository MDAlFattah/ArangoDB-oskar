#!/usr/bin/env fish

echo Directory (pwd)

function prepareOskar
  set -xg OSKAR oskar

  if test "$OSKAR_BRANCH" = ""
    set -xg OSKAR_BRANCH "master"
  end

  mkdir -p "$HOME/$NODE_NAME" ; cd "$HOME/$NODE_NAME"

  if not cd $OSKAR ^ /dev/null 
    git clone -b $OSKAR_BRANCH https://github.com/arangodb/oskar $OSKAR ; and cd $OSKAR
  else
    git fetch --tags ; and git fetch ; and git reset --hard ; and git checkout $OSKAR_BRANCH ; and git reset --hard origin/$OSKAR_BRANCH
  end
  and source helper.fish
  if test $status -ne 0 ; echo Did not find oskar and helpers ; exit 1 ; end

  set -l lockfile (pwd)/work/ArangoDB/.git/index.lock

  echo "Checking for lock file $lockfile"

  if test -f $lockfile
    echo "Warning: lock file $lockfile exist"

    sudo lsof -V $lockfile | fgrep -q "no file use"

    if test $status -eq 0
      echo "Removing stale lock file $lockfile"
      rm -f $lockfile
    end
  end

  mkdir -p work
  begin test -f $HOME/.gcs-credentials; and cp $HOME/.gcs-credentials work/.gcs-credentials; end; or true
end

function cleanBranchName
  echo $argv[1] | sed -e 's:[^-a-zA-Z0-9_/#.+]::g'
end

function cleanJenkinsParameter
  set -l cleaned (cleanBranchName $ARANGODB_BRANCH);   set -xg ARANGODB_BRANCH   $cleaned
  set -l cleaned (cleanBranchName $ENTERPRISE_BRANCH); set -xg ENTERPRISE_BRANCH $cleaned
  set -l cleaned (cleanBranchName $OSKAR_BRANCH);      set -xg OSKAR_BRANCH      $cleaned
  set -l cleaned (cleanBranchName $RELEASE_TAG);       set -xg RELEASE_TAG       $cleaned
end

function cleanPrepareLockUpdateClear
  cleanJenkinsParameter
  and prepareOskar
  and lockDirectory
  and updateOskar
  and clearResults
end

function cleanPrepareLockUpdateClear2
  cleanJenkinsParameter
  and prepareOskar
  and lockDirectory
  and updateOskarOnly
  and clearResults
end

function TT_init
  set -g TT_filename work/totalTimes.csv
  and set -g TT_date (date +%Y%m%d)
  and set -g TT_t1 (date +%s)
  and rm -f $TT_filename
end

function TT_setup
  set -g TT_t2 (date +%s)
  and echo "$TT_date,setup,"(expr $TT_t2 - $TT_t1) >> $TT_filename
end

function TT_compile
  set -g TT_t3 (date +%s)
  and if test -f work/buildTimes.csv
    awk -F, "{print \"$TT_date,\" \$2 \",\" \$3}" < work/buildTimes.csv >> $TT_filename
    and rm -f work/buildTimes.csv
  end
end

function TT_tests
  set -g TT_t4 (date +%s)
  and echo "$TT_date,tests,"(expr $TT_t4 - $TT_t3) >> $TT_filename
end
