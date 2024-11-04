FROM ruby:2.7.8

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN gem install -N bundler -v 2.4.22 && bundle install --jobs 8

RUN rake db:setup

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
