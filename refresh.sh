#!/bin/bash

stack exec site rebuild
git add .
git commit -am "refreshed site from script"
git push
stack exec site watch
