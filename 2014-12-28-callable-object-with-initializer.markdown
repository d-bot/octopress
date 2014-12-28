---
layout: post
title: "Callable object with initializer"
date: 2014-12-28 02:19:06 +0000
comments: true
categories: 
---

Found this while reading fluentd source codes

클래스 객체 생성시 생성자에 넘기는 파라미터에 따라 그에 맞게 객체 변수(@parser) 를 생성하고 해당 파라미터에 의해 생성된 객체 변수(@parser)의 call 함수를 이용해 실제 함수를 호출한다.

즉, 어떤 객체의 behavior (method) 를 정의하는데 behavior 의 이름을 항상 동일하지만 객체의 상태에 따라 다르게 behavior 를 하도록하고 싶을때 쓰는 기법.


```ruby
#!/usr/bin/env ruby

require 'time'

class TimeParser
  def initialize(time_format)
    @parser =
      if time_format
        Proc.new { |value| Time.strptime(value, time_format) }
      else
        Time.method(:parse)
      end
  end

  def parse(value)
    time = @parser.call(value).to_i
    return time
  end
end

format, value = nil, "2014-12-27 06:18:12"

m = TimeParser.new(format)
puts m.parse(value)

```