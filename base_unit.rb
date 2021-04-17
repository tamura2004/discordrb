class BaseUnit
  attr_accessor :type, :id, :name

  def initialize(type, id, name, y, x)
    @type = type
    @id = id
    @name = name
  end
end
