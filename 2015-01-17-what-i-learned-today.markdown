---
layout: post
title: "What I learned today"
date: 2015-01-17 07:31:12 +0000
comments: true
categories: Ruby
---
#### 객체 디자인에서 가장 기본이 되는 것 중의 하나는 책임을 어디에 둘 지를 결정하는 것이다.

#### 배열 뺄셈?
```ruby
irb(main):001:0> cities  = %w/London Oslo Paris Amsterdam Berlin/
=> ["London", "Oslo", "Paris", "Amsterdam", "Berlin"]
irb(main):002:0> visited = %w/Berlin Oslo/
=> ["Berlin", "Oslo"]
irb(main):003:0> cities - visited
=> ["London", "Paris", "Amsterdam"]

$ TARGET="192.168.100.1 127.0.0.1 8.8.8.8" TEST="192.168.100.1" ruby -e 'puts (ENV["TARGET"].split - ENV["TEST"].split).join" "'
127.0.0.1 8.8.8.8

```

#### object.class? 가 리턴하는 클래스가 해당 object 와 같다면 연속적인 메서드 체이닝이 가능하다. (object.date.month 이런식으로)

#### if 를 사용하는것을 줄이고 def has_table?(obj) 와 같은 함수를 이용해서 조건을 만든다?? 잘못 이해한것 같고 if statement 들을 줄이기 위해서 메타 프로그래밍을 이용하는게 맛는듯.. (abstract 한 부분을 concrete 하게)

#### Symbol 은 기본적으로 string 과 크게 다를것 없지만 immutable 하기 때문에 meta programming 에서 많이 사용된다. 그리고 컨벤션상 심볼이 스트링에 비해 좀 더 의미있는 데이터를 표현해 줄 수 있다.

```ruby
[2] pry(main)> a = %/ djcjsksk
[2] pry(main)* jdjejsj djdjd eee
[2] pry(main)* 1111 q q q q /
=> " djcjsksk \njdjejsj djdjd eee\n1111 q q q q "
```

### Ctags
```
# Create tags
$ ctags -R . # put ctags file in .gitignore file

ctrl + ]: Find fuction definition
ctrl + t: back to cursor
```

### Loading/Requiring Code

`$LOAD_PATH` and `$:` are global variables that have library location information
```ruby
# File.expand_path: converts relative path to absolute path
# Arguments:
#  - 1st: relative path from current dir
#  - 2nd: the starting path (__FILE__)

lib = File.expand_path("../../lib", __FILE__)  # To obtain paths around a source file.
$:.unshift(lib)
# See http://www.sitepoint.com/loading-code-ruby/

# Or
require_relative('query/query')
```


### 유연하게 함수 인자받기
```ruby
2.2.0p0 :007 > def test(a, *b, **c)
2.2.0p0 :008?>   p a
2.2.0p0 :009?>   p b
2.2.0p0 :010?>   p c
2.2.0p0 :011?>   end
 => :test
2.2.0p0 :012 > test(1,2,3,4)
1
[2, 3, 4]
{}
 => {}
2.2.0p0 :014 > test(1,2,3,4,a: 4, b: 5)
1
[2, 3, 4]
{:a=>4, :b=>5}
 => {:a=>4, :b=>5}
```

### 환경 변수를 이용하기 (패스워드 사용으로 적합할듯)
```ruby
#!/usr/bin/env ruby

puts ENV['dchoi']


:dchoi-mac:~:$ export dchoi=TEST
:dchoi-mac:~:$ ruby env.rb
TEST

:dchoi-mac:~:$ dchoi=ASDF ruby env.rb
ASDF
:dchoi-mac:~:$ echo $dchoi
TEST

:dchoi-mac:~:$ dchoi=dylan ruby env.rb
dylan
:dchoi-mac:~:$ echo $dchoi
TEST
```

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
