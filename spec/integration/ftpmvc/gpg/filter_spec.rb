require './spec/spec_helper'
require 'ftpmvc'
require 'ftpmvc/gpg'
require 'net/ftp'


describe FTPMVC::GPG::Filter do
  let(:app) do
    FTPMVC::Application.new do
      
      filter FTPMVC::GPG::Filter, recipients: 'john.doe@gmail.com'
      
      filesystem do
        directory :encrypted
      end
    end
  end

  before do
    class EncryptedDirectory < FTPMVC::Directory
      def index
        super + [ FTPMVC::File.new('password.txt') ]
      end

      def get(path)
        StringIO.new('secret')
      end
    end
  end

  describe 'LIST' do
    it 'includes .gpg to filenames extension' do
      with_application(app) do |ftp|
        ftp.login
        expect(ftp.list('/encrypted')).to include(/password.txt.gpg/)
      end
    end
  end
  describe 'GET/RETR' do
    before do
      allow_any_instance_of(GPGME::Crypto)
        .to receive(:encrypt)
        .and_return StringIO.new('encrypted content')      
    end
    it 'encrypts files content' do
      with_application(app) do |ftp|
        ftp.login
        expect(get(ftp, '/encrypted/password.txt.gpg')).to eq 'encrypted content'
      end
    end
  end
end
