require 'ftpmvc'
require 'ftpmvc/gpg'
require 'net/ftp'


describe FTPMVC::GPG::Filter do
  around do |example|

    class EncryptedDirectory < FTPMVC::Directory
      def index
        super + [ FTPMVC::File.new('password.txt') ]
      end

      def get(path)
        StringIO.new('secret')
      end
    end

    app = FTPMVC::Application.new do
      
      filter FTPMVC::GPG::Filter, recipients: 'john.doe@gmail.com'
      
      filesystem do
        directory :encrypted
      end
    end

    FTPMVC::Server.new('127.0.0.1', 0).start(app) do |server|
      begin
        @port = server.port
        example.run
      ensure
        server.stop
      end
    end
  end

  before do
    stub_const 'Net::FTP::FTP_PORT', @port
    allow_any_instance_of(EncryptedDirectory)
      .to receive(:list)
      .and_return [ FTPMVC::File.new('songs.txt') ]
  end

  describe 'LIST' do
    it 'includes .gpg to filenames extension' do
      Net::FTP.open('127.0.0.1') do |ftp|
        ftp.login
        expect(ftp.list('/encrypted')).to include(/password.txt.gpg/)
      end
    end
  end
  describe 'GET/RETR' do
    it 'encrypts files content' do
      Net::FTP.open('127.0.0.1') do |ftp|
        ftp.login
        response = ''
        ftp.retrbinary('RETR /encrypted/password.txt.gpg', 1024) do |block|
          response << block
        end
        expect(response.size).to eq 342
      end
    end
  end
end
