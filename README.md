# Log Weasel

Instrument Rails and Resque with shared transaction IDs to trace execution of a unit of work across
applications and application instances.

This particularly handy if you're using a system like <a href="http://www.splunk.com">Splunk</a> to manage your log
files across many applications and application instances.

## Installation

Add log_weasel to your Gemfile:

<pre>
gem 'log_weasel'
</pre>

Use bundler to install it:

<pre>
bundle install
</pre>

## Rails 3

For Rails 3, we provide a Railtie that automatically configures and loads Log Weasel.

To see Log Weasel transaction IDs in your Rails logs either use the Logger provided or
customize the formatting of your logger to include <code>LogWeasel::Transaction.id</code>.

<pre>
YourApp::Application.configure do
  config.log_weasel.key = 'YOUR_APP'    # Optional. Defaults to Rails application name.

  logger = LogWeasel::Logger.new "#{Rails.root}/log/#{Rails.env}.log"
  config.logger                   = logger
  config.action_controller.logger = logger
  config.active_record.logger     = logger
end
</pre>


## Other

### Configure

Load and configure Log Weasel with:

<pre>
LogWeasel.configure do |config|
  config.key = "YOUR_APP"
end
</pre>

<code>config.key</code> is a string that will be included in your transaction IDs and is particularly
useful in an environment where a unit of work may span multiple applications. It is optional but you must call
<code>LogWeasel.configure</code>.

### Rack

Log Weasel provides Rack middleware to create and destroy a transaction ID for every HTTP request. You can use it
in a any web framework that supports Rack (Rails, Sinatra,...) by using <code>LogWeasel::Middleware</code> in your middleware
stack.

## Resque

When you configure Log Weasel as described above either in Rails or by explicitly calling <code>LogWeasel.configure</code>,
it modifies Resque to include transaction IDs in all worker logs.

Start your Resque worker with <code>VERBOSE=1</code> and you'll see transaction IDs in your Resque logs.

## Airbrake

If you are using <a href="http://airbrake.io/p">Airbrake</a>, Log Weasel will add the parameter
<code>log_weasel_id</code> to Airbrake errors so that you can track execution through your application stack that
resulted in the error. No additional configuration required.

## Example

In this example we have a Rails app pushing jobs to Resque and a Resque worker that run with the Rails environment loaded.

### HelloController

<pre>
class HelloController &lt; ApplicationController

  def index
    Resque.enqueue EchoJob, 'hello from HelloController'
    Rails.logger.info("HelloController#index: pushed EchoJob")
  end

end
</pre>

### EchoJob

<pre>
class EchoJob
  @queue = :default_queue

  def self.perform(args)
    Rails.logger.info("EchoJob.perform: #{args.inspect}")
  end
end
</pre>

Start Resque with:

<pre>
QUEUE=default_queue rake resque:work VERBOSE=1
</pre>

Requesting <code>http://localhost:3030/hello/index</code>, our development log shows:

<pre>
[2011-02-14 14:37:42] YOUR_APP-WEB-192587b585fa66b19638 48353 INFO

Started GET "/hello/index" for 127.0.0.1 at 2011-02-14 14:37:42 -0800
[2011-02-14 14:37:42] YOUR_APP-WEB-192587b585fa66b19638 48353 INFO   Processing by HelloController#index as HTML
[2011-02-14 14:37:42] YOUR_APP-WEB-192587b585fa66b19638 48353 INFO HelloController#index: pushed EchoJob
[2011-02-14 14:37:42] YOUR_APP-WEB-192587b585fa66b19638 48353 INFO Rendered hello/index.html.erb within layouts/application (1.8ms)
[2011-02-14 14:37:42] YOUR_APP-WEB-192587b585fa66b19638 48353 INFO Completed 200 OK in 14ms (Views: 6.4ms | ActiveRecord: 0.0ms)
[2011-02-14 14:37:45] YOUR_APP-WEB-192587b585fa66b19638 48461 INFO EchoJob.perform: "hello from HelloController"
</pre>

Fire up a Rails console and push a job directly with:

<pre>
> Resque.enqueue EchoJob, 'hi from Rails console'
</pre>

and our development log shows:

<pre>
[2011-02-14 14:37:10] YOUR_APP-RESQUE-a8e54bfb76718d09f8ed 48453 INFO EchoJob.perform: "hi from Rails console"
</pre>

and our resque log shows:

<pre>
***  got: (Job{default_queue} | EchoJob | ["hello from HelloController"] | {"log_weasel_id"=>"SAMPLE_APP-WEB-a65e45476ff2f5720e23"})
***  Running after_fork hook with [(Job{default_queue} | EchoJob | ["hello from HelloController"] | {"log_weasel_id"=>"SAMPLE_APP-WEB-a65e45476ff2f5720e23"})]
*** SAMPLE_APP-WEB-a65e45476ff2f5720e23 done: (Job{default_queue} | EchoJob | ["hello from HelloController"] | {"log_weasel_id"=>"SAMPLE_APP-WEB-a65e45476ff2f5720e23"})

***  got: (Job{default_queue} | EchoJob | ["hi from Rails console"] | {"log_weasel_id"=>"SAMPLE_APP-RESQUE-00919a012476121cf89c"})
***  Running after_fork hook with [(Job{default_queue} | EchoJob | ["hi from Rails console"] | {"log_weasel_id"=>"SAMPLE_APP-RESQUE-00919a012476121cf89c"})]
*** SAMPLE_APP-RESQUE-00919a012476121cf89c done: (Job{default_queue} | EchoJob | ["hi from Rails console"] | {"log_weasel_id"=>"SAMPLE_APP-RESQUE-00919a012476121cf89c"})
</pre>

Units of work initiated from Resque, for example if using a scheduler like
<a href="https://github.com/bvandenbos/resque-scheduler">resque-scheduler</a>,
will include 'RESQUE' in the transaction ID to indicate that the work started in Resque.

## Contributing

If you would like to contribute a fix or integrate Log Weasel transaction tracking into another frameworks
please fork the code, add the fix or feature in your local project and then send a pull request on github.
Please ensure that you include a test which verifies your changes.

## Authors

<a href="http://github.com/asalant">Alon Salant</a> and <a href="http://github.com/brettfishman">Brett Fishman</a>.

## LICENSE

Copyright (c) 2011 Carbon Five. See LICENSE for details.