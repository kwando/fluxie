require 'spec_helper'

describe Fluxie::LineProtocol do
  let(:protocol) { Fluxie::LineProtocol }

  describe 'escape' do
    it 'surround strings with quotes' do
      expect(protocol.escape('hello')).to eq('"hello"')
    end

    it 'escapes quotes' do
      expect(protocol.escape('hel"lo')).to eq('"hel\"lo"')
    end

    it 'passes through Fixnums' do
      expect(protocol.escape(23)).to eq(23)
    end

    it 'passes through Floats' do
      expect(protocol.escape(23.13)).to eq(23.13)
    end
  end

  describe 'escape_field' do
    it 'escapes whitespaces' do
      expect(protocol.escape_field('tag key with spaces')).to eq('tag\ key\ with\ spaces')
    end

    it 'escapes tag values' do
      expect(protocol.escape_field('tag,value,with"commas"')).to eq('tag\,value\,with"commas"')
    end
  end
end