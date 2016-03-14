# AR-Lite

A toy-level ORM built to demonstrate my knowledge of SQL and ruby metaprogramming.

# Outline

The project itself is contained in the lib folder. In spec there are a number of automated tests of the basic functionality of the library. These make use of the testing database. This is a simple database defined and populated in 'test.sql' that contains some basic information for a few animals and humans from the 'Game of Thrones' universe. The file 'pry_testing_setup.rb' contains basic model defenitions for the tables in this database.

In order to play with the models themselves, download the repo and load this file in pry. There will be a total of six models: 'Pet', 'Human', 'Species', 'Kingdom' and 'Continent'.  These have been connected via appropriate 'belongs_to' and 'has_many' connections. They have also been connected across multiple steps through 'has_one' connections - the only multi-step association that I've written so far.

