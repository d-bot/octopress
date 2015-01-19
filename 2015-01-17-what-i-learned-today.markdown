---
layout: post
title: "What I learned today"
date: 2015-01-17 07:31:12 +0000
comments: true
categories: 
---

```ruby
class Stack
  def initialize
    @store = Array.new
  end

  def pop
   @store.pop
  end

  def push(element)
    @store.push(element)
    self
  end

  def size
    @store.size
  end
end
```

위의 예제에서 push 에서는 self 를 리턴하고 pop 에서 리턴하지 않는것은 Ruby 의 Array 컨벤션상 pop 은 제거된 element 를 리턴하기 때문에 self 를 리턴하지 않아야 하고 push 는 컨벤션상 새로 변경된 리스트를 리턴하고 함수 chaining `ary.push(3).push(4).push(10)` 이 가능하게 하기 위함이다. 즉, 컨벤션을 고려하면서 method chaining 을 하려면 self 를 반드시 리턴하도록 한다. 아래 self 관련 예제 하나 더.

```ruby
class Interpreter
  def initialize(&block)
    instance_eval(&block)
  end

  def at(time)
    @time = time
    self
  end

  def when(date)
    @date = date
    self
  end

  def we(*people)
    @people = people
    self
  end

  def going(where)
    @where = where
    self
  end

  def output
    puts [@people.join(' and '), "are going", @where, @date, "at", @time].join(' ')
  end
end

Interpreter.new { at("7pm").when("tomorrow night").we("John", "Bob").going("drinking") }.output

#=> "John and Bob are going drinking tomorrow night at 7pm."
```
