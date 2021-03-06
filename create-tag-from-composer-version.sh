#!/bin/bash
set -e

file='composer.json'
echo -e "\ncreate tag"
version=$(php get-value-from-json-file.php $file version)
echo -e "$version"
tag_exists=$(git ls-remote origin refs/tags/"$version")
if [ -z "$tag_exists" ]; then
  git tag -a "$version" -m 'new version'
  git push --tags
  echo -e "done"
else
  echo -e "exists"
fi
