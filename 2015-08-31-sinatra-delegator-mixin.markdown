---
layout: post
title: "Sinatra Delegator Mixin"
date: 2015-08-31 08:37:24 +0000
comments: true
categories: ruby
---

[Delegator](http://nicholasjohnson.com/ruby/blog/posts/delegating_with_extend/)<br>
[Sinatra Overview](http://neethack.com/2012/02/code-odyssey-sinatra/)

### 기본적으로 get put post 메소드들은 Base 클래스의 클래스 메서드로 정의되어 있음.



```ruby
module Sinatra
  class Base

    class << self
      def get
      end

      def post
      end

      def put
      end
    end

  end
end
```

실제로 get 메서드를 사용할때 global scope 에 정의된것처럼 보이지만, 사실 해당 함수들은 namespaced nicely in a class called `Application`. The global scope is delegating method calls to the `Application` class. `Application` 클래스는 아래와 같이 정의되어 있음.

```ruby
module Sinatra

  class Application < Base
    set :logging, Proc.new { ! test? }
    set :method_override, true
    set :run, Proc.new { ! test? }
    set :session_secret, Proc.new { super() unless development? }
    set :app_file, nil

    def self.register(*extensions, &block) #:nodoc:
      added_methods = extensions.map {|m| m.public_instance_methods }.flatten
      Delegator.delegate(*added_methods)
      super(*extensions, &block)
    end
  end

end
```

자 이제 그럼 Delegator 모듈을 보면, define_method 를 이용해서 많은 함수들을 정의하고 있다. 그리고 자세히 보면 정의된 모든 함수들은 정의한 함수 이름과 인자들을 `send` 콜의 인자로 하여 Delegator.target (`Application` class)으로 메세지를 보낸다.

```ruby
module Sinatra

  module Delegator

    def self.delegate(*methods)
      methods.each do |method_name|
        define_method(method_name) do |*args, &block|
          return super(*args, &block) if respond_to? method_name
          Delegator.target.send(method_name, *args, &block)
        end
        private method_name
      end
    end

    delegate :get, :patch, :put, :post, :delete, :head, :options, :link, :unlink,
             :template, :layout, :before, :after, :error, :not_found, :configure,
             :set, :mime_type, :enable, :disable, :use, :development?, :test?,
             :production?, :helpers, :settings, :register

    class << self
      attr_accessor :target
    end
    self.target = Application
  end

end

```

이제 시나트라는 글로벌 스코프에 이 함수들을 mixin 해서 해당 함수들이 어디서든 사용가능하게 해줘야 한다. 여기서 extend 를 사용하는데 extend 는 class에 함수를 추가하는게 아니라 object 에 함수를 추가할때 사용한다. (응??)

From global scope we can now simply do this:

```ruby
extend Sinatra::Delegator
```

This will extend the global scope object (pointed to by self) with the methods in the mixin. We can now call all of these methods on the global scope, and the delegator will forward them nicely onto the `Application` class.



