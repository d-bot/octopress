---
layout: post
title: "when to use block and why"
date: 2016-07-16 20:28:40 +0000
comments: true
categories: 
---

함수안에서 함수밖의 local scope 의 함수를 접근할때 블락을 이용할 수 있다.
```ruby
word = "moo"

define_method :x do
  puts word
end
# moo

y = proc { puts word }
y.call
# moo

z = lamda { puts word }
z.call
# moo
```

근데 함수 인자로 local scope 의 변수를 넘기면 될걸 굳이 블락을 써야하나? 좀 더 알아보자

[블락와 each](http://radar.oreilly.com/2014/02/why-ruby-blocks-exist.html)
```ruby
def calculate_tax(income)
  tax_rate = 0.2

  # return 비슷한 개념으로 보면 되는데, calculate_tax 가 받는 코드 블락의 인자로 사용된다.
  # 뭔가 map 함수가 쓰이는것 방식처럼 사용되어야 하다는 느낌
  yield income * tax_rate

end

calculate_tax(income) do |tax|
  # more code here w/ the
  # tax
end
```


http://stackoverflow.com/questions/2180903/when-to-use-blocks

뭔가 끝나지 않는 데이터를 읽으면서 특정 코드 블락을 실행할때

어떤 함수의 결과값에 따라서 특정 코드를 실행하고 싶을때
something.stuff do |result|
  block.call(result)
end

lambda { |test|
  "im lambda"
}


블록을 사용하는 좋은 예는 특정 함수의 결과값들을 차례로 리턴하는 함수를 받아서 또 다른 코드들을 실행시키는 함수?
```ruby
do_something(values) do |result|
  do another stuff with the result
end
```

[A block makes sense if ](http://stackoverflow.com/questions/2180903/when-to-use-blocks)

It allows code to use a resource without having to close that resource
```ruby
open(file) do |f|
  # do stuff with the file
end
```

The calling code would have to do non-trivial computation with the result
- In this case, you avoid adding the return value to calling scope. This also often makes sense with multiple return values.
```ruby
something.do_stuff do |res1, res2|
  if res1.foo? and res2.bar?
    foo(res1)
  else
    bar(res2)
  end
end # didn't add res1/res2 to the calling scope

```

Code must be called both before and after the yield (Eloquent ruby also explained it. template stuff?)
```ruby
<% content_tag :div do  %>
  <%= content_tag :span "span content" %>
<% end -%>
```

And of course iterators are a great use case, as they're (considered by ruby-ists to be) prettier than for loops or list comprehensions.









