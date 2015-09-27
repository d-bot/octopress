---
layout: post
title: "Sinatra Helpers"
date: 2015-09-21 07:25:59 +0000
comments: true
categories: 
---

[use sinatra helpers 4 javascript](http://www.sitepoint.com/using-sinatra-helpers-to-clean-up-your-code/)

[sinatra classic vs modular](http://blog.carbonfive.com/2013/06/24/sinatra-best-practices-part-one/)

[Application Scope](http://www.sinatrarb.com/intro#Request/Instance%20Scope)


### Request/Instance Scope

For every incoming request, a new instance of your application class is created, and all handler blocks run in that scope.

Here’s the [code](https://github.com/sinatra/sinatra/blob/v1.4.5/lib/sinatra/base.rb#L885-L887). When a Sinatra app receives a request it dups itself and passes the code to the newly created object, so each request is ultimately handled by a fresh instance.

### Sinatra instance is created with Sinatra:Application.prototype.dup

A new class is created for every request. However, this is not done by Rack. This is a feature of Sinatra. If you want to dig into the details: The instance is not actually created with Sinatra::Application.new but with Sinatra::Application.prototype.dup, see Sinatra::Base#call for the code.

### Request/Instance Scope

For every incoming request, a new instance of your application class is created, and all handler blocks(blocks in get/post/put) run in that scope. From within this scope you can access the request and session objects or call rendering methods like erb or haml. You can access the application scope from within the request scope via the settings helper:

```ruby
class MyApp < Sinatra::Base
  # Hey, I'm in the application scope!
  get '/define_route/:name' do
    # Request scope for '/define_route/:name'
    @value = 42

    settings.get("/#{params['name']}") do
      # Request scope for "/#{params['name']}"
      @value # => nil (not the same request)
    end

    "Route defined!"
  end
end
```


### methods defined in helpers are available in router and views

Also take a look how to register extensions


```ruby
require 'pry'

module Cinatra

  module Helpers
     # Methods available to routes, before/after filters, and views.
    def blah
      puts "blah~"
    end
  end

  class Base

    #include Rack::Utils
    include Helpers
    #include Templates

    def self.test
      puts "test method"
    end

    class << self
      def get
        puts "psuedo get"
        yield if block_given?
      end

      # Makes the methods defined in the block and in the Modules given
      # in `extensions` available to the handlers and templates
      def helpers(&block)
        puts self.class.name
        instance_eval(&block) if block_given?
        # 현재 class 의 scope 안에서 실행되므로 결국은 class << self (Base 의 singleton class) 안에서 인자로 넘어온 블락은 evaluate 될줄 알았으나 아니었다.
        # 실상은 현재 스코프(singleton class) 의 객체로 현재 scope 를 evaluate 해서 instalce_eval을 써야 singleton method 로 인식이됨.
        # class_eval is a method of the Module class, meaning that the receiver will be a module or a class. The block you pass to class_eval is evaluated in the context of that class. Defining a method with the standard def keyword within a class defines an instance method.
        binding.pry
      end
    end
  end # End of Base

end


class MyTest < Cinatra::Base

  helpers do

    def inside_helper
      """
      MyTest 객체의 인스턴스 함수로 정의가 되는구나!!!
      """
      puts "defined in Base singleton class"
    end

  end

  get do
    test
    inside_helper
  end

end
```


