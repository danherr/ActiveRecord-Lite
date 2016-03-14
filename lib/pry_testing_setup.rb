require_relative 'associatable'

DBConnection.reset

class Pet < SQLObject
  belongs_to :owner, class_name: "Human", foreign_key: :owner_id
  belongs_to :species
  
  has_one_through :house, :owner, :house

  has_one_through :kingdom, :owner, :kingdom
  has_one_through :continent, :kingdom, :continent

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :pets, foreign_key: :owner_id
  belongs_to :house

  has_one_through :kingdom, :house, :kingdom

  finalize!
end

class House < SQLObject
  has_many :humans

  belongs_to :kingdom

  has_one_through :continent, :kingdom, :continent

  finalize!
end

class Kingdom < SQLObject

  has_many :houses

  belongs_to :continent

  finalize!
end

class Continent < SQLObject

  has_many :kingdoms

  finalize!
  
end

class Species < SQLObject

  has_many :pets

  finalize!

end
