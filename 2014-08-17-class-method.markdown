---
layout: post
title: "Class Method"
date: 2014-08-17 10:20:56 +0000
comments: true
categories: 
---

In order to save configurations, class valuables and methods should be used. [Also see #4](http://yehudakatz.com/2009/08/24/my-10-favorite-things-about-the-ruby-language/)

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
