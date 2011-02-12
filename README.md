# Log Weasel

Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances. This particularly handy if you're using a system like <a href="http://www.splunk.com">Splunk</a> to manage your log files across many applications and application instances.

## Installation

Add log_weasel to your Gemfile:

<pre>
gem 'log_weasel'
</pre>

Use bundler to install it:

<pre>
bundle install
</pre>

## Rack

Log Weasel provides Rack middleware to create and destroy a transaction for every HTTP request.

### Rails 3

To see Log Weasel transaction IDs in your Rails logs, you need to add the Rack middleware and
either use the BufferedLogger provided or customize the formatting of your logger to include
<code>LogWeasel::Transaction.id</code>.

<pre>
YourApp::Application.configure do
  logger = LogWeasel::BufferedLogger.new "#{Rails.root}/log/#{Rails.env}.log"
  config.logger                   = logger
  config.action_controller.logger = logger
  config.active_record.logger     = logger

  config.middleware.insert_before Rails::Rack::Logger,
                                  LogWeasel::Middleware, :key => 'YOUR_APP'
end
</pre>

## Resque

To see Log Weasel transaction IDs in your Resque logs, you need to need to initialize Log Weasel
when you configure Resque, for example in a Rails initializer.

<pre>
LogWeasel::Resque.initialize! 'YOUR_APP'
</pre>



## LICENSE

Released under the MIT License. See the LICENSE file for further details.