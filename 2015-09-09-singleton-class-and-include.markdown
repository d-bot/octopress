---
layout: post
title: "Singleton Class and Include"
date: 2015-09-09 08:15:53 +0000
comments: true
categories: Ruby
---

[Explaining include and extend](http://aaronlasseigne.com/2012/01/17/explaining-include-and-extend/)

[Ruby Internals](http://confreaks.tv/videos/mwrc2008-ruby-internals)

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

위의 코드를 실행하면 interpreter 는 A 클래스와 A의 singleton class 를 생성하고 singleton class 에 who_am_i 함수를 저장하고 A 클래스에는 speak_up 함수만 저장한다.(Again, 객체는 함수를 저장하지 않는다. A 도 Class 의 객체이므로 who_am_i 는 인터프리터가 런타임중 생성한 A의 singleton class 에 저장된다.)


### 객체에 singleton method 를 추가할때

```ruby
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

b ---> A (has speak_up) ---> *A (has who_am_i)

          ^
          |
          |

a --> **A (has not_so_loud)
```

위의 그림은 method look tree 를 보여주고 있다. 즉, a 객체에서 method 룩업을 할때 가장 먼저 \*\*A 로 가고 그다음 A 로 가서 함수를 찾는다. 물론 b 객체는 \*\*A 와 아무런 관계가 없으므로 A 로 가서 함수를 찾는다.



### include 와 extend 의 차이

모듈 include 는 일반적인 class hierachy 사이에 들어가게 되나 extend 는 singleton class hierachy 사이에 들어가게 된다. (in terms of method lookup)



```
          --------------------->  Module
          |
          |                         ^
          |                         |
          |                         |
          |                       Class
          |
          |                         ^
          |                         |
          |                         |

        Object ----------------> *Object

          ^                         ^
          | extend                  |
          |                         |

 Sinatra::Application -----> *Sinatra::Application

          ^                         ^
          | 상속                    |
          |                         |

     Sinatra::Base ---------> *Sinatra::Base

```


