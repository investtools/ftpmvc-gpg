require './spec/spec_helper'
require 'ftpmvc'
require 'ftpmvc/gpg'
require 'net/ftp'


describe FTPMVC::GPG::Filter do
  let(:app) do
    FTPMVC::Application.new do
      
      filter FTPMVC::GPG::Filter, recipients: ['john.doe@gmail.com'], keys: [
        <<-EOF
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v1

          mI0EVGNdYQEEALR159b8du6QsH0lQDx1ImFmdN9qVWHgbcXDK4CKwXMbLwNEsjIn
          LNkGP7ZPtnvodywlV7G+CDcVDa2r7MrLJdk3/idQ25zBVnL8HndkZiEZHj+WEo5u
          sR5uZQSshGjWdl2UKWOJoRCW0PEfNBxJeKbCrksaebXjzgXIJl7Mar6TABEBAAG0
          HUpvaG4gRG9lIDxqb2huLmRvZUBnbWFpbC5jb20+iLgEEwECACIFAlRjXWECGwMG
          CwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEGp4Yp2MJm5hxOQD/jGvwPiKEgHK
          AKUqzMv8RpkfP+hkNMa+clhURYRReo0ISWDsb8XUZsZF84ZhwVshlAHqCVdJb13H
          iK/uSBJpxgEHwzIIn+k1G14HK7DKC7kfheaN0mvS3Tq9sdd5PyWGnQyBiP3OYlmF
          TWa/KEz5IfKs95nSBa1w3Vc9cjpn1YgxuI0EVGNdYQEEALZkxWWXptwEcdtYwdR6
          wgXbmFKjeyhRutGJoAR/SwkDoQBqQhTLh6eFKTL9gHWolAJJm4H0pBwVGsVa5su8
          wXfgIu2Y3rSItwjvof05mlTdqjaMVYM/jiHnfIBVJa/xuQRhkroa1jlK4iVZmKNY
          8qsj6pvKGB0uOj+BHMMnMMz5ABEBAAGInwQYAQIACQUCVGNdYQIbDAAKCRBqeGKd
          jCZuYcXBBACtBmIR5o/m2adUCzYfb/mNlh7eM/bvNMeXXmPsazhl5kp05izqy5Z1
          iSQTnoJ8FKi4ke9GRbpKL4EZ4tWop4QKWAbbojIepR0Q6Ncvv4Ho9N32nmSEEfBU
          UPgZz+71ilscZiuigmFSDhP368qBG6rmaxgOoK4O+wjVJEJzq4Yc8A==
          =NH17
          -----END PGP PUBLIC KEY BLOCK-----
        EOF
      ]
      
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
    it 'encrypts files content' do
      with_application(app) do |ftp|
        ftp.login
        expect(get(ftp, '/encrypted/password.txt.gpg').size).to eq 213
      end
    end
  end
end
