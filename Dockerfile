# Dockerfile
FROM ruby:3.2

WORKDIR /app

COPY . .

RUN gem install bundler && bundle install || true

CMD ["ruby", "/app/handle_incoming.rb"]
