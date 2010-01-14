class Foo < Lamed::Controller

  def say_hello
    @req_params[:content_type] = 'text/html'
    hello = @req_params.inspect
    return hello
  end

end