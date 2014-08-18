---
layout: post
title: "ruby namespace"
date: 2014-08-10 09:51:05 +0000
comments: true
categories: Namespace
---

[참고](http://www.toptal.com/ruby/interview-questions)

module 키워드는 class 와 def 키워드와 마찬가지로 자신의 모든 컨텐츠들을 위해서 새로운 lexical scope 를 생성한다.

그러므로 module Foo 는 VAL 의 값이 'Foo Local' 인 Foo 스코프를 생성한다. Foo 안에 Bar 클래스를 선언하였는데 해당 클래스는 부모 스코프(Foo)에 접근이 가능한 또다른 lexical scope (Foo::Bar 라는 이름의) 를 생성한다.


그러나 Foo::Bar 를 선언할때는 사실 새로운 또다른 Foo::Bar 라는 lexical scope 를 생성하는것이 된다. (졸라 헷갈리지 않는가!) 그러서 이 lexical scope 는 앞서 선언된 Foo 와는 전혀 관계없는 부모가 없는 완전 독립된 스코프라 Foo 의 스코프에는 전혀 접근할수 없다. 그러므로 가장 상위에 있는 VAL = 'Global' 에만 접근이 가능하여 Global 을 리턴한다.

```ruby
VAL = 'Global'

module Foo
  VAL = 'Foo Local'

  class Bar
    def value1
      puts VAL
    end
  end
end

class Foo::Bar
  def value2
    puts VAL
  end
end

Foo::Bar.new.value1		# Foo Local
Foo::Bar.new.value2		# Global

```


