require_relative 'searchable'
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

  
  class HasThroughOptions
    attr_accessor :through, :source, :self_class

    def initialize(through, source, self_class)
      @through = through
      @source = source
      # through_class = self_class.assoc_options[through].class_name
      # @class_name = through_class.constantize.assoc_options[source].class_name
      @self_class = self_class
    end

    def class_name
      through_class = self_class.assoc_options[through].class_name
      @class_name ||= through_class.constantize.assoc_options[source].class_name
      # @class_name ||= self_class.assoc_options[source].class_name
    end
  end

  def has_one_through(name, through_name, source_name)

    h_th_options = HasThroughOptions.new(through_name, source_name, self)
    self.assoc_options[name] = h_th_options

    define_method(name.to_sym) do

      path = [h_th_options]
      until path.all?{|options| options.is_a?(BelongsToOptions)}
        path = path.flat_map do |options|
          if options.is_a?(BelongsToOptions)
            [options]
          elsif options.is_a?(HasThroughOptions)
            through = options.self_class.assoc_options[options.through]
            source_class = through.class_name.constantize
            source = source_class.assoc_options[options.source]
            [through, source]
          else
            raise "Found incorrect associations in the path."
          end
        end
      end


      their_table = path.last.table_name
      me = self.id
      my_table = self.class.table_name



      joins = path.inject(["", my_table]) do |joins_pair, be_options|
        last_table = joins_pair.last
        new_table = be_options.table_name
        f_key = be_options.foreign_key
        p_key = be_options.primary_key
        new_joins = joins_pair.first + <<-SQL
        JOIN
          #{new_table} ON #{last_table}.#{f_key} = #{new_table}.#{p_key}
        SQL

        [new_joins, new_table]
      end

      joins = joins.first

      result = DBConnection.execute(<<-SQL)
          SELECT
            #{their_table}.*
          FROM
            #{my_table}
          #{joins}
          WHERE
            #{my_table}.id = #{me}
          LIMIT 1
        SQL

      result.first ? path.last.model_class.new(result.first) : nil
    end

  end

end

class SQLObject

  extend Associatable
end
