class HelloWorld < Lamed::Controller
  
  def say_hello
    content_type = 'text/html'
    puts env
    hello = "Hello World.  We just got LaMeD!"
    return hello
  end
  
end