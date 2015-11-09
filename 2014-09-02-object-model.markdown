---
layout: post
title: "Object Model"
date: 2014-09-02 04:06:19 +0000
comments: true
categories: Ruby
---

[Object Model](http://www.toptal.com/ruby/ruby-metaprogramming-cooler-than-it-sounds)

메타 프로그래밍 관점에서 class 키워드는 클래스 정의보다는 scope 지정 키워드로서 더 의미가 깊다.

```ruby
2.1.2 :001 > class MyClass
2.1.2 :002?>   def my_method
2.1.2 :003?>     @v = 1
2.1.2 :004?>   end
2.1.2 :005?> end
 => :my_method

2.1.2 :006 > obj = MyClass.new
 => #<MyClass:0x00000000cfa6e8>
2.1.2 :007 > obj.instance_variables			# my_method 를 호출하기 전까지는 obj 객체에 인스턴스 변수가 없다! (생성자 함수가 없으므로)
 => []
2.1.2 :008 > obj.my_method
 => 1
2.1.2 :009 > obj.instance_variables			# my_method 호출 이후에는 obj 객체에 인스턴스 변수가 있다!
 => [:@v]


2.1.2 :010 > obj.methods.grep /my/			# 해당 객체가 가지고 있는 함수들을 검색
 => [:my_method]

2.1.2 :011 > obj.methods.grep /^re/			# obj 객체는 이런 함수들을 어디서 가지고 오는가?? (아래를 참조)
 => [:remove_instance_variable, :respond_to?]


2.1.2 :012 > obj.class
 => MyClass


2.1.2 :013 > MyClass.class
 => Class


2.1.2 :014 > Class.class
 => Class


2.1.2 :015 > Object.class
 => Class

###
### 클래스 상속 체계
###

2.1.2 :016 > MyClass.superclass
 => Object


2.1.2 :017 > Object.superclass
 => BasicObject


2.1.2 :018 > BasicObject.superclass
 => nil


2.1.2 :019 > Class.superclass
 => Module


2.1.2 :020 > Module.superclass
 => Object

```

```
#MyClass < Object < BasicObject
#Class < Module < Object

#Inheritance Hierarchy


            BasicObject
                ^
                |
                |     superclass
                <----------------------
                |                     |
              Object               Module
                ^                     ^
                | superclass          | superclass
obj1 -----      |                     |
         |      |                     |
obj2 ------>  MyClass ------------> Class -----
         |               class        ^       |  (class)
obj3 -----                            |--------


```

### Method Lookup

```
2.1.2 :021 > MyClass.ancestors
 => [MyClass, Object, Kernel, BasicObject]

Ancestor chain/tree

            BasicObject
                 ^
                 |
                 |
               Kernel
                 ^
                 |
                 |
               Object
                 ^
                 |
                 |
   obj ------> MyClass

```

종합하면,

객체는 객체변수들과 해당 클래스를 가르키는 link 로 구성되어 있다. (함수들은 객체의 클래스에 존재한다)

클래스 자체도 Class 라는 클래스의 객체이며 class 의 이름은 constant (상수) 이다.

Class 는 Module 의 subclass 이며 Module 은 methods 들의 package 이다.

모든 클래스는 최상위에 BasicObject 가 있는 ancestor chain/tree 가 있다.

루비에서 함수를 호출하면 receiver 의 class 로 오른쪽으로 이동후 ancestor chain 을 타고 올라가면서 함수를 찾는다. (위의 ancestor chain 그림 참조)

클래스에서 모듈을 include 하면 그 모듈은 해당 클래스의 바로 위의 ancestor chain 에 들어가고 prepend 하면 해당 클래스의 바로 아래의 ancestor chain 으로 들어간다.

Refinements are like pieces of code patched right over a class and they override normal method lookup. On the other hand, a Refinement works in a limited area of the program: the lines of code between the call to using and the end of the file, or the end of the module definition.

