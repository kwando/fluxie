require 'spec_helper'

describe Fluxie::DataSerie do
  context 'with valid data' do
    let(:values) { [[1, 2], [3, 4]].freeze }
    let(:columns) { %w(a b).freeze }
    let(:name) { 'hello_world'.freeze }

    let(:result) { Fluxie::DataSerie.new(name, columns, values) }

    it 'sets name' do
      expect(result.name).to eq(name)
    end

    it 'sets columns' do
      expect(result.columns).to match_array(columns)
    end

    it 'sets values' do
      expect(result.values).to match_array(values)
    end

    describe 'to_a' do
      it 'creates an array of hashes' do
        expect(result.to_a).to match_array([{'a' => 1, 'b' => 2}, {'a' => 3, 'b' => 4}])
      end
    end
  end
end