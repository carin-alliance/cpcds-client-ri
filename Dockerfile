FROM ruby:2.7.6

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN gem install -N bundler && bundle install

RUN rake db:setup

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
