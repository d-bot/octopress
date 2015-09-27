---
layout: post
title: "Scripting in Object"
date: 2015-09-24 07:45:06 +0000
comments: true
categories: 
---

OOP 스타일이 아닌 스크립팅 스타일로 사용할때는 Object class 안에 모두 정의되는 셈인데 이때 singleton scope 와의 충돌이 어떻게 피해지는지 궁금

```ruby
def script_test
  puts "script test"
end

script_test
=> script test
```

위의 코드는 사실 아래와 같음.

```ruby

class Object

  def script_test
    puts "script test"
  end

end

script_test
=> script test
```

```ruby
:dchoi-mac:~:$ irb
2.2.0p0 :001 > self
 => main
 ```
