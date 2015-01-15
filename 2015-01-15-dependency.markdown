---
layout: post
title: "Dependency"
date: 2015-01-15 10:09:56 +0000
comments: true
categories: 
---

```ruby
class Gear
  #...
  #...
  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end
  #...
end
```

위에서 보듯이 Wheel 클래스가 변경되면 Gear 클래스도 같이 변경되어야 하는 의존성이 있다.

```ruby
def initialize(chainring, cog, wheel)
  @chainring = chainring
  @cog = cog
  @wheel = wheel
end

def gear_inches
  ratio * wheel.diameter
end
```
위의 코드는 Wheel 인스턴스를 Gear 클래스 밖에서 생성하기 때문에 Gear 와 Wheel 사이의 결합이 없어졌고 Gear 는 diameter 를 구현하고 있는 어떤 객체와도 동작한다. 이 기술을 의존성 주입(dependency injection) 이라고 한다. (함수 호출 == 메세지 전송)

<h4>의존성 격리시키기</h4>
불필요한 의존성을 모두 제거하면 가장 좋겠지만 아쉽게도 기술적으로는 가능해도 현실적으로는 어렵다. 그러므로 불필요한 의존성을 제거할 수 없는 경우라면 의존성을 클래스 안에서 격리시켜 놓아야 한다.

<h4>인스턴스 생성을 격리시키기</h4>
만약 Gear 에 Wheel 을 주입할 수 없다면 새로운 Wheel 인스턴스를 만드는 "과정"을 Gear 클래스 내부에 격리시켜 놓을 필요가 있다. 이는 의존성을 명시적으로 노출하려는 것이며 동시에 wheel 이 Gear 클래스 내부에 스며들지 않도록 하기 위한 조치다.

1st example (moving to initialize, 생성자 함수를 통해서 wheel 에 대한 의존성을 뚜렷하게 드러낸다.)
```ruby
class Gear

  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @wheel = Wheel.new(rim, tire)
  end

  def
    ratio * wheel.diameter
  end

end
```

2nd example (using wheel method, wheel 메서드를 호출하기 전까지는 Wheel 의 인스턴스가 만들어지지 않는다.)
```ruby
class Gear

  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def
    ratio * wheel.diameter
  end

  def wheel
    @wheel ||= Wheel.new(rim, tire)
  end

end
```

여기서 핵심은 여전히 서로에 대해 많은것을 알고 있긴 하지만 몇몇 의존성은 줄어들었고 Gear 가 Wheel 에 의존하고 있다는 사실을 뚜렷하게 표현할 수 있었고 재사용 또한 수월하도록 하였다.

<h4>외부로 전송하는 메세지중 위험한것들을 격리</h4>
```ruby

def gear_inches
  # 무시무시한 수학공식들
  foo = some_intermediate_result * wheel.diameter
  # 무시무시한 수학공식들
end

###
### To
###

def gear_inches
  # 무시무시한 수학공식들
  foo = some_intermediate_result * diameter
  # 무시무시한 수학공식들
end

def diameter
  wheel.diameter
end

```

wheel 이 구현하고 있는 diameter 메서드의 이름과 시그너처를 바꾸더라도 Gear 에게 미치는 영향은 이 작은 wrapper method 에 한정된다.
<h4>인자 갯수와 순서에 대한 의존성 제거</h4>
인자의 갯수와 순서또한 의존성을 만들어내므로 Hash 를 이용해서 해당 위험을 줄인다.

```ruby
class Gear

  attr_reader :chainring, :cog, :wheel

  def initialize(args)
    @chainring = args[:chainring]
    @cog = args[:cog]
    @wheel = args[:wheel]
  end

end

Gear.new(:chainring => 52, :wheel => Wheel.new(2, 1.5), :cog => 11).gear_inches
```

<h4>인자에 기본값 사용하기</h4>
위의 코드는 해시키가 없는경우 nil 을 할당할 수 없었는데 아래와 같이 해시의 fetch 함수를 이용해서 default 값을 지정함과 동시에 존재하지 않는 키값에 대해서 nil 을 할당할 수 있다.

```ruby
class Test
  def initialize(args)
    @chainring = args.fetch(:chainring, 40)
    @cog = args.fetch(:cog, 10)
    @wheel = args.fetch(:wheel, nil)
  end
end

args = {:chainring => 50, :cog => 19}
Test.new(args)

```

<h4>멀티파라미터 초기화 고립시키기</h4>
만약 우리가 접근할수 없는 외부 프레임워크의 initialize 가 정해진 순서의 인자들을 필요로 하는 경우 Wrapper 모듈을 통해서 의존성을 없앨 수 있다. (팩토리: 다른 객체를 만들기 위해 존재하는 객체)

```
module SomeFramework
  class Gear
    attr_reader :chainring, :cog, :wheel
    def initialize(chainring, cog, wheel)
      @chainring = chainring
      @cog = cog
      @wheel = wheel
    end
  end
end


# Factory
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(args[:chainring], args[:cog], args[:wheel])
  end
end

args = { :chainring => 42, :cog => 11, :wheel => Wheel.new(26.1.5) }
GearWrapper.gear(args).gear_inches
```

위에서 보듯이 GearWrapper 는 특정 클래스에 include 되기 위한게 아니다. GearWrapper 는 오로지 다른 클래스의 인스턴스를 생성하기 위해서만 존재한다. 객체지향 디자이너들은 이런 객체를 "팩토리" 라고 부른다.

<h4>의존성의 방향 관리 및 결정</h4>
모든 의존성은 방향이 있고 지금까지 Gear 클래스는 Wheel 이나 diameter 에 의존했다. 이러한 의존 방향 결정은 최대한 자기 저신보다 덜 변하는 클래스에 의존해야 한다. 즉, 1) 변경될 가능성이 얼마나 높은지 이해하고 2) 구체적인것과 추상적인 것을 인지해야한다.

Gear 에 Wheel 을 주입하고 Gear 가 diameter 라는 메서드에 반응(respond_to) 하는 "오리 타입"에 의존하도록 했을 때 우리는 별 생각없이 "인터페이스"를 정의한 것이다. 즉, 어떤 종류의 것들은 지름(diameter)을 가지고 있다는 생각을 "추상화한 것이 인터페이스이다.

==> Gear 는 "diameter 메시지에 반응하는 어떤 객체를 필요로 한다" 라는 추상적인 사실에 의존하고 있다.

이러한 추상화의 훌륭한 점은 일반적이고 안정적인 성질을 지닌다는 점이다. 추상화된 인터페이스는 인터페이스가 기반하고 있던 구체 클래스보다 변경될 일이 훨씬 적다. 그러므로 추상화된 결과에 의존하는 것은 매우 안전하다.

결론은 자기 자신보다 덜 변하는것들에 의존하라!


