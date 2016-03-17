require_relative './lib/sql_object'

DBConnection.reset

class Pet < SQLObject
  belongs_to :owner, class_name: "Human", foreign_key: :owner_id
  belongs_to :species
  
  has_one :house, through: :owner, source: :house
  has_one :kingdom, through: :owner  
  has_one :continent, through: :kingdom

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :pets, foreign_key: :owner_id
  has_one :first_pet, class_name: "Pet", foreign_key: :owner_id
  
  belongs_to :house

  has_one :kingdom, through: :house

  finalize!
end

class House < SQLObject
  has_many :humans

  belongs_to :kingdom

  has_one :continent, through: :kingdom

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
