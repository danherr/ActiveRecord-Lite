require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    if params.is_a?(Hash)
      results = DBConnection.execute(<<-SQL, params)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          #{params.map{|key, val| "#{key} = :#{key}"}.join(' AND ')}
      SQL

      results.map{|row_hash| self.new(row_hash)}
    end
  end
end

class SQLObject
  extend Searchable
end
