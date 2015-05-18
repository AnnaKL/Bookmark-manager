class Link

  include DataMapper::Resource

  property :id,     Serial
  property :title,  String
  property :url,    String

  has n, :tag, through: Resource

end