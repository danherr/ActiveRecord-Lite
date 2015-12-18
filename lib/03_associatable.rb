require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym
    @class_name = options[:class_name] || name.to_s.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name.to_s.downcase + "_id").to_sym
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    be_options = BelongsToOptions.new(name, options)

    assoc_options[name] = be_options

    define_method(name.to_sym) do

      their_table = be_options.table_name
      foreign_key = be_options.foreign_key
      primary_key = be_options.primary_key
      me = self.id
      my_table = self.class.table_name

      result = DBConnection.execute(<<-SQL)
        SELECT
          #{their_table}.*
        FROM
          #{their_table}
        JOIN
          #{my_table} ON #{my_table}.#{foreign_key} = #{their_table}.#{primary_key}
        WHERE
          #{my_table}.id = #{me}
        LIMIT 1
      SQL

      result.first ? be_options.model_class.new(result.first) : nil
    end
  end

  def has_many(name, options = {})
    hm_options = HasManyOptions.new(name, self.name, options)

    define_method(name.to_sym) do
      their_table = hm_options.table_name
      their_key = hm_options.foreign_key
      my_key = hm_options.primary_key
      me = self.id
      my_table = self.class.table_name

      result = DBConnection.execute(<<-SQL)
        SELECT
          #{their_table}.*
        FROM
          #{their_table}
        JOIN
          #{my_table} ON #{my_table}.#{my_key} = #{their_table}.#{their_key}
        WHERE
          #{my_table}.id = #{me}
      SQL

      result.map{ |result| hm_options.model_class.new(result)}
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject

  extend Associatable
end
