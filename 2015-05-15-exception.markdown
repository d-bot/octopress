---
layout: post
title: "Exception"
date: 2015-05-15 07:13:49 +0000
comments: true
categories: Ruby
---

#### 기본적으로 예외객체는 에러가 발생하는 조건에 대한 정보를 담고 있다. 대부분 이 정보는 사람이 읽을 수 있는 형태로 프로그램이 크래쉬 되기전에 터미널에 프린트된다. 물론 이 예외 객체는 인터셉트되어 rescue 절을 이용해서 처리할 수 있다.

* Certain type of exceptions 복구가능한 에러들이다. 즉, 현재 작업을 종료(abort) 하고 에러 메세지를 기록할 수 있다.
* More detailed exceptions 은 현재 프로그램의 상태를 변경하고 해당 작업을 재시도 할수 있게 한다. (network timeout 같은것들)

* 예외(에러)를 복구하기 위해서는 다양하게 발생할 수 있는 에러 컨디션들을 구분할수 있어야한다. 가장 흔한 방법으로는 raise 구문을 string 과 함께 사용하는 것이다. `raise "coffee machine low on water"`
* raise 구문은 다양하게사용 되는데 입력 인자가 하나만 스트링 형태로 들어오면 raise 는 해당 string (에러 메세지)을 이용하여 `RuntimeError` 를 생성하고 실제로는 아래와 같이 동작한다.
 ```ruby
 rase(RuntimeError, "coffee machine low on water")
 ```
* 위에서 보는것과 같이 첫번째 인자로 클래스 이름을 넣을수 있는데 이렇게 되면 해당 클래스의 객체로부터 exception object 가 생성되어 raise 된다.
* 두번째 인자(string) 은 그냥 에러 메세지로 출력될 용도로 사용되는데 해당 인자를 생략하게 되면 첫번째 인자 즉, 에러 클래스의 이름이 에러 메세지로 사용된다. (which is NOT very useful as far as error messages go: 에러가 발생해도 뭐 무슨말인지 알아먹기 힘들단 말이지)

* 해당 프로그램을 종료시킬 거라면 그냥 RuntimeError 를 발생시키는건 별 문제 없으나, 그외의 경우라면 이것은 좋은 생각이 아니다. RuntimeError 를 그냥 출력하는것은 그냥 "엇 뭔가 잘못됐네" 라고 말하는거랑 별다를바가 없다.

* 예외를 발생시켜야 하는 상황이라고 결정하면 새로운 예외 클래스를 생성하는것이 좋다. 예외는 타입정보에 기초해서 처리되므로 새로운 클래스를 생성하는게 예외를 구분하는 일반적인 방법이다.

* 새로운 예외를 생성할땐 아래의 3가지만 지켜주면 된다.
  1. 새로운 예외 클래스들은 반드시 standard exception classes 들중 하나로부터 상속받아야 한다.
      - 그외의 예외를 발생시키는것은 TypeError 을 초래한다. (discarding the exception you were trying to raise in the first place)
  2. The standard exception classs form a hierarchy with the Exception base class as the root. But Exception and several of its subclasses are considered low-level errors that will generally crash the program. The majority of the standard exception classes inherit instead from StandardError and you should follow suit.
  3. Error 라고 예외이름 마지막에 붙여준다. (common convention)

* StandardError 를 상속받는 또 다른 이유는 rescue 절의 기본적인 행동에서 찾아볼 수 있다. 아시다시피 rescue 절에서 예외를 다룰때 클래스 이름을 생략할수 있는데 그럴경우 rescue 는 any exception whose class (or superclass) is StandardError 를 가로챈다. (마찬가지로 rescue 를 statement modifier 로 사용할때도 동일하다.) - 그러니까 rescue 를 쓸때 클래스 이름을 생략하면 StandardError 뿌리에서 나온 모든 예외들은 알아서 자동으로 인터셉트된다는 말이네.

```ruby
class CoffeeTooWeakError < StandardError; end
raise(CoffeeTooWeakError, "coffee to water ratio too low")
```

* 예를 들어 특정 온도 사이에서만 제대로 동작하는 3D printer 가 있는데 해당 온도 범위를 벗어났을때 에러를 출력하는데, 에러가 발생했을 당시의 온도값을 해당 예외 객체에서 extract 할수 있어야 하고 프린터 화면에는 해당 온도값에 따라서 온도가 너무 추운지 너무 따뜻한지 출력해 주어야 한다.
```ruby
class TemperatureError < StandardError
  attr_reader(:temperature)

  def initialize(temperature)
    @temperature = temperature
    super("invalid temperature: #@temperature")
  end
end
```

