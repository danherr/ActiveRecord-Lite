require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        1
    SQL
      .first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "cats"
  end

  # ::all: return an array of all the records in the DB

  def self.all
    DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
      .map{|hash| self.new(hash)}
  end

  def self.parse_all(results)
    results.map{|hash| self.new(hash)}
  end

  # ::find: look up a single record by primary key

  def self.find(id)
    me = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
      .first

    me ? self.new(me) : nil
  end

  def initialize(params = {})
    params.each do |key, val|
      if self.class.columns.include? key.to_sym
        send("#{key}=", val)
      else raise "unknown attribute '#{key.to_s}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  # insert: insert a new row into the table to represent the SQLObject.

  def insert
    vals = attribute_values
    col_string = "(#{attributes.keys.join(', ')})"
    table = self.class.table_name
    num_val = vals.length

    DBConnection.execute(<<-SQL, *vals)
      INSERT INTO
        #{table} #{col_string}
      VALUES
        ( #{(["?"] * num_val).join(' , ')} )
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  # update: update the row with the id of this SQLObject

  def update
    table = self.class.table_name

    set_str = attributes.keys.map do |key|
      "#{key} = :#{key}"
    end.join(' , ')

    DBConnection.execute(<<-SQL, attributes)
      UPDATE
        #{table}
      SET
        #{set_str}
      WHERE
        id = :id
    SQL
  end

  # save: convenience method that either calls insert/update depending on whether or not the SQLObject already exists in the table.

  def save
    id ? update : insert
  end
end
