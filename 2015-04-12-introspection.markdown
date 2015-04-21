---
layout: post
title: "Introspection"
date: 2015-04-12 08:56:20 +0000
comments: true
categories: 
---

### http://www.leighhalliday.com/ruby-introspection-metaprogramming

#### What data am I working on?
```ruby
puts spitty.inspect
#<Alpaca:0x007fd849166808 @name="Spitty", @birthdate=#<Date: 1984-11-11 ((2446016j,0s,0n),+0s,2299161j)>>
```


#### What type of class is this?
```ruby
puts spitty.class.name
# Alpaca

puts spitty.instance_of?(Alpaca)
# true
```

#### What methods are available to me?
```ruby
puts spitty.methods.inspect
[:name, :name=, :birthdate, :birthdate=, :spit, :nil?, :===, :=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :clone, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, :to_s, :inspect, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :singleton_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]

# methods except from parent object
7.methods.sort - Object.methods

puts spitty.respond_to?(:spit)
# true
```

#### Which instance variables are defined?
```ruby
puts spitty.instance_variables.inspect
[:@name, :@birthdate]
```

#### Which instance variables are defined?
```ruby
@name = "Mike"
test = "name"
2.2.0p0 :001 > puts instance_variable_get("@#{test}")
mike
 => nil
```

