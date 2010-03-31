class BarModel
  
  include DataMapper::Resource
  
  property :id,    Serial, :length => 10
  property :title, String, :length => 64, :key => true
  
end