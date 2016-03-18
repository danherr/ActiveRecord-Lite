require_relative 'db_connection'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'


class SQLObject

  extend Associatable
  extend Searchable

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
    @table_name ||= self.name.downcase.pluralize
  end

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

  def save
    id ? update : insert
  end

end
