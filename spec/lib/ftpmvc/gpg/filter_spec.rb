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
      allow_any_instance_of(GPGME::Crypto)
        .to receive(:encrypt)
        .and_return StringIO.new('encrypted secret')
      allow(other_filter)
        .to receive(:get)
        .and_return StringIO.new('secret')
    end
    it 'encrypts original content' do
      expect(gpg_filter.get('/file.txt.gpg').read).to eq 'encrypted secret'
    end

    describe '#initialize' do
      context 'when keys option is given' do
        it 'imports the keys' do
          expect(GPGME::Key).to receive(:import).twice
          FTPMVC::GPG::Filter.new(nil,
            other_filter,
            recipients: 'john.doe@gmail.com',
            keys: ['mykey1', 'mykey2'])
        end
      end
      context 'when key has indentation' do
        it 'removes indentation' do
          expect(GPGME::Key)
            .to receive(:import)
            .with("-----BEGIN PGP PUBLIC KEY BLOCK-----\n...\n-----END PGP PUBLIC KEY BLOCK-----\n")
          FTPMVC::GPG::Filter.new(nil, other_filter, recipients: 'john.doe@gmail.com', keys: [
            <<-EOF
              -----BEGIN PGP PUBLIC KEY BLOCK-----
              ...
              -----END PGP PUBLIC KEY BLOCK-----
            EOF
          ])
        end
      end
    end

    describe '#exists?' do
      it 'removes .gpg extension from filename' do
        allow(other_filter)
          .to receive(:exists?)
          .with('/secret/passwords.txt')
        gpg_filter.exists?('/secret/passwords.txt.gpg')
      end
    end
  end
end
