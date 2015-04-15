---
layout: post
title: "Class Method"
date: 2014-08-17 10:20:56 +0000
comments: true
categories: 
---

클래스 메서드는 해당 클래스로부터 생성되는 객체의 interface or responsibilities 에 속할 필요가 없는 행동들을 정의하는데 사용한다.

In order to save configurations, class valuables and methods should be used. [Also see #4](http://yehudakatz.com/2009/08/24/my-10-favorite-things-about-the-ruby-language/)

```ruby
module Macro
  class Base
    def self.has_many(name)
      puts "#{self} has many #{name}"

      define_method(name) do
        puts "#{name} has been defined"
      end
    end
  end
end

class Checklist < Macro::Base
  has_many :target
end

phase1 = Checklist.new
phase1.target


#dch [6:04:44] >  _posts git:(master) ✗ ruby test.rb
#Checklist has many target
#target has been defined
```

```ruby
class MyApp

  def self.test(msg)
    puts msg
  end

  test("class method")

end

MyApp.new

#$ ruby MyApp.rb
#class method
```

Another example
```ruby
class Post < ActiveRecord::Base
 validates_presence_of   :title
 belongs_to :user
end
```

클래스 메소드는 생성자 함수가 될수 있나? rackup 이 실행되는것을 보면 좀 이해가 되는듯

`run MyApp.new`	# MyApp 안에 정의된 get/post 함수들이 실행되서 결과값이 call 함수에 의해 호출되어야함.

그럼 class 함수를 생성자 함수처럼 쓰는 이유는 뭘까?

예를 좀 들면
File.open
Dir.glob

결국, Use it where it makes sense!
