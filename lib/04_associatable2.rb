require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  class HasThroughOptions
    attr_accessor :through, :source, :class_name, :self_class

    def initialize(through, source, self_class)
      byebug if self_class.nil?
      @through = through
      @source = source
      @class_name = self_class.assoc_options[through].class_name
      @self_class = self_class
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
            source_class = options.class_name.constantize
            source = source_class.assoc_options[options.source]
            [through, source]
          else
            raise "Bad thing happened."
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
