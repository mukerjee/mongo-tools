#!/bin/bash

set -x
set -v
set -e

mongotarget=$(if [ "${mongo_target}" ]; then echo "${mongo_target}"; else echo "${mongo_os}"; fi)
mongoversion=$(if [ "${mongo_version_always_use_latest}" ]; then echo "latest"; else echo "${mongo_version}"; fi)

python="python3"
if [ "Windows_NT" = "$OS" ]; then
  python="py.exe -3"
fi

dlurl=$($python ./binaryurl.py --edition=${mongo_edition} --target=$mongotarget --version=$mongoversion --arch=${mongo_arch:-x86_64})

version=$( perl -e 'my $url = shift; if ( $url =~ /-(\d+\.\d+\.\d+(?:-[^.]+)?)\.(?:tgz|zip)$/ ) { print q{r} . $1 } else { die "Cannot determine version from URL: $url\n" }' "$dlurl" )

DIR=$(mktemp -d)
cd $DIR

git clone \
    --depth 1 \
    --branch "$version" \
    https://github.com/mongodb/mongo.git

cd mongo

python3 buildscripts/scons.py install-jstestshell
