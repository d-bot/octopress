---
layout: post
title: "Enumerable"
date: 2014-12-03 08:32:07 +0000
comments: true
categories:
---

each: 블락으로 계산된 값을 리턴하지도 원래 컬렉션을 변경하지도 않는다.
```ruby
2.0.0p353 :001 > a = %w/ a b c d e f /
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :002 > a.each { |x| x.upcase }
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :003 > p a
["a", "b", "c", "d", "e", "f"]
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :004 > b = a.each { |x| x.upcase }
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :005 > p b
["a", "b", "c", "d", "e", "f"]
 => ["a", "b", "c", "d", "e", "f"]
```

map: 블락으로 계산된 값을 리턴하지만 원래 컬렉션 자체를 변경하지는 않는다. (collect 함수도 동일)
```ruby
2.0.0p353 :001 > a = %w/ a b c d e f /
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :002 > a.map { |x| x.upcase }
 => ["A", "B", "C", "D", "E", "F"]
2.0.0p353 :003 > p a
["a", "b", "c", "d", "e", "f"]
 => ["a", "b", "c", "d", "e", "f"]
2.0.0p353 :004 > b = a.map { |x| x.upcase }
 => ["A", "B", "C", "D", "E", "F"]
2.0.0p353 :005 > p b
["A", "B", "C", "D", "E", "F"]
 => ["A", "B", "C", "D", "E", "F"]
```

select: 조건에 부합하는 값만 컬렉션으로 리턴
```ruby
2.0.0p353 :001 > a = [1,2,3,4,5,6,7,8]
 => [1, 2, 3, 4, 5, 6, 7, 8]
2.0.0p353 :002 > a.select { |x| x.even? }
 => [2, 4, 6, 8]
```

그외 재밌는 Enumerable methods
each_slice: `(1..10).each_slice(2) { |ary| p ary }`
reverse_each: `(1..10).reverse_each { |x| p x }`
each_with_index: `(1..10).each_with_index { |value, index| p "#{index}: #{value}" }`
inject: `(1..10).inject(0) { |x, sum| sum += x }`
count: length 와는 다르게 블럭을 받을수 있음 `(1..100).count { |x| x.even? }`
grep: `["asdf", "qwer", "zxcv"].grep(/asdf/) { |x| x.upcase }`


