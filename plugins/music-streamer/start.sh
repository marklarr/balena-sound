cd /usr/src

bundle config build.eventmachine --with-cppflags=-I/usr/include/openssl

bundle install && ruby app.rb
