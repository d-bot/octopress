---
layout: post
title: "instance variable self vs at and accessors"
date: 2016-07-15 23:01:30 +0000
comments: true
categories: 
---

인스턴스 변수에 `@` 이 붙을때와 `self` 가 붙을때의 차이가 궁금해서 확인해봄.
--

`@` 가 `attr_*` 없이 선언되면 해당 변수는 객체 내부적으로만 접근 가능한 변수가 되고

```ruby
class Test

    def initialize
        @asdf = 1
        qwer = 2
    end

    def vision
        puts @asdf  # @ 없이 asdf 가 호출되면 에러남.
    end
end

a = Test.new
a.vision
```

`@` 가 `attr_*` 와 함께 선언되면 해당 변수는 `@` 없이 호출가능하다.

```ruby
class Test
  attr_reader :asdf

    def initialize
        @asdf = 1
        qwer = 2
    end

    def vision
        puts asdf   # @ 가 없이 asdf 변수가 호출되었음에 주목
    end
end

a = Test.new
a.visio
```


`self` 는 기본적으로 `attr_accessor` 없이는 선언이 불가능함(attr_reader 도 안됨). 일단 `attr_accessor` 와 함께 선언되면 내부적으로든 객체 외부에서든 접근이 가능하다.

```ruby
class Test

    attr_accessor :asdf

    def initialize
        self.asdf = 1
        qwer = 2
    end

    def vision
        puts asdf
    end

end

a = Test.new
```

결론은 `@` 를 적절한 `attr_*` 와 함께 사용하는게 적절히 변수에 대한 접근을 제한하면서 접근 레벨을 둘 수 있어 적당한 방법인것 같음.


