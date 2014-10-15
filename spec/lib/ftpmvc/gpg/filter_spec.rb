require 'ftpmvc/gpg/filter'
require 'ftpmvc/file'
require 'ftpmvc/directory'

describe FTPMVC::GPG::Filter do
  before do
    stub_const 'OtherFilter', Class.new(FTPMVC::Filter)
  end
  let(:other_filter) { OtherFilter.new(nil, nil) }
  let(:gpg_filter) { FTPMVC::GPG::Filter.new(nil, other_filter, recipients: 'john.doe@gmail.com') }
  describe '#index' do
    before do
      allow(other_filter)
        .to receive(:index)
        .and_return [ FTPMVC::File.new(original_filename), FTPMVC::Directory.new('documents') ]
    end
    let(:original_filename) { 'secret.txt' }
    it 'adds .gpg extension to files returned by chain' do
      expect(gpg_filter.index('/').map(&:name)).to include 'secret.txt.gpg'
    end
    context 'when file already has .gpg as extensions' do
      let(:original_filename) { 'secret.txt.gpg' }
      it 'keeps filename untouched' do
        expect(gpg_filter.index('/').map(&:name)).to include 'secret.txt.gpg'
      end
    end
    it 'keeps directory names untouched' do
      expect(gpg_filter.index('/').map(&:name)).to include 'documents'
    end
    context 'when file already has .gpg as extensions' do
      let(:original_filename) { 'secret.txt.gpg' }
      it 'keeps filename unchanged' do
        expect(gpg_filter.index('/').map(&:name)).to include 'secret.txt.gpg'
      end
    end
  end

  describe '#get' do
    before do
      allow(other_filter)
        .to receive(:get)
        .and_return StringIO.new('secret')
    end
    it 'encrypts original content' do
      expect(gpg_filter.get('/file.txt.gpg').read.size).to eq 342
    end

  end
end
