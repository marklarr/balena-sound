cd /usr/src

bundle config build.eventmachine --with-cppflags=-I/usr/include/openssl

bundle install && APP_ENV=production ruby app.rb
