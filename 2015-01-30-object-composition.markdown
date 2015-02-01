---
layout: post
title: "Object Composition"
date: 2015-01-30 07:41:20 +0000
comments: true
categories: 
---

### Composition

조합에서 좀 더 큰 객체는 자신의 부분들을 가지고 있다. 즉 가지고 있는(has-a) 관계를 맺는다. 자전거는 부품을 가지고 있다. 조합의 정의에서 도출할 수 있는 또 하나의 관점은, 자전거가 부품들을 가지고 있을 뿐 아니라 인터페이스를 통해 각 부품들과 소통한다는 점이다. 부분이란 곧 역할이며 자전거는 주어진 역할을 수행하는 어떤 객체와도 협업할 수 있다.

{% img left /images/composition.png %}
위의 그림에서 마름모는 조합을 의미하고 실선 오른쪽의 숫자는 조합된 객체의 수를 의미한다. `1..* 은 여러개의 Part를 갖는것을 뜻한다.`

### Parts 를 배열과 비슷하게 만들기

```ruby
class Parts < Array
  def spares
    select { |part| part.need_spare }
  end
end
```

위와 같이 Array 를 상속받아서 Parts 를 배열처럼 만들 수 있지만 Array 클래스의 + 메서드는 Parts 객체를 리턴하지 않고 Array 객체를 리턴하게 되기 때문에 문제가 될 수 있다. 그래서 아래와 같이 구현하는게 바람직하다.

```ruby
require 'forwardable'
class Parts
  extend Forwardable

  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select { |part| part.needs_spare }
  end
end
```

### 공장 만들기

다른 객체를 생산하는 객체를 팩도리라 부른다.

```ruby
road_config = [
  ['chain', '10-speed'],
  ['tire_size', '23'],
  ['tape_color', 'red'],
]

mountain_config = [
  ['chain', '10-speed'],
  ['tire_size', '2.1'],
  ['front_shock', 'Manitou', false],
  ['rear_shock', 'Fox'],

]

require 'ostruct'
module PartsFactory

  def self.build(config, part_class = Part, parts_class = Parts)
    parts_class.new(config.collect { |part_config| create_part(part_config)})
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0]
      description: part_config[1]
      needs_spare: part_config.fetch(2, true))})
    )
  end

end

road_parts = PartsFactory.build(road_config)
mountain_parts = PartsFactory.build(mountain_config)
```

위의 팩토리는 config 배열의 구조에 대해 알고 있다. config 의 구조에 대한 지식을 팩토리 안에 넣어두면 두 가지 결과를 낳는다. 첫째, config 가 매우 간결하게 표현될 수 있다. PartsFactory가 config의 내부 구조를 알고 있기 때문에, 해시가 아니라 배열의 형태로 config를 작성할 수 있다. 둘째, 한번 config를 배열로 관리하기 시작하면, 새로운 Parts를 만들 때는 언제나 팩토리를 사용해야 한다.

완성된 최종 코드는 아래와 같다.

```ruby
class Bicycle
  attr_reader :size, :parts

  def initialize(args={})
    @size = args[:size]
    @parts = args[:parts]
  end

  def spares
    parts.spares
  end
end

require 'forwardable'
class Parts
  extend Forwardable

  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    select { |part| part.needs_spare }
  end
end

require 'ostruct'
module PartsFactory

  def self.build(config, parts_class = Parts)
    parts_class.new(config.collect { |part_config| create_part(part_config)})
  end

  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true))
  end

end

road_config = [
  ['chain', '10-speed'],
  ['tire_size', '23'],
  ['tape_color', 'red'],
]

mountain_config = [
  ['chain', '10-speed'],
  ['tire_size', '2.1'],
  ['front_shock', 'Manitou', false],
  ['rear_shock', 'Fox'],

]


road_bike = Bicycle.new(
  size: 'L',
  parts: PartsFactory.build(road_config)
)

p road_bike.spares

# [#<OpenStruct name="chain", description="10-speed", needs_spare=true>, #<OpenStruct name="tire_size", description="23", needs_spare=true>, #<OpenStruct name="tape_color", description="red", needs_spare=true>]
```

### 집합: 새로운 종류의 조합

우리는 이미 위임이라는 개념을 알고 있다. 한 객체가 전달받은 메시지를 단순히 다른 객체에게 전달하는 것을 위힘이라고 한다. 위임은 의존성을 만들어 낸다. 메시지를 수신한 객체는 메시지를 인지해야하고 또한 이 메시지를 어디로 보내야 할지 알아야 한다.

조합은 종종 위임을 사용하는데 이때 사용하는 위임의 개념에는 몇 가지 함의가 더 있다. 조합된 객체는 잘 정의된 인터페이스를 통해 협업할 줄 아는 여러 부분들로 구성되어 있다.

조합은 가지고 있는 관계(has-a relationship)이다. 식사는 애피터이저를 가지고 있고, 대학은 학부를 가지고 있고, 자전거는 부품을 가지고 있다. 이런 부품들은 역할들(roles)이며 조합된 객체는 역할의 인터페이스에 의존적이다.

