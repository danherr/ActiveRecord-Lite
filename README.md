# AR-Lite

A lightweight ORM.

# Outline

The project itself is contained in the lib folder. In spec there are a number of automated tests of the basic functionality of the library. These make use of the testing database. This is a simple database defined and populated in 'test.sql' that contains some basic information for a few animals and humans from the 'Game of Thrones' universe.

The file 'pry_testing_setup.rb' contains basic model defenitions for the tables in this database. In order to play with the models themselves, download the repo and load this file in a REPL. There will be a total of six models: 'Pet', 'Human', 'Species', 'Kingdom' and 'Continent'.  These have been connected via appropriate 'belongs_to' and 'has_many' connections. They have also been connected across multiple steps through 'has_one' connections - the only multi-step association that I've written so far.

#SQLObject

This is the base class for Models. A model will be connected to a database table whose name is a pluralized version of the model name. This can be overridden by setting the model's '.table_name' property manually.

## Class Methods

A Model that inherits from SQLObject will have the following class methods:

* all - Fetches the relevant table from the database, constructs a new object for each row, and returns them packaged in an array.
* columns - Returns an array of symbols representing the column names in the relevant table.
* find - Takes an id and returns a model for the record with that id.
* new - Takes in a hash of attributes and creates a new model instance with these attributes.
* where - Takes in a hash linking attributes to values, and returns an array of models corresponding to all records whose attributes match the linked values. 

## Instance Methods

Any model of a class inherited from SQLObject will have the following instance method:

* save - Saves the model to the database. This either creates a new record in the model's table, or updates the record already there.

In addition to this, it will have reader and writer methods for each column in its database table.

## Associations

There are three types of associations: belongs_to, has_one and has_many. These express the foreign key realtionships between the models. When an association is defined, it stores the information needed to construct a join table. Each association takes a name and an optional hash of options. It will add an instance method with the given name to its model.

### The `belongs_to` Association

This supports the 'many' side of a one-step one-to-many relationship. It takes the following options:

* `class_name` - The name of the model class that the current model is connected to. This defaults to the capitalized version of the association name.

* `primary_key` - The column in the current class that will be used in the join. This defaults to `'id'`

* `foreign_key` - The column in the other class that will be used for the join. This defaults to the association name with `'_id'` appended on the end.

### The `has_one` Association

This supports either a one-to-one relatonship or the 'many' side of a multi-step one-to-many relationship. It can be used in two ways:

##### Without the `through` option:

* `class_name` - As above: the name of the association changed into class-name style.

* `primary_key` - The column in the foreign table. This defaults to `'id'`.

* `foreign_key` - The column name in the current table. This defaults to the association name plus `'_id'`.

##### With the `through` option:

* `through` - The name (as a symbol) of an association on the current model that takes us at least one step toward the other desired model. This has no default as it is required to let the system know this will be a multi-step association.

* `source` - The name (as a symbol) of an association on the target of the association named in the `through` option. This association must target the ultimate endpoint of the current association. This defaults to the name of the current association.

Note that the chain of associations defined by a `has_one` with the `through` option must only contain other associations of the `belongs_to` or `has_one` type.

### The `has_many` Association

This supports the 'one' side of a many-to-one relationship. (Currently only a single step one.) Its name should be plural. It has the following options:

* `class_name` - The name of the association changed into class-name style and made singular.

* `primary_key` - The column in the foreign table. This defaults to `'id'`.

* `foreign_key` - The column name in the current table. This defaults to the singularized association name plus `'_id'`.
