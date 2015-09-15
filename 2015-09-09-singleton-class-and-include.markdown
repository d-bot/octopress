---
layout: post
title: "Singleton Class and Include"
date: 2015-09-09 08:15:53 +0000
comments: true
categories: Ruby
---
[Explaining include and extend](http://aaronlasseigne.com/2012/01/17/explaining-include-and-extend/)

[Ruby Internals](http://confreaks.tv/videos/mwrc2008-ruby-internals)

[I, Object](http://jakeyesbeck.com/2015/08/23/ruby-objects/)

### 기본적으로 객체는 함수를 저장하고 있지 않다. 함수는 모두 해당 객체의 클래스에 저장되어 있다.

```ruby
class A
  def self.who_am_i
    puts self
  end

  def speak_up(input)
    puts input.upcase
  end
end
```

위의 코드를 실행하면 interpreter 는 A 클래스와 A의 singleton class 를 생성하고 singleton class 에 who_am_i 함수를 저장하고 A 클래스에는 speak_up 함수만 저장한다.(Again, 객체는 함수를 저장하지 않는다. A 도 Class 의 객체이므로 who_am_i 는 인터프리터가 런타임중 생성한 A의 singleton class 에 저장된다. Again, 모든 객체가 생성될때 그에 상응하는 singleton class 역시 같이 정의된다.)


### singleton method 를 추가할때

```ruby
class A
  def self.who_am_i
    puts self
  end

  def speak_up(input)
    puts input.upcase
  end
end

a = A.new
b = A.new

def a.not_so_loud(input)
  puts input.downcase
end
```

위와 같이 a 객체에 singleton method 를 추가하는 경우, interpreter 는 a 객체만의 singleton class \*\*A를 생성하고 해당 singleton class 에 not_so_loud 함수를 저장한다.

```
                                  Class

                                    ^
                                    |
                                    |

b ---> *A (has who_am_i) -----> A (has speak_up)

                                    ^
                                    |
                                    |
                                    |
a --> **A (has not_so_loud) ---------
```

위의 그림은 method look tree 를 보여주고 있다. 즉, 모든 객체들은 자신의 싱글턴 클래스에서 먼저 method lookup 을 실행후, 원래 클래스로 가서 인스턴스 메서드를 찾는다. 물론 b 객체는 \*\*A 와 아무런 관계가 없으므로 자신의 싱글턴 클래스 \*A 로 가서 함수를 찾는다. (Singleton class is the first place to look up a method)



### include 와 extend 의 차이

모듈 include 는 일반적인 class hierachy 사이에 들어가게 되나 extend 는 singleton class hierachy 사이에 들어가게 된다. (in terms of method lookup)



```
          -------------------------->  Module
          |
          |                              ^
          |                              |
          |                              |
          |                            Class
          |
          |                              ^
          |                              |
          |                              |

        Object ---------------------> *Object

          ^                              ^
          |                              |
          |                              |

        Pirate ----------------------> *Pirate

          ^                              ^
          |                              |
          |                              |

        Human ----------------------> *Human

```