식사는 인터페이스를 통해 애피타이저와 소통하기 때문에 새로운 객체가 애피타이저 역할을 수행하고 싶다면 이 인터페이스만 구현하면 된다. 새로운 애피타이저가 자연스럽게 기존의 애피타이저를 대체하고 새로운 식사와 어울릴 수 있게 된다.

조합이라는 개념은 미묘하게 다른 두 가지 의미로 사용되기 때문에 조금 헷갈리기 쉽다. 위에서 제시한 정의는 조합을 넓은 의미로 정의한 것이다. 우리가 조합이라는 개념을 접하는 대부분의 경우에는 일반적으로 두 객체 사이의 가지고 있는 관계(has-a relationship)를 의미한다고 생각해도 좋다. 조금 더 정교하게 정의하면 조합이란, 포함된 객체가 포함하는 객체로부터 독립적으로 존재하지 못하는 방식으로 서로 가지고 있는 관계(has-a relationship) 를 맺고 있다는 뜻이다. 이런 엄밀한 정의를 따르자면, 식사가 애피타이저를 가지고 있을뿐 아ㅣㄴ라 식사를 끝낸 후에는 애피타이저 역시 사라져버린다는 것 역시 알 수 있다.

개념을 일반적으로 또는 엄밀하게 사용하면서 생겨나는 이 간극을 집합이라는 개념이 채워준다. 집합이란 포함된 객체가 독립적으로 존재할 수 있는 조합을 뜻한다. 대학은 학부를 가질 수 있고, 학부는 교수들을 가지고 있다. 우리의 애플리케이션이 여러 대학들을 관리하고 그 속에서 수천 명의 교수들이 있다면, 대학이 폐교되고 학부가 폐지되어도 교수들은 여전히 남아 있는 경우를 생각할 수 있다.

대학과 학부의 관계는 엄밀한 의미로 사용한 조합의 관계이고 학부와 교수의 관계는 집합의 관계이다. 학부를 폐지해도 교수들은 사라지지 않는다. 교수들은 스스로 존재할 수 있다.

조합과 집합을 정교하게 구분하는 것이 실제 코드를 작성하는데는 별로 도움이 안될 수 있다. 이제 이 두 개념을 모두 이해하고 있으니 이 두 관계를 모두 지칭하는데 조합이라는 개념을 사용하면 되고 필요할 때는 집합의 개념을 사용하면 된다.

### 조합의 이점

조합을 사용하면 명확한 책임과 명료한 인터페이스를 갖는 작은 객체를 여럿 만들게 되는 경향이 있다. 잘 조합된 객체는 여러 측면에서 매우 훌륭한 점수를 받을 수 있다.

작은 객체들은 하나의 책임만을 갖고 있고, 자신의 행동을 직접 명시하고 있다. 투명한 객체들이다. 수정사항이 발생했을 때 코드를 이해하기 쉽고 어떤 일이 벌어질지 예상하기도 좋다. 또한 조합된 객체가 상속구조로부터 독립적이라는 사실은 상속받은 행동이 적다는 것을 뜻한다. 결국 상속구조의 위쪽에서 발생한 변화로부터 덜 영향을 받는다.

조합된 객체는 자신의 부분들을 인터페이스를 통해 관리하기 때문에 한 부분을 새로 추가하는 것이 보다 쉽다. 주어진 인터페이스를 충실히 따르는 객체를 추가하기만 하면 된다. 조합된 객체의 관점에서 보자면 이미 있던 한 부분의 변형된 형태를 추가하는 것은 충분히 말이 되는, 적절한 것이며 자기 내부의 코드는 수정하지 않아도 된다.

조합에 관여하는 객체들은 본질적으로 그 크기가 작다. 구조적으로 독립되어 있고 잘 정의된 인터페이스를 가지고 있다. 이런 특징 덕분에 객체들을 자연스럽게 추가하고 제거할 수 있으며 객체들을 서로 대체할 수 있는 요소로 만들어준다. 결국 잘 조합된 객체는 새로운 환경에서도 손쉽게 사용할 수 있다.

조합이 이끌어 낼 수 있는 최고의 시나리오를 상상해 보면 애플리케이션이 작고, 추가하거나 제거하기 쉽고, 확장하기 용이한 객체들로 이루어지는 것이다. 이런 애플리케이션은 변화에 유연하게 대응할 수 있다.

### 조합의 비용

세상의 많은 일들이 그러하듯 조합이 제공하는 이점은 조합의 약점에도 영향을 준다. 조합된 객체는 여러부분들과 관계를 맺고 있다. 각각의 부분이 작고 쉽게 이해할 수 있더라도, 이 부분들이 모여 전체가 작동하는 방식은 훨씬 불명확할 수 있다. 개별 부분들은 충분히 투명하더라도 전체는 그렇지 않을 수 있다.

구조로부터의 독립성은 자동화된 메시지 전달을 포기하면서 얻은 것이다. 조합된 객체는 누구에게 어떤 메시지를 전달해야 할지 명확하게 알고 있어야 한다. 메시지 전달을 위해 동일한 코드가 여러 객체 속에 분산되어 존재하지만 조합은 이코드들을 한 곳에 모아줄 수 없다.
