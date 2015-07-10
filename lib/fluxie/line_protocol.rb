module Fluxie
  module LineProtocol
    def self.escape(value)
      case value
        when Numeric
        then
          return value
        else
          return %Q("#{value.to_s.gsub('"','\"')}")
      end
    end

    # @param tags [Hash]
    # @return [String]
    def self.values(values)
      values.map { |k, v| "#{escape_field(k)}=#{escape(v)}" }.join(',')
    end

    # @param tags [Hash]
    # @return [String]
    def self.tags(tags)
      return '' if tags.empty?
      ',' << tags.map { |k, v| "#{escape_field(k)}=#{v}" }.join(',')
    end

    # @param field [String | Symbol]
    # @return [String]
    def self.escape_field(field)
      field.to_s.gsub(',', '\,').gsub(/\s/, '\ ')
    end
  end
end