---
layout: post
title: "Duck Typing"
date: 2015-01-19 09:24:51 +0000
comments: true
categories: 
---

### 오리 타입

오리 타입은 특정 클래스에 종속되지 않은 퍼블릭 인터페이스이다. 여러 클래스를 가로지르는 이런 인터페이스는 클래스에 대한 값비싼 의존을 메시지에 대한 부드러운 의존으로 대치시킨다. 그리고 애플리케이션을 굉장히 유연하게 만들어 준다.

```ruby
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each { |preparer|
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.fil_water_tank(vehicle)
      end
    }
  end
end

class TripCoordinator
  def buy_food(customers)
  end
end

class Driver
  def gas_up(vehicle)
  end

  def fill_water_tank(vehicle)
  end
end
```

### 오리 타입 찾기.

위와 같이 복잡한 의존성을 제거하기 위해서는 한 가지 중요한 사실을 이해해야 한다. Trip 의 prepare 메서드는 하나의 목적을 갖고 있기 때문에 prepare 의 인자 역시 이 목표를 이루기 위해 협업하는 객체라는 사실이다. 모든 인자는 똑같은 사명을 띠고 이곳에 모였다. 그리고 이들이 모인 이유와 이들의 클래스는 아무런 상관이 없다. 위의 예제에서 우리는 이미 "인자의 클래스가 무엇을 할줄 아는지" 이미!! 알기 때문에 자꾸 옆길로 샌다. 그러지 말고 'prepare가 무엇을 원하는지'에 집중하자. prepare 관점에서 생각하면 문제는 매우 명확하다. prepare 메서드는 여행을 준비(prepare)하고 싶어한다. 이 메서드의 인자는 여행 준비에 동참하기 위해 여기에 왔다. 인자가 주어진 작업을 제대로 할 줄 안다고 prepare 가 믿기만 하면 디자인은 훨씬 간단해질 것이다.

즉, Trip 의 prepare 메서드는 자시의 모든 인자들이 preparer이고 prepare_trip 을 이해할 수 있기를 바란다. 그런데 preparer 란 무엇일까? 현재 시점에서 이 객체는 구체적으로 존재하지 않는다. 추상적인 생각일 뿐이다. 이 객체의 퍼블릭 인터페이스는 아이디어로만 존재하고 디자인이 만들어낸 허구에 불과하다. 이런 추상화를 통해서 해당 퍼블릭 인터페이스를 wrapper 로 이용하여 인자의 클래스가 무엇을 할줄 아는지 감싸버리면서 해당 클래스를 정의해 버린다.

```ruby
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each { |preparer|
      prepare.prepare_trip(self)
    }
  end
end

class Mechanic
  def prepare_trip(trip)
    trip.bicycles.each { |bicycle|
      prepare_bicycle(bicycle)
    }
  end
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end
end

class Driver
  def prepare_trip(trip)
    vehicle = trip.vehicle
    gas_up(vehicle)
    fill_water_tank(vehicle)
  end
end
```

이렇게 함으로서 여행 준비가 복잡해져도 손쉽게 preparer 를 추가할 수 있다.

### 오리타입을 사용하는 코드 작성하기

오리 타입을 사용하려면 클래스를 가로지르는 인터페이스(across-class interface) 를 사용하면 좋은 지점을 찾아내는 "안목"부터 갖춰야 한다. 오리 타입을 구현하는 일은 상대적으로 쉽ㄴ다. 디자인 관점에서 문제가 되는 일은 오리 타입이 필요하다는 사실을 인지하고 인터페이스를 추상화시키는 부분이다.





