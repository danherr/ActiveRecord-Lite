require 'associatable'

describe 'AssocOptions' do
  describe 'BelongsToOptions' do
    it 'provides defaults' do
      options = BelongsToOptions.new('house')

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq('House')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = BelongsToOptions.new('owner',
                                     foreign_key: :human_id,
                                     class_name: 'Human',
                                     primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Human')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'HasManyOptions' do
    it 'provides defaults' do
      options = HasManyOptions.new('cats', 'Human')

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq('Cat')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = HasManyOptions.new('cats', 'Human',
                                   foreign_key: :owner_id,
                                   class_name: 'Kitten',
                                   primary_key: :human_id
      )

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq('Kitten')
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Pet < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'

        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.model_class).to eq(Human)

      options = HasManyOptions.new('pets', 'Human')
      expect(options.model_class).to eq(Pet)
    end
    
    it '#table_name returns table name of associated object' do
      options = BelongsToOptions.new('human')
      expect(options.table_name).to eq('humans')

      options = HasManyOptions.new('pets', 'Human')
      expect(options.table_name).to eq('pets')
    end
  end
end

describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Pet < SQLObject
      belongs_to :human, foreign_key: :owner_id

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :pets, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLObject
      has_many :humans

      finalize!
    end
  end

  describe '#belongs_to' do
    let(:nymeria) { Pet.find(1) }
    let(:arya) { Human.find(1) }

    it 'fetches `human` from `Pet` correctly' do
      expect(nymeria).to respond_to(:human)
      human = nymeria.human

      expect(human).to be_instance_of(Human)
      expect(human.name).to eq('Arya')
    end

    it 'fetches `house` from `Human` correctly' do
      expect(arya).to respond_to(:house)
      house = arya.house

      expect(house).to be_instance_of(House)
      expect(house.name).to eq('Stark')
    end

    it 'returns nil if no associated object' do
      stray_cat = Pet.find(6)
      expect(stray_cat.human).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:danny) { Human.find(4) }
    let(:danny_house) { House.find(3) }

    it 'fetches `pets` from `Human`' do
      expect(danny).to respond_to(:pets)
      dragons = danny.pets

      expect(dragons.length).to eq(3)

      expected_names = %w(Drogon Rheagal Viserion)
      3.times do |i|
        dragon = dragons[i]

        expect(dragon).to be_instance_of(Pet)
        expect(dragon.name).to eq(expected_names[i])
      end
    end

    it 'fetches `humans` from `House`' do
      expect(danny_house).to respond_to(:humans)
      humans = danny_house.humans

      expect(humans.length).to eq(1)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].name).to eq('Daenerys')
    end

    it 'returns an empty array if no associated items' do
      petless_human = Human.find(3)
      expect(petless_human.pets).to eq([])
    end
  end


describe 'Associatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Pet < SQLObject
      belongs_to :human, foreign_key: :owner_id
      belongs_to :species

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      has_many :pets, foreign_key: :owner_id
      belongs_to :house

      finalize!
    end

    class House < SQLObject
      has_many :humans
      belongs_to :kingdom

      finalize!
    end

    class Kingdom < SQLObject
      has_many :houses
      belongs_to :continent
    end

    class Continent < SQLObject
      has_many :kingdoms
    end
    
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      pet_assoc_options = Pet.assoc_options
      human_options = pet_assoc_options[:human]

      expect(human_options).to be_instance_of(BelongsToOptions)
      expect(human_options.foreign_key).to eq(:owner_id)
      expect(human_options.class_name).to eq('Human')
      expect(human_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Pet.assoc_options).to have_key(:human)
      expect(Human.assoc_options).to_not have_key(:human)

      expect(Human.assoc_options).to have_key(:house)
      expect(Pet.assoc_options).to_not have_key(:house)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Pet
        has_one_through :house, :human, :house

        self.finalize!
      end
    end

    let(:nymeria) { Pet.find(1) }

    it 'adds getter method' do
      expect(nymeria).to respond_to(:house)
    end

    it 'fetches associated `house` for a `Pet`' do
      house = nymeria.house

      expect(house).to be_instance_of(House)
      expect(house.name).to eq('Stark')
    end
  end
end


end
