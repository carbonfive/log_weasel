$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'combustion'
require 'stitch_fix/log_weasel'

Combustion.initialize!

require 'rspec'

begin
  require 'securerandom'
rescue
  require 'active_support/secure_random'
end

RSpec.configure do |config|
  config.mock_with :rspec
end
