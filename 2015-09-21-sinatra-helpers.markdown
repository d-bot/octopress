---
layout: post
title: "Sinatra Helpers"
date: 2015-09-21 07:25:59 +0000
comments: true
categories: 
---

[use sinatra helpers 4 javascript](http://www.sitepoint.com/using-sinatra-helpers-to-clean-up-your-code/)

[sinatra classic vs modular](http://blog.carbonfive.com/2013/06/24/sinatra-best-practices-part-one/)


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
    self.inside_helper
  end

end
```


