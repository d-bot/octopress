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
class Base

  def self.get
    puts "psuedo get"
    yield if block_given?
  end


  def self.test
    puts "test method"
    yield if block_given?
  end

  class << self

    # Makes the methods defined in the block and in the Modules given
    # in `extensions` available to the handlers and templates
    def helpers(&block)
      instance_eval(&block) if block_given?
      # 현재 class 의 scope 안에서 실행되므로 결국은 class << self (Base 의 singleton class) 안에서 인자로 넘>어온 블락은 evaluate 될줄 알았으나 아니었다.
      # 실상은 현재 스코프(singleton class) 의 객체로 현재 scope 를 evaluate 해서 instalce_eval을 써야 singleton method 로 인식이됨.
    end
  end

end

class MyTest < Base

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


