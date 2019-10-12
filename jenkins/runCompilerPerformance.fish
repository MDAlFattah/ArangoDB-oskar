#!/usr/bin/env fish
source jenkins/helper/jenkins.fish

set -xg date (date +%Y%m%d)
set -xg datetime (date +%Y%m%d%H%M)
set -xg dest /mnt/buildfiles/performance/Linux/Compiler/RAW

cleanPrepareLockUpdateClear
and enterprise
and switchBranches $ARANGODB_BRANCH $ENTERPRISE_BRANCH true
and if echo "$ARANGODB_BRANCH" | grep -q "^v"
  pushd work/ArangoDB
  set -xg date (git log -1 --format=%aI  | tr -d -- '-:T+' | cut -b 1-8)
  set -xg datetime (git log -1 --format=%aI  | tr -d -- '-:T+' | cut -b 1-12)
  echo "==== date $datetime ===="
  popd
end
and pingDetails
and ccacheOff
and showConfig
and buildStaticArangoDB

set -l s $status
set -l resultname (echo $ARANGODB_BRANCH | tr "/" "_")
set -l filename $dest/results-$resultname-$datetime.csv

echo "storing results in $resultname"
awk -F, "{print \"$ARANGODB_BRANCH,$date,\" \$1 \",\" \$2}" \
  < work/buildTimes.csv \
  > $filename

cd "$HOME/$NODE_NAME/$OSKAR" ; moveResultsToWorkspace ; unlockDirectory 
exit $s
