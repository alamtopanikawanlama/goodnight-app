
set -e
bundle check || bundle install
if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

bundle exec rake db:migrate || bundle exec rake db:setup
exec "$@"