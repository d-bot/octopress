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

`@` 가 `attr_*` 와 함께 선언되면 해당 변수는 `@` 없이 접근하여 값을 가져오는게 가능하다. 하지만, 새로운 값을 assign 하는것은 에러가 난다 (즉, read-only 이다. 이건 내생각에 아마 인스턴스 변수가 해당 클래스를 호출하는 다른 모듈의 네임스페이스 안에서 이름이 충돌나지 않게 하기 위함이 아닐까).  값을 할당하려면 @ 를 항상 붙여서 assignment 를 한다.

```ruby
class Test
  attr_reader :asdf, :zxcv

  def initialize
      @asdf = 1
      @zxcv = nil
  end

  def vision
    puts asdf   # @ 가 없이 asdf 변수가 호출되었음에 주목
    puts zxcv    # 아무것도 출력 안됨. 왜냐하면 @zxcv 는 nil 이니까
    @zxcv = 10   # @zxcv 에 10 을 할당. @ 없이는 새로운 값을 할당할 수 없음.
  end

  def final
    puts @zxcv.class.name
    puts zxcv.class.name
    puts zxcv
  end
end

a = Test.new
a.vision
a.final

# $ ruby test.rb
1

Fixnum
Fixnum
10
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


