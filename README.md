# Log Weasel

Instrument Rails and Resque with shared transaction IDs so that you trace execution across instances. This particularly handy if you're using a system link <a href="http://www.splunk.com">Splunk</a> to manage your log files across many applications and application instances.

## Installation

Add log-weasel to your Gemfile:

<pre>
gem 'log-weasel'
</pre>

Use bundler to install it:

<pre>
bundle install
</pre>

## LICENSE

Released under the MIT License. See the LICENSE file for further details.