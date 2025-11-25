FROM ruby:3.4

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN chmod +x bin/sales_taxes

CMD ["ruby", "bin/sales_taxes"]
