set -ex

while ! mysqladmin ping -u $DB_USERNAME -p"$DB_PASSWORD" -h $DB_HOSTNAME -P $DB_PORT --silent; do
    echo "Waiting for mysql"
    sleep 1
done

composer config --global github-oauth.github.com $GITHUB_TOKEN

# temp debug
echo "PR BODY $CI_PR_BODY"

/code/pm4-tools/pm build-ci

mv /code/laravel-echo-server.json /code/pm4/

/code/pm4-tools/pm build-javascript-ci

DB_DATABASE=processmaker \
    /code/pm4-tools/pm install-ci

cd /code/pm4
vendor/bin/paratest -p 6
