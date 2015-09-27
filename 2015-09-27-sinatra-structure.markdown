---
layout: post
title: "Sinatra Structure"
date: 2015-09-27 07:07:36 +0000
comments: true
categories: 
---

[Sinatra Structure](http://neethack.com/2012/02/code-odyssey-sinatra/)

### base.rb

1. Rack Module: Rack:Request 와 Rack:Response 를 구현한다.

2. Helper Module: 헬퍼 메서드들은 routes, filters, views  안에서 available 하며, redirect, status code, url, html header, session, mime type, http streaming등을 처리한다.

3. Template Module: tilt 를 이용하여 다양한 템플릿 엔진들을 다룬다.

4. Base class: 위의 모든 모듈을 포함하는 메인 클래스. Handling routes and invoke correspond code blocks and filters

5. Application class: Base 클래스를 상속하고 시나트라 어플리케이션의 객체를 실행한다.

6. Delegator module: top-level 파일의 DSL method 들을 Delegation 한다.

### main.rb

Patch Sinatra::Application class, set the hooks to run application at exit and parse option. Also it includes the delegator to send all methods on Top-level to application

## Routes

In Sinatra, after user call the dsl methods(like get, post) in file, the HTTP verbs, path and code block will be registered in application, and will be executed when receiving matched request.

when the dsl method get called, the Application will generate a Proc with the name of Http verb and path (like "get /") save the Proc, url path (include the keys, pattern and conditions on paths like "/:id") in @routes

DSL 함수가 호출되면, Application 은 해당 호출된 http verb 와 path (get "/") 를 Proc 객체를 생성하고 저장한

```ruby
Simplifie dversion of routes

class App

  class << self
    attr_reader :routes

    def get(path, options={}, &block)
      route("GET", path, options, &block)
    end

    def route(verb, path, options, &block)
      @routes ||= {}
      signature = complie!(verb, path, block, options)
      @routes[verb] ||= []
      @routes[verb] << signature
    end

    def compile!(verb, path, block, options)
      unbound_method = generate_method("#{verb} #{path}", &block)

      [path, proc {|base| unbinded_method.bind(base).call() }]
    end

    def generate_method(method_name, &block)
      define_method(method_name, &block)
      method = instance_method method_name
      remove_method method_name
      method
    end
  end

end

App.get "/" do
  "Hello world"
end
"""
get( "/", options={}, Proc.new("Hello world") )
=>
route( "GET", "/", {}, Proc.new("Hello world") )
=>
@routes = {}
@routes["GET"] = [ compile!("GET", "/", Proc.new("Hello world"), {}) ]
"""


base = App.new
App.routes["GET"][0][1].call(base)    # App.routes 이렇게 액세스가 가능한건 attr_reader 로 정의했기 때문
#print:: "Hello world"

```

In here, sinatra generates the code block as an `unbound_method`, it is a kind of instance method that you can bind it to any other instance dynamically before call. Sinatra use this to bind Application instance with Proc on runtime

## Route call

After register the code block, sinatra waits for request and invoke correspond routes to handle request. The entry point of all request is the rack [call interface](http://chneukirchen.org/blog/archive/2007/02/introducing-rack.html). All rack application must inplement the interface.

Overall, the request execution stack is: `call => call! => invoke => dispatch! => route! => route_eval`


```ruby
def call(env)
  dup.call!(env)
end

def call!(env)
  @env = env
  @request = Request.new(env)
  @response = Response.new
  @params = indifferent_params(@request.params)
  template_cache.clear if settings.reload_templates
  force_encoding(@params)

  @response['Content-Type'] = nil
  invoke {dispatch!}
  invoke { error_block!(response.status)}

  unless @response['Content-Type']
    if Array === body and body[0].respond_to? :content_type
      content_type body[0].content_type
    else
      content_type :html
    end

    @response.finish
  end
end
```

The code above is the first part of how Sinatra handle incoming requests. First, as a Rack application, all requests will invoke the call(env) function Sinatra application will duplicate an instance, invoke the call!(env) on new instance (because HTTP is stateless) in the call! function, sinatra will new the Rack::Request and Rack::Response object by env, than set the params.

After all object is set, it will start to invoke the routes by `invoke{ dispatch! }`, the result will be store on @response, and return to user by call the @response.finish

```ruby
# Run the block with 'throw :halt' support and apply result to the response.
def invoke
  res = catch(:halt) { yield }
  res = [res] if Fixnum === res or String === res
  if Array === res and Fixnum === res.first
    status(res.shift)
    body(res.pop)
    headers(*res)
  elsif res.respond_to? :each
    body res
  end
  nil # avoid double setting the same response tuple twice
end
```


The invoke function wrap and execute the handler codeblock, catch the :halt (which throw by route! as interrupt signal), and then set status, header and result to @response.

for example, when you execute the code wrapped by invoke, you can set the @response by throw :halt and Array response:

```ruby
invoke do
  # do something...
  throw :halt, [200, "Hello world!"] # this will go to @@response
end
```

With the structure like this, error_block or other function can also throw :halt with result and return to user.

