class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, Text
  property :password, Text

  has n, :favorites, through: Resource
  has n, :venues, through: Resource
end
