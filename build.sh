#! /usr/bin/env bash
set -uvx
set -e
cd "$(dirname "$0")"
cwd=`pwd`
ts=`date "+%Y.%m%d.%H%M.%S"`
version="${ts}"

#raco setup --fix-pkg-deps easyscript

sed -i -e "s/<Version>.*<\/Version>/<Version>${version}<\/Version>/g" version.xml

tag="EasyScript-v$version"
cd $cwd
git add .
git commit -m"$tag"
git tag -a "$tag" -m"$tag"
git push origin "$tag"
git push
git remote -v
