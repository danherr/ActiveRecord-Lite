require_relative '04_associatable2'



DBConnection.reset

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id

  has_one_through :home, :human, :house

  has_one_through :country, :human, :country
  has_one_through :country2, :home, :country

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :cats, foreign_key: :owner_id
  belongs_to :house

  has_one_through :country, :house, :country

  finalize!
end

class House < SQLObject
  has_many :humans

  belongs_to :country

  finalize!
end

class Country < SQLObject

  has_many :houses

finalize!
end
