class HelloWorld < Lamed::Controller
  
  def say_hello
    @req_params[:content_type] = 'text/html'
    hello = "Hello World.  We just got LaMeD!"
    return hello
  end
  
end