FROM ruby:2.7.8

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir -p /app
WORKDIR /app

COPY . .
RUN gem install -N bundler && bundle install --jobs 8

RUN rake db:setup

EXPOSE 3000
CMD ["bundle", "exec", "puma"]
