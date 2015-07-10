require 'spec_helper'

describe Fluxie::Client do
  describe 'from_url' do
    let(:client) { Fluxie::Client.from_url('influxdb://uuuu:ppppaaa@127.0.0.1:8086/sms') }

    it 'can be created with a url' do
      expect(client).to be_a(Fluxie::Client)
    end

    describe 'query' do
      it 'works' do
        result = client.query('SELECT mean(d) FROM datapoints WHERE time > now() - 1h GROUP BY time(10m)')
        expect(result).to be_a(Fluxie::QueryResult)
      end

      it 'works23' do
        result = client.query('SELECT mean(d) FROM datapointsa WHERE ta')
        expect(result).to be_a(Fluxie::QueryResult)
        expect(result).to be_errors
      end
    end

    describe 'write' do
      it 'works' do
        result = client.write('datapoints', values: {d: rand}, tags: {host: 'eve'})
        expect(result).to be(nil)
      end

      it 'can write string values' do
        result = client.write('datapoints', values: {d: rand, host: 'eve'}, tags: {host: 'eve'})
        expect(result).to be(nil)
      end
    end
  end

  describe 'non exsisting database' do
    it 'raises a specialized error if a database is not found' do
      client = Fluxie::Client.from_url('influxdb://uuuu:pppp@127.0.0.1:8086/not_found')
      expect { client.write('datapoints', values: {value: rand}) }.to raise_error(Fluxie::DatabaseNotFoundError)
    end
  end

  describe 'list_databases' do
    let(:client) { Fluxie::Client.from_url('influxdb://uuuu:pppp@127.0.0.1:8086/sms') }

    it 'returns an array of database names' do
      result = client.list_databases
      expect(result).to be_a(Array)
      expect(result).to include('sms')
    end
  end

  describe 'ping' do
    let(:client) { Fluxie::Client.from_url('influxdb://uuuu:pppp@127.0.0.1:8086/sms') }
    it 'works' do
      expect(client.ping).to eq(true)
    end
  end


  describe 'JSONDecoder' do
    let(:decoder) { Fluxie::JSONDecoder }
    MockResponse = Struct.new(:body, :header)

    context 'valid json' do
      it 'returns a hash with string keys' do
        input = MockResponse.new('{"hello": 1234}', content_type: 'application/json')
        output = decoder.call(input)

        expect(output.body).to eq('hello' => 1234)
      end
    end

    context 'invalid json' do
      it 'blows up if content type is json but content is invalid' do
        input = MockResponse.new('hello: 1234}', content_type: 'application/json')
        expect { decoder.call(input) }.to raise_error(Fluxie::JSONDecoder::Error)
      end

      it 'does not blow up if content type is not json' do
        body = 'hello: 1234}'.freeze
        input = MockResponse.new(body, content_type: 'text/plain')
        expect(decoder.call(input).body).to eq(body)
      end
    end
  end
end