별로 특별한것 없이 그냥 base 클래스를 super 함수를 호출하면서 초기화해서 해당 예외 클래스의 상위 클래스가 internal instance variable 들을 에러 메세지와 함께 셋업할수 있게 해준다.

```ruby
raise(TemperatureError.new(180))
```

위의 코드는 첫번째 인자로 클래스 이름 대신 객체가 들어갔는데 raise 구문은 알아서 처리를 해주는데 이런 경우 raise 는 `exception` 이라는 함수를 해당 객체로부터 호출한다. (`exception` 이라는 message 를 해당 객체로 보낸다.) exception 클래스와 exception 객체 둘다 각자 자기자신의 `exception` 함수가 있다. (courtesy of the `Exception class`).

클래스 메서드 버전은 그저 new 함수의 alias 이며 특별하지 않다 그래서 raise 에 클래스를 넘기는것은 실제로 해당 클래스의 new 함수를 호출하고(`exception` 함수를 통해서) 리턴되는 객체를 raise 한다.

그러나 인스턴스 메서드 버전은 약간 이상하다. 얼마나 많은 인자가 넘겨졌느냐에 따라 아래와 같다.
  - 1개: `exception` 함수가 인자 없이 호출되고 `exception` 함수는 아무것도 하지 않고 그냥 self 를 리턴한다. 즉, raise 의 첫번째 인자로 들어온 객체가 그냥 raised exception 이 되어 버린다.
  - exception 객체와 에러 메세지를 raise 에 파라미터로 넘기면 raise 는 `exception` 함수를 넘겨진 에러 메세지를 인자로하여 해당 객체로부터 호출한다. 이 경우 `exception` 함수는 해당 exception 객체의 복사본을 만들어서 에러 메세지를 넘겨받은 에러 메세지(2nd param)로 리셋하고 해당 exception 을 리턴한다. (리턴된 예외가 raise 된다.)

  커스텀 예외를 만들고 initialize 를 하는 경우라면 두번째 케이스를 잘 기억해 둬야한다. 만약 커스텀 에러 객체(initialize 에 에러메세지가 이미 정의된) 와 에러메세지를 파라미터로 raise 에 넘기면 커스텀 객체의 initialize 에 정의된 에러 메세지는 오버라이트 된다.initialize 함수를 통해 에러 메세지를 정의하는 경우라면 raise 에 항상 해당 커스텀 클래스의 객체만 넘기고 에러 메세지는 넘기지 않는다.

마지막으로 커스텀 예외를 여러개 생성하는 경우 hierarchy 구조로 생성하는것이 좋다. StandardError 부터 상속 -> 상속 -> 상속


#### Exception 을 잡을때 순서대로 rescue 되니까 잡고 싶은것 부터 먼저 rescue 로 잡고 나머지 broad 한 예외들을 마지막 resuce 절에 넣는다.

```ruby
begin
  task.perform
rescue ArgumentError, LocalJumpError,
      NoMethodError, ZeroDivisionError
      raise
rescue => e
  logger.error("task failed: #{e}")
end

```

```ruby
begin
  task.perform
rescue NetworkConnectionError => e
  #Retry logic...
rescue InvalidRecordError => e
  # Send record to support staff...
end
```

[Exeption](http://best-ruby.com/best_practices/using_exception_e.html)

`rescue => e` 만 쓰면 기본적으로 `StandardError` exception 만 잡히고 다른 exception 들을 잡지 못하므로 모든 exception 을 잡으려면 `rescue Exception => e` 이런식으로 잡아야 한다.

```ruby
loop do
  begin
    sleep 1
  rescue Exception => e
    puts "I'm STRONGER. Give up!"
  end
end

# Run and try CTRL+C
```

### Exception hierarchy
```ruby
Exception
  NoMemoryError
  ScriptError
    LoadError
    NotImplementedError
    SyntaxError
  SignalException
    Interrupt
  StandardError
    ArgumentError
    IOError
      EOFError
    IndexError
    LocalJumpError
    NameError
      NoMethodError
    RangeError
      FloatDomainError
    RegexpError
    RuntimeError
    SecurityError
    SystemCallError
    SystemStackError
    ThreadError
    TypeError
    ZeroDivisionError
  SystemExit
  fatal
```
