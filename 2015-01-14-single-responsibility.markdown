---
layout: post
title: "Single Responsibility"
date: 2015-01-14 09:17:53 +0000
comments: true
categories: 
---

객체지향 시스템의 근간을 이루는 것은 메세지(message)이지만 가장 눈에 띄는 구조는 클래스이다. 즉, 하나의 책임만 지는 클래스를 만들어야함.

<h4>클래스에게 하나의 책임만 있는지 알아보기 </h4>
- Gear씨, 당신의 기어비는 무엇인가요? (o)
- Gear씨, 당신의 기어 인치는 무엇인가요? (애매)
- Gear씨, 당신의 타이어 높이는 무엇인가요? (x)

클래스의 책임을 한문장으로 만들어 보는것. 만약, '그리고', '또는' 같은 단어를 사용한다면 이 클래스는 하나 이상의 책임을 가지고 있을 가능성이 높다.

<h4>데이터(data)가 아니라 행동(behavior) 에 기반한 코드를 작성</h4>
행동은 메서드 속에 담겨 있고 메세지를 보내는 행위를 통해 실행된다. 그리고 객체는 행동과 함께 데이터를 갖으며, 데이터는 객체의 인스턴스 변수 속에 있는고 그 형태는 간단한 문자열부터 복잡한 해시까지, 매우 다양할 수 있다.

인스턴스 변수 숨기기: 아래의 ratio 메서드처럼, 변수를 직접 참조하기보다는 언제나 액세서 메서드를 통해 변수에 접근하는것이 좋다.
```ruby
class Gear

  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring = chainring
    @cog = cog
  end

  def ratio
    chainring / cog.to_f
  end
end

# attr_reader 를 통해 아래 메서드가 구현됨
#def cog
#  @cog
#end
```

이제 cog 가 무엇인지 아는것은 cog method 뿐이다. cog는 메시지 전송(message send)의 결과가 되었다. 이 cog 메서드를 구현함으로써 cog는 여러곳에서 참조하고 있는 데이터(data)에서 '단 한번만 정의된 행동(behavior)' 으로 바뀌었다. (만약 @cog 변수를 열 군데에서 참조하고 있고 어느 순간 그 내용을 바꿔야 한다면, 코드의 여러 부분을 수정해야한다 그래서 이렇게 래퍼 메서드로 감싸는것이 현명하다.)

이렇게 데이터 구조를 감싸는데 Struct 클래스가 유용하다. Struct 로 객체를 생성함으로서 그안의 객체 데이터를 접근하는것에서 메시지를 전송하는것으로 변경이 가능해진다.

<h4>메서드에서 추가 책임 뽑아내기</h4>
```
def diameters
  wheels.collect do |wheel|
    wheel.rim + (wheel.tire * 2)
  end
end

##
## => 개별 객체에 행해지는 액션과 객체들을 iteration 하는 활동을 분리
##

def diameters
  wheels.collect { |wheel| diameter(wheel) }
end

def diameter(wheel)
  wheel.rim + (wheel.tire * 2)
end

```

