class Foo < Lamed::Controller

  def say_hello
    content_type = 'text/html'
    hello = "Hello.  This is the #{self.to_s} controller"
    return hello
  end

end