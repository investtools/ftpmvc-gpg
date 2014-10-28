require 'ftpmvc/filter'
require 'gpgme'

module FTPMVC
  module GPG
    class Filter < FTPMVC::Filter
      def initialize(fs, chain, options={})
        super fs, chain
        @crypto = GPGME::Crypto.new recipients: options[:recipients]
      end

      def index(path)
        @chain.index(path).each do |node|
          if node.kind_of?(File) and not ::File.extname(node.name) == '.gpg'
            node.name = "#{node.name}.gpg"
          end
        end
      end

      def get(path)
        StringIO.new(@crypto.encrypt(GPGME::Data.from_io(@chain.get(path))).read)
      end
    end
  end
end
