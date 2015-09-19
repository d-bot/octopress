---
layout: post
title: "Global Variables"
date: 2015-09-19 00:36:04 +0000
comments: true
categories: 
---

[from here](http://jimneath.org/2010/01/04/cryptic-ruby-global-variables-and-their-meanings.html)

### $: (Dollar Colon)

$: is basically a shorthand version of `$LOAD_PATH` `$:` contains an array of paths that your script will search through when using require.

```ruby
>> $: === $LOAD_PATH
=> true
>> $:
=> [".", "/Users/jimneath/.ruby"]
>> $: << '/test/path' # Add a directory to load path
=> [".", "/Users/jimneath/.ruby", "/test/path"]
```


### $0 (Dollar Zero)

$0 contains the name of the ruby program being run. This is typically the script name.

### $\* (Dollar Splat)

$\* is basically shorthand for ARGV. $\* contains the command line arguments that were passed to the script.

```ruby
#example.rb
puts "$*: " << $*.inspect
puts "ARGV: " << ARGV.inspect
Jims-MacBook-Pro:~/Desktop ruby example.rb hello world
$*: ["hello", "world"]
ARGV: ["hello", "world"]
```

### $? (Dollar Question Mark)

$? returns the exit status of the last child process to finish.

```ruby
>> `pwd` # Show current directory
=> "/Users/jimneath/Desktop\n"
>> $?
=> #<Process::Status: pid=17867,exited(0)>
>> `fake command` # This will fail
(irb):7: command not found: fake command
=> ""
>> $?
=> #<Process::Status: pid=17871,exited(127)>
```

### $$ (Dollar Dollar)

$$ returns the process number of the program currently being ran.

```ruby
>> $$ # Show process id
=> 17916
>> puts `ps aux | grep irb`
```


### $~ (Dollar Tilde)

$~ contains the MatchData from the previous successful pattern match. (the last regex match, as an array of subexpressions)

```ruby
>> "hello world".match(/world/) === $~
=> true
>> $~
=> #<MatchData:0x12be0e8>
>> $~.to_a
=> ["world"]
```


### $1, $2, $3, $4 etc

$1-$9 represent the content of the previous successful pattern match.

```ruby
>> "hello world".match(/(hello) (world)/) 
=> #<MatchData:0x12b06f0>
>> $1
=> "hello"
>> $2
=> "world"
>> $3
=> nil
```

### $& (Dollar Ampersand)

$& contains the matched string from the previous successful pattern match. (string last matched by regex)

```ruby
>> "the quick brown fox".match(/quick.*fox/)
=> #<MatchData:0x129cc40>
>> $&
=> "quick brown fox"
```

### $+ (Dollar Plus)

$+ contains the last match from the previous successful pattern match.

```ruby
>> "the quick brown fox".match(/(quick) (brown) (fox)/)
=> #<MatchData:0x1294a04>
>> $~.to_a
=> ["quick brown fox", "quick", "brown", "fox"]
>> $+
=> "fox"
```

### $` (Dollar Backtick)

$` contains the string before the actual matched string of the previous successful pattern match.

```ruby
>> "the quick brown fox".match(/quick.*fox/)
=> #<MatchData:0x12882cc>
>> $&
=> "quick brown fox" # The matched string
>> $`
=> "the " # The text preceding the matched string
```

### $’ (Dollar Apostrophe)

$' contains the string after the actual matched string of the previous successful pattern match.

```ruby
>> "the quick brown fox".match(/quick/)
=> #<MatchData:0x1280c48>
>> $&
=> "quick" # The matched string
>> $'
=> " brown fox" # The text following the matched string
```

## Exceptional Global Variables


### $! (Dollar Bang)

$! contains the Exception that was passed to raise. (last error message)

```ruby
>> 0 / 0 rescue $!
=> #<ZeroDivisionError: divided by 0>
```

### $@ (Dollar At Symbol)

$@ contains the backtrace for the last Exception raised. (location of error)

```ruby
>> 0 / 0 rescue puts $@
(irb):16:in `/'
(irb):16:in `irb_binding'
/usr/local/lib/ruby/1.8/irb/workspace.rb:52:in `irb_binding'
/usr/local/lib/ruby/1.8/irb/workspace.rb:52
=> nil
```


## ETC

### $\_ The last input line of string by gets or readline.

### $"

### $-I

### $/ input record separator

### $\ output record separator

### $\. line number last read by interpreter

### $= case-insensitivity flag

### $* the command line arguments


## $_ and $~ have local scope.





