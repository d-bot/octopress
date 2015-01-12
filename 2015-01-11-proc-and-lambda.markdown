---
layout: post
title: "Proc &amp; Lambda"
date: 2015-01-11 23:36:36 +0000
comments: true
categories:
---

<h2>Block 을 Proc 으로 변환</h2>
특정 함수에 블락을 argument 로 넣고 싶을때 &를 붙여서 가장 마지막 argument 로 넘긴다.

```ruby
p = Proc.new { |x| x + 1 }  # p.call(2) # 3
p = lambda { |x| x + 1 }    # p.call(2) # 3
p = -> (x) { x + 1 }        # p.call(2) # 3 # so-called stabby lambda
```

<h2> 2 differences between Lambda and Proc (RETURN and CHECKING of ARGUMENTS) </h2>

<h4> RETURN </h4>

```ruby
2.0.0p353 :001 > l = lambda { return 10 }
 => #<Proc:0x007f97023c4ee8@(irb):4 (lambda)>
2.0.0p353 :002 > p = Proc.new { return 10 }
 => #<Proc:0x007f97023dfc98@(irb):5>
2.0.0p353 :003 > l.call
 => 10
2.0.0p353 :004 > p.call
LocalJumpError: unexpected return
  from (irb):5:in `block in irb_binding'
  from (irb):7:in `call'
  from (irb):7
  from /Users/dchoi/.rvm/rubies/ruby-2.0.0-p353/bin/irb:12:in `<main>'
2.0.0p353 :005 >
```

<h4>In a proc,  "return" behaves differently. Rather than return from the proc, it returns from the scope where the proc itself was defined</h4>

```ruby
def double(callable_object)
  callable_object.call * 2
end

l = lambda { return 10 }
double(l) # => 20

p = Proc.new { return 10 }
double(p) # => LocalJumpError # Because it tries to return from the scope where p is defined but you can't return from the top-level scope.
# To avoid this problem, p should be defined without return keyword like "p = Proc.new { 10 }"
```

```ruby
def another_double
  p = Proc.new { return 10 }
  result = p.call
  return result * 2 # unreachable code!
end

another_double # => 10
```


<h4> Checking of arguments (arity) </h4>

Lambda strictly honor the # arguments but Proc doesn't (Lambda fails with ArgumentError)

```ruby
2.0.0p353 :001 > p = Proc.new { |a, b| [a, b] }
 => #<Proc:0x007f8e2abb7e88@(irb):1>
2.0.0p353 :002 > l = lambda { |a, b| [a, b] }
 => #<Proc:0x007f8e2abc48b8@(irb):2 (lambda)>
2.0.0p353 :003 > p.call(1,2,3)
 => [1, 2]
2.0.0p353 :004 > l.call(1,2,3)
ArgumentError: wrong number of arguments (3 for 2)
  from (irb):2:in `block in irb_binding'
  from (irb):4:in `call'
  from (irb):4
  from /Users/dchoi/.rvm/rubies/ruby-2.0.0-p353/bin/irb:12:in `<main>'
2.0.0p353 :005 > l.call(1)
ArgumentError: wrong number of arguments (1 for 2)
  from (irb):2:in `block in irb_binding'
  from (irb):5:in `call'
  from (irb):5
  from /Users/dchoi/.rvm/rubies/ruby-2.0.0-p353/bin/irb:12:in `<main>'
2.0.0p353 :006 > p.call(1)
 => [1, nil]
```

All in all, lambdas is strict about arguments and they just exit when return is called. Use lambda if you don't need specific the specific features of Procs.
