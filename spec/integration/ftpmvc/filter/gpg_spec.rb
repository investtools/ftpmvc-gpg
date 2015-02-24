require './spec/spec_helper'
require 'ftpmvc'
require 'ftpmvc/gpg'
require 'net/ftp'


describe FTPMVC::Filter::Gpg do
  let(:encrypted_dir) { EncryptedDirectory.new(name: 'encrypted') }
  let(:app) do
    dir = encrypted_dir
    FTPMVC::Application.new do
      
      filter FTPMVC::Filter::Gpg, passphrase: 'mypassphrase', recipients: ['john.doe@gmail.com'], keys: [
        "-----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1

        mI0EVOyxnQEEALTim9Dk3e8UgzGltjsKBZi1blSSqH2sYSH6MQXHRDoeV0R/32oJ
        OlWJ07INSy0DfX+XZupFk5yXkqM3Q9Vqrj2DUXAP1d/I4kBI/WOu6CL/bW5f45Vg
        wQ8gKcowrniFMte8/1S98LneNQlViJiowmCsib7MfJCew/4BYHpnwd/TABEBAAG0
        HUpvaG4gRG9lIDxqb2huLmRvZUBnbWFpbC5jb20+iLgEEwECACIFAlTssZ0CGwMG
        CwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEAwbIKSlGNiWD7sD/Rmo9JlTFukC
        7tbwHEz9q2D4hB7OZAVLlVhUszwJ0gZOb+cG55L59f/M4nSE7gC995d+2DuncZoC
        NP48NWJMVzecTMDu1lcxTJ2pFVa7626kdwKH8QkM6NG0+E5kl5uaF2mUzcWpHF9t
        U5uYmIUXxNghyKJE3/EqzLpJGtWqGd93uI0EVOyxnQEEANoIiUR0mI53Vn1/y2tx
        NRfcweOxytHZFMkSUyE6lQcllU6tkQCBL60MWBEtNKvTulC7ciw/SbxID/ugTo4Q
        lbnRNIyZTitnhzOPUD/OqvT1VE4+mi9fgaaIzKBu9OVVqAWh3ySo0SKQOJGKC15K
        rMZJNek1DmtGwj0KiAFkxg3DABEBAAGInwQYAQIACQUCVOyxnQIbDAAKCRAMGyCk
        pRjYlvddBACGn75Uer8DbRw+YjK454J3JB1g745ASE5H4WRVR/VjxTpwZ96+fcJQ
        SS/MEvVJjG3hoe8Li55dJPOwefr6y2fkxIHrkeNVFCIz9ACfQCYdXGoEYX9MqucI
        spD7r/SHY1ecipvzHCvcD6VaoPKmsck9XaWqt/jMx2Cp75MC1dd6tg==
        =I7Sh
        -----END PGP PUBLIC KEY BLOCK-----",
        "-----BEGIN PGP PRIVATE KEY BLOCK-----
        Version: GnuPG v1

        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
        +MzHYKnvkwLV13q2
        =GFGp
        -----END PGP PRIVATE KEY BLOCK-----"
      ]
      
      filesystem do
        directory dir
      end
    end
  end

  before do
    class EncryptedDirectory < FTPMVC::Directory
      attr_reader :received_data

      def index
        super + [ FTPMVC::File.new('password.txt') ]
      end

      def get(path)
        StringIO.new('secret')
      end

      def put(path, stream)
        @received_data = stream.read
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
  describe 'PUT/STOR' do
    it 'encrypts files content' do
      with_application(app) do |ftp|
        ftp.login
        ftp.putbinaryfile('spec/fixtures/data.gpg', '/encrypted/password.txt.gpg')
        expect(encrypted_dir.received_data).to eq 'data'
      end
    end
  end
end
