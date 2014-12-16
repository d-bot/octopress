---
layout: post
title: "Toggle Around"
date: 2014-12-16 10:13:13 +0000
comments: true
categories:
---
특정 설정값을 변경하여 실행하고 다시 해당 설정값을 되돌려 놓을때 유용한 기법

Toggle Around: in_environment method

```ruby
class Application
  attr_accessor :environment

  def initialize
    @environment = :development
  end

  def connect_to_database
    puts "Connecting to #{@environment} database..."
  end

  def handle_request
    puts "Handling #{@environment} request..."
  end

  def write_to_log
    puts "Writing to #{@environment} log file..."
  end

  def in_environment(env)
    old_env = @environment
    @environment = env
    yield
	# Make sure to catch exception from yield block and ensure to run the old value back to original
  rescue Exception => e
    puts e.message
  ensure
    @environment = old_env
    puts "Reset environment to #{@environment}"
  end
end

app.in_environment(:production) do
  app.connect_to_database
  app.handle_request
  app.write_to_log
end

puts

app.in_environment(:test) do
  app.connect_to_database
  app.handle_request
  app.write_to_log
end
```

Logger 클라스에서 흔히 로깅을 잠시 꺼놓을때도 사용
```ruby
def silently
	previous_logger = Configuration.logger
	Configuration.logger = nil		# 로깅 객체를 nil 로 만들어서 잠시 logging 을 off 시킴
	yield
ensure
	Configuration.logger = previous_logger
end
```

Money gem 역시 해당 기법을 currency 변경에 사용
```ruby
def with_default_currency(iso_code)
	original_default = Money.default_currency
	Money.default_currency = Money::Currency.new(iso_code)
	yield
ensure
	Money.default_currency = original_default
end
```


