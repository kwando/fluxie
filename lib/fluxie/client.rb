require 'uri'
require 'hurley'
require 'json'
require 'fluxie/data_serie'
require 'fluxie/line_protocol'
require 'fluxie/point'
require 'logger'

module Fluxie
  module JSONDecoder
    Error = Class.new(StandardError)

    def self.call(response)
      response.body = JSON.load(response.body) if json?(response)
      response
    rescue JSON::ParserError => ex
      raise Error.new(ex)
    end

    def self.json?(response)
      response.header[:content_type].to_s.start_with?('application/json')
    end
  end

  class Database
    def initialize(client, name)
      @client = client
      @name = name
    end

    attr_reader :name
  end

  Error = Class.new(StandardError)

  class ClientError < Error
    def initialize(error, message)
      @error = error
      super(message)
    end

    attr_reader :error
  end

  DatabaseNotFoundError = Class.new(Error)
  BadQueryError = Class.new(Error)


  class Client
    DEFAULT_PORT = 8086

    # @param [URI] url
    def initialize(url, logger: Logger.new(STDOUT))
      raise TypeError.new('expected an URI instance') unless url.kind_of?(URI)
      @url = url
      db_name = url.path.to_s[1..-1]

      @logger = logger

      @url.scheme = 'http'
      @url.path = ''
      @url.port = DEFAULT_PORT if @url.port.nil?

      @http = Hurley::Client.new(url)
      @http.header[:user_agent] = "Fluxie v#{Fluxie::VERSION}"
      @http.after_call(JSONDecoder)

      @database = Database.new(self, db_name)
    end

    attr_reader :logger

    def list_databases
      query('show databases').series.first.values.flatten
    end

    # @return [Fluxie::Result]
    def query(string)
      logger.debug 'query: ' << string
      response = @http.get('/query', db: @database.name, q: string)
      logger.debug response.body.inspect
      return QueryResult.from_array(response.body.fetch('results')) if response.success?
      if response.status_code == 400
        raise BadQueryError.new(response.body['error'])
      end
      raise "#{response.status_code} #{response.body}"
    rescue Hurley::ClientError => ex
      raise ClientError.new(ex, ex.message)
    end

    def write(series, tags: {}, values: {})
      query = Point.new(series, tags: tags, values: values).to_s

      logger.debug 'write: ' << query
      response = @http.post("/write?db=#{@database.name}", query)
      logger.debug("#{response.status_code} #{response.body}")

      return response.body if response.success?
      if response.status_code = 404
        raise DatabaseNotFoundError.new("Database '#{@database.name}' does not exist")
      end
      raise "#{response.status_code} #{response.body}"
    rescue Hurley::ClientError => ex
      raise ClientError.new(ex, ex.message)
    end

    # @return [Boolean]
    def ping
      @http.get('/ping').success?
    end

    class << self
      # @return [Fluxie::Client]
      def from_url(string)
        new(URI.parse(string.to_s))
      end
    end
  end
end
