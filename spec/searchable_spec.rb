require 'searchable'

describe 'Searchable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Pet < SQLObject
      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      finalize!
    end
  end

  it '#where searches with single criterion' do
    pets = Pet.where(name: 'Nymeria')
    pet = pets.first

    expect(pets.length).to eq(1)
    expect(pet.name).to eq('Nymeria')
  end

  it '#where can return multiple objects' do
    humans = Human.where(house_id: 1)
    expect(humans.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    humans = Human.where(name: 'Rob', house_id: 1)
    expect(humans.length).to eq(1)

    human = humans[0]
    expect(human.name).to eq('Rob')
    expect(human.house_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Human.where(name: 'Jaquen Hagar')).to eq([])
  end
end
