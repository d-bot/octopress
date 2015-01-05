---
layout: post
title: "ruby namespace"
date: 2014-12-29 17:51:05 +0000
comments: true
categories: Namespace
---

[참고](http://www.toptal.com/ruby/interview-questions)

namespace 의 기본적인 목적은 Array 같이 이미 존재하는 라이브러리들과 이름충돌이 나지 않도록 하기 위해 사용한다.

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
			# puts ::VAL  # In order to access TOP-LEVEL namespace
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
즉, global namespace 에 쉽게 접근하려면 class Foo::Bar 스타일을 사용해야함! (아니면 ::VAL 이렇게 접근하든가)

일반적으로 프로젝트안에서 namespace 구조를 디렉토리로 나타낸다. 그리고 class Foo:;Bar 로 정의하면 indent 를 하나 줄일 수 있는 장점도 있다?ㅋ


```ruby
module Foo
	VAL = "test"

	class Bar
		def initialize (value = VAL)
			...
			...
		end
	end
end
```
module 키워드는 lexical scope 를 생성하고 VAL 과 Bar 클래스는 같은 lexical scope 에 있기 Bar 는 VAL 상수에 접근이 가능하지만 아래와 같이 Bar 클래스가 다른 lexical scope 에 있으면 해당 상수에 접근할수 없다.

```ruby
module Foo
	VAL = "test"
end

class Foo::Bar
	def initialize (value = VAL)		## raises NameError
		...
		...
	end
end
```

위와같이 서로 다른 lexical scope 에 존재할때는 아래와 같이 해당 값에 접근해야한다.

```ruby
class Foo::Bar
	def initialize(value = Foo::VAL)
		...
		...
	end
end
```

Top-level access
```ruby
module Cluster
	class Array
		def initialize(n)
			@disks = Array.new(n) {|i| "disk#{i}"}		## Wrong Array! SystemStackError!
		end
	end
end
```

위의 코드는 top-level 의 Array 를 사용해야하는 Cluster::Array 클래스를 정의하지만 네임스페이스 문제로 에러가 난다. top-level 의 Array 에 접근하기 위해서는 아래와 같이 수정이 필요함.

```ruby
module Cluster
	class Array
		def initialize(n)
			@disks = ::Array.new(n) {|i| "disk#{i}"}
		end
	end
end
```











