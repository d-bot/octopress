---
layout: post
title: "Dynamic Method"
date: 2015-04-17 04:39:19 +0000
comments: true
categories: Ruby
---

일반적인 메소드 콜은 컴파일러가 해당되는 method 가 콜을 받는 객체에 매칭되는 method 가 있는지 검사하는데 이것을 static type checking 이라고 한다. 이러한 static type checking 때문에 tedious 코드를 많이 생산하게 되는데 dynamic languages(python, ruby) 등에는 해당 이슈가 없다.

코드를 줄이는 방법 2가지: Dynamic methods & Dynamic dispatch OR method_missing

## Dynamic Dispatch & Dynamic Methods

When you call a method, you're actually sending a message to an object.
```ruby
class Myclass
  def my_method(my_arg)
    my_arg * 2
  end
end

obj = MyClass.new
obj.send(:my_method, 3) # => 6
```

여기서 `send` 사용함으로 인해 호출하고 싶은 함수의 이름을 regular argument 로 쓰기 위함이다. 이렇게 함으로써 어떤 함수를 호출할지 결정을 프로그램 실행되고 있는 마지막까지 기다려 볼 수 있다. 이런 기법을 `Dynamic Dispatch` 라고 한다.

```ruby
require 'pry'

p = Pry.new
p.memory_size = 101
p.memory_size   # 101


```

```ruby
## A Pry object stores the interpreter's configuration into its own attributes, such as memory_size and quiet

def refresh(options={})
  defaults = {}
  attributes = [ :input, :output, :commands, :print, :quiet, :exception_handler, :hooks, :custom_completions, :prompt, :memory_size, :extra_sticky_locals ]

  attributes.each do |attribute|
    defaults[attribute] = Pry.send attribute  # Pry 클래스 메서드에 의해 정해진 값으로 defaults 를 초기화
  end
  # ...

  defaults.merge!(options).each do |key, value|
    send("#{key}=", value) if respond_to?("#{key}=")    # options에 정의된 값들에 대해 응답하면 해당 값을 defaults 에서 업데이트
  end

  true
end


```

참고로 send 는 해당 객체의 private 함수까지도 호출할 수 있으므로 privacy 이슈를 감안한다면 public_send 를 사용하는것이 좋다. 그렇지만 일반적으로 send 를 사용하는 이유는 private 함수까지도 접근하기 위함이므로 상황에 맞게 잘 사용하는것이 중요.


### Defining methods dynamically

메서드를 다이나믹하게 정의하는 이유는 method 이름을 런타임중 지정할수 있기 때문이다.

dynamic dispatch 와 dynamic method 를 이용한 refactoring.

```ruby
class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source  data_source
  end

  def self.define_compoment(name)
    define_method(name) do
      info = @data_source.send "get_#{name}_info", @id
      price = @data_source.send "get_#{name}_price", @id
      result = "#{name.capitalize}: #{info} ($#{price})"
      return "* #{result}" if price >= 100
      result
    end
  end

  define_component :mouse
  define_component :cpu
  define_component :keyboard
end
```

#### Sprinkling the code with introspection
```ruby
class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
    data_source.methods.grep(/^get_(.*)_info$/) { Computer.define_component $1 }
  end

  def self.define_compoment(name)
    define_method(name) do
      info = @data_source.send "get_#{name}_info", @id
      price = @data_source.send "get_#{name}_price", @id
      result = "#{name.capitalize}: #{info} ($#{price})"
      return "* #{result}" if price >= 100
      result
    end
  end

end
```

## Method_missing

method_missing 은 최상위 객체인 BasicObject 의 private method 임. 아래와 같이 send 를 이용해 테스트해보면 NoMethodError 예외를 발생시키는데 ruby의 method lookup 메카니즘으로 최상층까지 찾아 올라가서 못찾으면 BasicObject 의 method_missing 이 최상층에서 발생시키는 예외.
```ruby
2.2.0p0 :001 > BasicObject.send :method_missing, :test_method
NoMethodError: undefined method `test_method' for BasicObject:Class
  from (irb):1
  from /usr/local/bin/irb:11:in `<main>'
```

여기서 우리는 method_missing 을 override 함으로써 정의되지 않은 method call 들에 대해 대응(위임)한다.

```ruby
class Lawyer
  def method_missing(method, *args)
    puts "You called: #{method} (#{args.join(',')})"
    puts "(You also passed it a block)" if block_given?
  end
end

bob = Lawyer.new
bob.talk_simple('a', 'b') do
  # a block
end

# You called: talk_simple('a', 'b')
# (You also passed it a block)
```

method_missing 은 일종의 Dynamic Proxy 처럼 동작하여 없는 method 들이 호출되었을때 해당 method 를 갖고 있는 다른 객체로 받은 메세지(method)를 forwarding 해주는 기능을 하게 된다. (일종의 abstraction 을 가능하게 해줌)

```ruby

class Computer
  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
  end

  def method_missing(name)
    super if !@data_source.respond_to?("get_#{name}_info")  # 그런 method 가 없으면 최상위의 BasicObject 의 method_missing 을 호출해서 예외를 발생시킨다.
    info = @data_source.send("get_#{name}_info", @id)
    price = @data_source.send("get_#{name}_price", @id)

    result = "#{name.capitalize}: #{info} ($#{price})"
    return "* #{result}" if price >= 100
    result
  end
end

```










