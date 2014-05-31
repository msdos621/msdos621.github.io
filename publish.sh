jekyll build --destination ../usbsnowcrash.github.io/
cd ../usbsnowcrash.github.io/
git add .
git commit -m "Commit triggered from publish script `date`"
git push origin master
cd ../blog
git add .
git commit -m "Commit triggered from publish script `date`"
git push origin blog
