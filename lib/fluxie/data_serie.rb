module Fluxie
  class QueryResult
    def initialize(data)
      raise TypeError.new("expected a Hash but got #{data.class}") unless data.kind_of?(Hash)
      @data = data
    end

    def series
      @data.fetch('series') { raise Fluxie::Error.new('query contains an error') }.map { |data| DataSerie.from_data(data) }
    end

    def errors?
      @data.detect { |s| s.include?('error') }
    end

    class << self
      def from_array(result)
        raise Fluxie::Error.new('expects an array') unless result.kind_of?(Array)
        raise Fluxie::Error.new("expects array.size to be 1 but is #{result.size}") if result.size != 1
        new(result.first)
      end
    end
  end
  class DataSerie
    def initialize(name, columns, values)
      @name = name.freeze
      @columns = columns.freeze
      @values = values.freeze
    end

    attr_reader :name
    attr_reader :columns
    attr_reader :values

    def to_a
      @values.map { |values| Hash[@columns.zip(values)] }
    end

    class << self
      def from_data(data)
        new(
            data.fetch('name'),
            data.fetch('columns'),
            data.fetch('values')
        )
      end
    end
  end
end