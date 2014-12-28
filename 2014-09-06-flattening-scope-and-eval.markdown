---
layout: post
title: "Flattening Scope & Eval"
date: 2014-09-06 18:29:39 +0000
comments: true
categories: 
---

###def, class and module

즉, 위의 키워드를 쓰지 않음으로해서 네임스페이스를 flatten 할수 있다. 프로그래밍을 하면서 bindings 를 pass 해야하는 어려운 상황이 발생하는데 위의 Scope Gate 를 이용해서 해결해야하는 상황이 많다.

```ruby
my_var = "Success"

MyClass = Class.new do
	"#{my_var} in the class definition"

	define_method :my_method do
		"#{my_var} in the method"
	end
end


```

###Eval

넘기는 블락이 지정된 스코프 안에서 실행된다. (instance_eval, class_eval, module_eval)

```ruby
def my_method
	x = 10
	return binding		# 이게 없으면 binding pass 가 안됨
end

eval("x = 50", my_method)
# => 50
```

instance_eval 을 이용해서 해당 블락을 객체의 scope 안에서 실행시키는 예제
```ruby
class MyClass
	def initialize
		@v = "Hello World"
	end
end

obj = MyClass.new
obj.instance_eval { puts @v }		# MyClass 의 스코프 안에서 블락이 실행된다.
```

