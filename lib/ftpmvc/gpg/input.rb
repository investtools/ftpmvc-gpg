require 'ftpmvc/input'

module FTPMVC
  module GPG
    class Input

      include FTPMVC::Input
      
      def initialize(data)
        @data = data
      end

      def read
        while chunk = @data.read(GPGME::Data::BLOCK_SIZE)
          yield chunk
        end
      end
    end
  end
end
