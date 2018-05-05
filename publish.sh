#!/usr/bin/env bash

echo cleaning
stack exec theblog clean > /dev/null 2>&1

echo building
stack exec theblog build > /dev/null 2>&1

echo deploying
rm -rf _deploy/*
cp -r _site/* _deploy/

echo publishing
cd _deploy
dt=$( date )
git add --all .
git commit -a -m "$dt"
git push
