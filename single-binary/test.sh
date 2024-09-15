export GIT_SSL_NO_VERIFY=1
git clone http://gitlab.127.0..0.1.nip.io/demo/demo-app.git
cd demo-app
echo "Hello" + $(date) >README.md
git add -A
git commit -m "updated "
git push
cd ..
