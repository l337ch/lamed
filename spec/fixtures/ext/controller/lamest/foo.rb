class Foo < Lamed::Controller

  def say_hello
    @req_params[:content_type] = 'text/html'
    hello = "Hello.  This is the #{self.to_s} controller"
    return hello
  end

end