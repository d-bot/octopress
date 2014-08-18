---
layout: post
title: "Rack Builder"
date: 2014-08-18 06:57:10 +0000
comments: true
categories: 
---

[참고](http://m.onkey.org/ruby-on-rack-2-the-builder)

결론부터 말하면 `rackup` 스크립트는 .ru 파일을 Rack::Builder 클래스의 객체로 변경(convert) 한다.

### What is Rack::Builder ?
: Rack::Builder 는 다양한 Rack middleware 들과 application 들을 합쳐서 single entity/rack application 으로 변경(convert) 시키는 클래스이다.

Rack::Builder 객체는 stack (가장 밑이 실제 rack application 이고 그위는 middleware 들이고 whole stack itself 역시 rack application) 과 유사하다.

아래와 같이 infinity application 이라는 env 해쉬를 브라우저로 리턴해 주는 어플리케이션이 있을때
```ruby
infinity = lambda { |env| ["200", {"Content-Type" => "text/html"}, env.inspect }
Rack::Handler::WEBrick.run infinity, :Port => 9292
```

### 여기서 3가지 중요한 Rack::Builder 의 instance methods

#### Rack::Builder#run
* Rack::Build 클래스로 wrapping 하는 실제 rack application 을 명시(specify) 한다.
* infinity 객체를 Rack::Builder 객체로 변경한다. (아래 코드 참고)

```ruby
infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }
builder = Rack::Builder.new
builder.run infinity		# infinity 객체를 Builder 객체로 변경(convert)

Rack::Handler::WEBrick.run builder, :Port => 9292
```

블락을 사용하여 infinity 객체를 Builder 객체로 변경하는것은 아래와 같다. (initialize 안에 instance_eval 이 블락을 받음`instance_eval(&block) if block_given?`)

```ruby
infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }
builder = Rack::Builder.new do
	run infinity
end

Rack::Handler::WEBrick.run builder, :Port => 9292
```

#### Rack::Builder#use

Rack::Builder#use 는 rack 미들웨어를 rack application stack 에 추가한다. 즉, Rack::CommonLogger 를 infinity 에 추가하려면 아래와 같이 추가한다.

```ruby
infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }
builder = Rack::Builder.new do
	use Rack::CommonLogger
	run infinity
end

Rack::Handler::WEBrick.run builder, :Port => 9292
```

#### Rack::Builder#map

Rack::Builder#map 는 rack application/middleware 들을 명시된 path 나 URI 아래의 모든 children paths 로 마운트(매핑)한다.

즉, /version/ 아래의 모든 path 에 대해서 infinity 0.1 를 보여주고 싶으면 아래와 같이 할수 있다.

```ruby
require 'rack'

infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }

builder = Rack::Builder.new do
	use Rack::CommonLogger

	map '/' do
		run infinity
	end

	map '/version' do
		run Proc.new {|env| [200, {"Content-Type" => "text/html"}, "infinity 0.1"] }
	end
end

Rack::Handler::WEBrick.run builder, :Port => 9292
```
map 은 builder 안에서 scope 를 encapsulate 하고 하나의 scope 는 하나의 Rack::Builder#run 함수를 가질 수 있으므로 `run infinity` 를 따로 map 함수로 넣는다.


#### Nesting map blocks

만약 last version 을 /version/last 로 보여주고 싶다면 `map '/version/last' do` 이런식으로 매핑할수 있겠지만 더 나은 방법은 map block 을 nesting 하는것이다.

```ruby
infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }

builder = Rack::Builder.new do
	use Rack::CommonLogger

	map '/' do
		run infinity
	end

	map '/version' do

		map '/' do
			run Proc.new {|env| [200, {"Content-Type" => "text/html"}, "infinity 0.1"] }
		end

		map '/last' do
			run Proc.new {|env| [200, {"Content-Type" => "text/html"}, "infinity beta"] }
		end

	end

end

Rack::Handler::WEBrick.run builder, :Port => 9292
```

#### Rack::Builder -> rackup

결국 rackup 은 config.ru 파일을 읽어서 Rack::Builder 객체로 변경한다.
```ruby
config_file = File.read(config.ru)
rack_application = eval("Rack::Builder.new { #{config_file} }")
```

그리고 `rack_application` 을 지정된 웹서버로 넘겨준다. (여기서는 WEBrick)

```ruby
Rack::Handler::WEBrick.run rack_application, options
```

결론은 rack config files(.ru) 들은 Rack::Builder 객체의 context 로 evaluate 된다. 즉, infinity 를 `rackup` 스크립트가 이해할수 있는 rack config file(.ru) 로 변경하면 아래와 같다.

```ruby
# infinity.ru

infinity = Proc.new { |env| [200, {"Content-Type" => "text/html"}, env.inspect }

use Rack::CommonLogger

map '/' do
	run infinity
end

map '/version' do
	map '/' do
		run Proc.new { |env| [200, {"Content-Type" => "text/html"}, "infinity 0.1"] }
	end

	map '/last' do
		run Proc.new { |env| [200, {"Content-Type" => "text/html"}, "infinity beta"] }
	end
end
```

그리고 실행!

```
$ rackup infinity.ru
```


