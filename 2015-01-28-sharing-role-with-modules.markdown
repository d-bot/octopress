---
layout: post
title: "Sharing Role with Modules"
date: 2015-01-28 09:00:24 +0000
comments: true
categories: 
---

특정 문제를 해결하기 위해서 별로 연관이 없는 객체들이 공통의 행동을 공유하게 만든다. 이런 공통의 행동은 클래스와 아무런 상관이 없다. 이 행동은 객체가 수행하는 역할이다.

오리 타입 발견하기: `find . -type f |xargs grep -E "^\s*def |sort|uniq -c |sort -k 1nr"`

```ruby
class Schedule
  def scheduled?(schedulable, start_date, end_date)
    puts "This #{schedulable.class} " + "is not scheduled\n" +
          " between #{start_date} and #{end_date}"
    false
  end
end
```

```ruby

module Schedulable
  attr_writer :schedule

  def schedule
    @schedule ||= ::Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date) # self 를 넘겨야 Schedule 클래스에서 schedulable.class 값이 확인된다.
  end

  def lead_days
    0
  end
end


class Bicycle
  attr_reader :schedule, :size, :chain, :tire_size

  include Schedulable

  def lead_days
    1
  end

=begin
  def initialize(args={})
    @schedule = args[:schedule] || Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  def lead_days
    1
  end
=end

end

require 'date'
starting = Date.parse("2015/09/04")
ending = Date.parse("2015/09/10")

b = Bicycle.new
b.schedulable?(starting, ending)
# 이 자전거는 2015-09-03 과 2015-09-10 사이에 사용할 수 있다.
# => true
```

이렇게 메시지의 패턴은 Bicycle에게 schedulable?을 전송하는 것으로부터 Schedulable 모듈에게 schedulable? 을 전송하는 것으로 바뀌었다. 아래 예시는 Vehicle 과 Mechanic 에 Schedulable 모듈을 include  하여 schedulable? 메시지에 반응할 수 있도록 변경한 것이다.

```ruby
class Vehicle
  include Schedulable

  def lead_days
    3
  end
end

class Mechanic
  include Schedulable

  def lead_days
    5
  end
end
```

