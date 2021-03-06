---
layout: post
title: "Rack Builder (Run, Use and Map)"
date: 2014-08-18 06:57:10 +0000
comments: true
categories: Ruby
---

[Rack::Builder](http://m.onkey.org/ruby-on-rack-2-the-builder)

[rackup](https://github.com/rack/rack/wiki/%28tutorial%29-rackup-howto)

[youtube](https://www.youtube.com/watch?v=iJ-ZsWtHTIg&spfreload=10)

## `rackup` == `Rack::Builder.new`

### What is Rack::Builder ?
Rack::Builder 는 다양한 Rack middleware 들과 application 들을 합쳐서 single entity/rack application 으로 변경(convert) 시키는 클래스이다.

Rack::Builder 객체는 stack (맨밑이 rack application 이고 그위로는 middleware 들이고 whole stack itself 역시 rack application) 과 유사하다.

아래의 infinity application 이라는 env 해쉬를 브라우저로 리턴해 주는 어플리케이션을 예로 들면,
```ruby
infinity = lambda { |env| ["200", {"Content-Type" => "text/html"}, env.inspect }
Rack::Handler::WEBrick.run infinity, :Port => 9292
```

### Rack::Builder#run
실제 infinity 객체를 Rack::Builder 객체로 변경(wrapping)하는 함수이다. (아래 코드 참고)

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

즉, rack config files(.ru) 들은 Rack::Builder 객체의 context 로 evaluate 된다. 즉, infinity 는 `rackup` 스크립트가 이해할수 있는 rack config file(.ru) 로 변경하면 아래와 같다. (`Rack::Builder.new` 가 받는 블락의 내용이 됨, `app = Rack::Builder.new { ... config ... }.to_app`)

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

## 결국 `rackup` 은 `Rack::Builder.new` 이다. Rack::Builder 객체로 만들어 SERVER 에 넘김.

```ruby
app = Rack::Builder.new { ... config ... }.to_app
```

### Auto-Selection of a Server

The specified server (from Handler.get) is used, or the first of below to match
* REQUEST_METHOD is in the process environment, use CGI
* Mongrel is installed, use it
* Otherwise, WEBrick

### Automatic Middleware

`rackup` 은 지정된 환경(environemnt)에 따라 자동으로 몇개의 미들웨어를 사용한다. `-E` with `development` 가 디폴트 설정.
* development: CommonLogger, ShowExceptions, Lint
* deploymnet: CommonLogger
* none: none

