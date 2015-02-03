#!/bin/bash +x -e
source /usr/local/rvm/scripts/rvm
rvm use 1.9.3-p484

set -x # we're past RVM evil, so enable verbosity
bundle install

pwd
ls

curl -L https://gist.github.com/branan/b638a72a0d3523c6de38/raw/3c276aeabc3baba729421859123217dc1f58fc40/run_jasmine.coffe > run_jasmine.coffee
curl -L https://gist.github.com/branan/b638a72a0d3523c6de38/raw/1a17f577c9119f6256374cee74ed450fb8fc8fac/settings.yml > config/settings.yml
curl -L https://gist.github.com/branan/b638a72a0d3523c6de38/raw/0f14cee3efca848aa4b5d4aa98aef1854bfef000/config.yml > config/config.yml


PORT=$(($$ % 64510 + 1025))

bundle exec rackup -p $PORT &
  rack_pid=$!

until curl http://localhost:${{PORT}} >/dev/null 2>&1
do
  echo "Waiting for rackup to launch... ${{counter}} / 300" 
  if [[ $counter -lt 300 ]]; then
    counter=`expr $counter + 1`
    sleep 1
  else
    echo 'rackup failed to launch, and this whole section is a hack. Help me.'
    kill -9 $rack_pid
    exit 1
  fi
done

bundle exec phantomjs ./run_jasmine.coffee http://localhost:${{PORT}}/spec/runner.html
RESULT=$?

kill -9 $rack_pid

exit $RESULT
