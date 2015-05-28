---
layout: post
title: "Inheritance"
date: 2015-01-20 09:35:22 +0000
comments: true
categories: Ruby
---

### 상속 이해하기

기본적으로 상속이란 자동화된 메시지 전달 시스템이다. 고전적인 상속 관계는 하위 클래스를 만드는 것을 통해 정의된다. 메시지는 하위 클래스(subclass) 에서 상위 클래스(superclass)로 전달된다. 클래스의 위계관계가 공유되는 코드를 정의하는 것이다. (include 와 비슷하게 들리지만 상속은 추상 클래스를 이용한 기법이고, include 는 오리타입을 이용한 기법이다. 고전적 상속을 통한 메시지 전달은 클래스들 사이에서 이루어지는 작업이다. 오리 타입은 클래스들을 가로지르기 때문에 공통의 행동을 공유하기 위해 고전적 상속을 사용하지 않는다. 오리 타입은 루비의 모듈을 이용해서 코드를 공유한다)


상속에서 추상클래스를 만들때는 '모두 아래로 내리고 그 다음에 필요한 것만 위로 올리기' 전략이 리팩터링의 핵심이다. 상속을 구현하는 데 따르는 여러 어려움은 구체적인 것과 추상적인 것을 제대로 구분하지 못하는 데서 기인한다. 즉, 새로운 상속 관계를 만드는 리팩터링을 진행할 때 유념해야 하는 기본 원칙은, 구체적인 것을 내리기보다는 추상적인 것을 끌어올리는 방식을 취하라는 것이다.


#### 구체 Bicycle 클래스

```ruby
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args={})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    { tire_size: tire_size,
    chain: chain}.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  def post_initialize(argS)
    nil
  end

  def local_spares
    {}
  end

  def defalt_chain
    '10-speed'
  end

end
```

#### RoadBike 클래스

```ruby
class RoadBike < Bicycle
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color]
  end

  def local_spares
    { tape_color: tape_color }
  end

  def default_tire_size
    '23'
  end
end
```

#### MountainBike 클래스

```ruby
class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
  end

  def local_spares
    { rear_shock: rear_shock }
  end

  def default_tire_size
    '2.1'
  end

end
```

#### RecumbentBike 클래스

```ruby
class RecumbentBike < Bicycle
  attr_reader :flag

  def post_initialize(args)
    @flag = args[:flag]
  end

  def local_spares
    { flag: flag }
  end

  def default_chain
    "9-speed"
  end

  def default_tire_size
    '28'
  end

end

bent = RecumbentBike.new(flag: 'tall and orange')
bent.spares
# -> { :tire_size => "28",
#     :chain => "10-speed",
#     :flag => "tail and orange" }
```

### 요약

공통된 행동을 많이 공유하고 있지만 특정 관점에서만 다르고, 동시에 서로 연관된 타입들을 다루는 문제. 상속은 이런 문제를 해결해 준다. 공통된 코드를 고립시키고 공통의 알고리즘을 추상 클래스가 구현할 수 있도록 해준다. 동시에 하위 클래스가 자신만의 특수한 행동을 추가할 수 있는 여지도 남겨 놓는다.

추상화된 상위 클래스를 만드는 가장 좋은 방법은 구체적인 하위클래스의 코드를 위로 올리는 것이다. 최소한 세 개의 서로 다른 구체 클래스를 가지고 있다면 올바른 추상을 찾아내는 것은 어려운 일이 아니다.

추상화된 상위클래스는 템플릿 메서드 패턴을 이용해서 하위클래스가 자신의 특수한 내용을 추가할 수 있도록 돕는다. 그리고 혹 메서드를 통해 super를 전송하지 않고도 특수한 내용을 전달할 수 있도록 해준다. 훅 메서드를 이용하면 하위클래스가 추상화 알고리즘을 알지 못해도 자신의 특수한 내용을 추가할 수 있다. 하위 클래스가 super 를 전송하지 않아도 괜찮기 때문에, 상속 관계의 층위 사이의 결합이 느슨해진다.


