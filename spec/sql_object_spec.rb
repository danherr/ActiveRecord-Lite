require 'sql_object'
require 'db_connection'
require 'securerandom'

describe SQLObject do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Pet < SQLObject
      end
    end

    after(:each) do
      Object.send(:remove_const, :Pet)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Pet.table_name).to eq('pets')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Human < SQLObject
          self.table_name = 'humans'
        end

        expect(Human.table_name).to eq('humans')

        Object.send(:remove_const, :Human)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Pet.columns).to eq([:id, :name, :species_id, :owner_id])
      end

      it 'only queries the DB once' do
        expect(DBConnection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Pet.columns }
      end
    end

    describe '#attributes' do
      it 'returns @attributes hash byref' do
        cat_attributes = {name: 'Gizmo'}
        c = Pet.new
        c.instance_variable_set('@attributes', cat_attributes)

        expect(c.attributes).to equal(cat_attributes)
      end

      it 'lazily initializes @attributes to an empty hash' do
        c = Pet.new

        expect(c.instance_variables).not_to include(:@attributes)
        expect(c.attributes).to eq({})
        expect(c.instance_variables).to include(:@attributes)
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Pet < SQLObject
        self.finalize!
      end

      class Human < SQLObject
        self.table_name = 'humans'

        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Pet)
      Object.send(:remove_const, :Human)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        c = Pet.new
        expect(c.respond_to? :something).to be false
        expect(c.respond_to? :name).to be true
        expect(c.respond_to? :id).to be true
        expect(c.respond_to? :owner_id).to be true
      end

      it 'creates setter methods for each column' do
        c = Pet.new
        c.name = "Shaggy Dog"
        c.id = 209
        c.owner_id = 2
        expect(c.name).to eq 'Shaggy Dog'
        expect(c.id).to eq 209
        expect(c.owner_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        c = Pet.new
        c.instance_variable_set(:@attributes, {name: "Shaggy Dog"})
        expect(c.name).to eq 'Shaggy Dog'
      end

      it 'created setter methods use attributes hash to store data' do
        c = Pet.new
        c.name = "Shaggy Dog"

        expect(c.instance_variables).to include(:@attributes)
        expect(c.instance_variables).not_to include(:@name)
        expect(c.attributes[:name]).to eq 'Shaggy Dog'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        # We have to set method expectations on the pet object *before*
        # #initialize gets called, so we use ::allocate to create a
        # blank Pet object first and then call #initialize manually.
        c = Pet.allocate

        expect(c).to receive(:name=).with('Summer')
        expect(c).to receive(:id=).with(100)
        expect(c).to receive(:owner_id=).with(4)

        c.send(:initialize, {name: 'Summer', id: 100, owner_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Pet.new(favorite_band: 'Anybody but The Eagles')
        end.to raise_error "unknown attribute 'favorite_band'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        pets = Pet.all
        expect(pets.count).to eq(6)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'cat1', owner_id: 1 },
          { name: 'cat2', owner_id: 2 }
        ]

        pets = Pet.parse_all(hashes)
        expect(pets.length).to eq(2)
        hashes.each_index do |i|
          expect(pets[i].name).to eq(hashes[i][:name])
          expect(pets[i].owner_id).to eq(hashes[i][:owner_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        pets = Pet.all
        pets.each { |pet| expect(pet).to be_instance_of(Pet) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        c = Pet.find(1)

        expect(c).to be_instance_of(Pet)
        expect(c.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Pet.find(123)).to be_nil
      end
    end

    describe '#attribute_values' do
      it 'returns array of values' do
        cat = Pet.new(id: 123, name: 'cat1', owner_id: 1)

        expect(cat.attribute_values).to eq([123, 'cat1', 1])
      end
    end

    describe '#insert' do
      let(:cat) { Pet.new(name: 'Gizmo', owner_id: 1) }

      before(:each) { cat.insert }

      it 'inserts a new record' do
        expect(Pet.all.count).to eq(7)
      end

      it 'sets the id once the new record is saved' do
        expect(cat.id).to eq(DBConnection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the cat again
        cat2 = Pet.find(cat.id)

        expect(cat2.name).to eq('Gizmo')
        expect(cat2.owner_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        human = Human.find(2)

        human.name = 'Dead'
        human.update

        # pull the human again
        human = Human.find(2)
        expect(human.name).to eq('Dead')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        human = Human.new
        expect(human).to receive(:insert)
        human.save
      end

      it 'calls #update when record already exists' do
        human = Human.find(1)
        expect(human).to receive(:update)
        human.save
      end
    end
  end
end
