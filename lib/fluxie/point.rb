require 'fluxie/line_protocol'
module Fluxie
  class Point
    def initialize(measurement, tags: {}, values: {})
      @measurement = measurement
      @tags = tags
      @values = values
    end

    attr_reader :tags
    attr_reader :values
    attr_reader :measurement

    # @return [Fluxie::Point]
    def tag(key, value)
      @tags[key] = value unless value.nil?
      self
    end

    # @return [Fluxie::Point]
    def field(key, value)
      @values[key] = value unless value.nil?
      self
    end

    # @return [String]
    def to_s
      "#{LineProtocol.escape_field(measurement)}#{LineProtocol.tag_clause(tags)} #{LineProtocol.values(values)}"
    end

    class << self
      # @param name [String]
      # @return [Fluxie::Point]
      def measurement(name)
        new(name)
      end
    end
  end
end