---
layout: post
title: "Enumerable"
date: 2014-12-03 08:32:07 +0000
comments: true
categories:
---
[참고: 루비의 꽃, 열거자 Enumerable 모듈](http://blog.nacyot.com/articles/2014-04-19-ruby-enumerable/)

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
일반적으로 Enumerable 함수들은 새로운 array 가 리턴되지만 ! (bang) 을 쓰면 원본 array 를 변경시켜 버린다.


select (반대: reject)
```ruby
[1,2,3,4,5,6,7,8].select { |x| x.even? }
[1,2,3,4,5,6,7,8].reject { |x| x.even? }
```

each_slice
```ruby
(1..10).each_slice(2) { |ary| p ary }
```
reverse_each
```ruby
(1..10).reverse_each { |x| p x }
```
each_with_index
```ruby
(1..10).each_with_index { |value, index| p "#{index}: #{value}" }
```

inject
```ruby
(1..10).inject(0) { |x, sum| sum += x }
```

count: length 와는 다르게 블럭을 받을수 있음
```ruby
(1..100).count { |x| x.even? }
```

grep
```ruby
["asdf", "qwer", "zxcv"].grep(/asdf/) { |x| x.upcase }
```

find/detect: 블럭을 평가하여 조건에 부합하는 첫번째 요소만 리턴
```ruby
(1..10).detect { |x| x.even? }
(1..10).find { |x| x.even? }
```

find_index: 해당 조건을 만족하는 첫번째 요소의 인덱스를 리턴
```ruby
[1,2,3,4,5,6,7,8].find_index { |x| x.even? }
```

take(n): 처음 n 개 요소 리턴 (블럭을 받을수 없음)
```ruby
[1,2,3,4,5,6,7,8,9,10].take(3)
```

drop(n): 앞에서 n 개 만큼 요소 제거 (블럭을 받을 수 없음)
```ruby
(1..10).drop(4)
```

sort: 비교할 블락을 넘겨 해당 기준으로 정렬할 수 있다. (유사품: min, min_by, max, max_by)
```ruby
["asdfg", "qwe", "zxcvbn", "poiuytr"].sort { |a, b| a.length <=> b.length }
["asdfg", "qwe", "zxcvbn", "poiuytr"].sort_by { |x| x.length }
```

minmax: 최대 최소 리턴 (블락을 받을 수 있음)
```ruby
[1,2,3,4,5,6,7].minmax
["asdfg", "qwe", "zxcvbn", "poiuytr"].minmax { |a, b| a.length <=> b.length }
```

partition: 특정 조건으로 컬렉션을 분할
```ruby
require 'prime'
prime, non_prime = (1..10).partition { |x| Prime.prime? x }
 => [[2, 3, 5, 7], [1, 4, 6, 8, 9, 10]]
2.1.1 :003 > p prime
[2, 3, 5, 7]
 => [2, 3, 5, 7]
2.1.1 :004 > p non_prime
[1, 4, 6, 8, 9, 10]
 => [1, 4, 6, 8, 9, 10]
2.1.1 :005 >
```

group_by: 블럭 평가가 같은 그룹들을 해쉬로 묶어 리턴
```ruby
(1..10).group_by {|i| i % 3 }
 => {1=>[1, 4, 7, 10], 2=>[2, 5, 8], 0=>[3, 6, 9]}

(1..10).group_by{|i| i % 3 }.each{|k, v| puts "나머지 " + k.to_s + " : " + v.join(", ")}
나머지 1 : 1, 4, 7, 10
나머지 2 : 2, 5, 8
나머지 0 : 3, 6, 9
 => {1=>[1, 4, 7, 10], 2=>[2, 5, 8], 0=>[3, 6, 9]}
```

all? : 모든 요소들이 해당 블럭을 패스하는지 검사
```ruby
["asdfg", "qwe", "zxcvbn", "poiuytr"].minmax { |a, b| a.length <=> b.length }
```

chunk: 블럭을 평가한 결과가 같은것끼리 분할
```ruby
["asdfg", "qwe", "zxcvbn", "poiuytr", "qwert", "asd"].chunk { |x| x.length }.to_a
 => [[5, ["asdfg"]], [3, ["qwe"]], [6, ["zxcvbn"]], [7, ["poiuytr"]], [5, ["qwert"]], [3, ["asd"]]]
```

