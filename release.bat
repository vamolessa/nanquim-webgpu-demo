@echo off

call build.bat

git add --all
git commit -m "update"
git push
