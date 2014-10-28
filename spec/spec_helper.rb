require 'ftpmvc/test_helpers'

RSpec.configure do |config|
  config.include FTPMVC::TestHelpers
  config.before :each do
    ActiveSupport::Dependencies.clear
  end
end