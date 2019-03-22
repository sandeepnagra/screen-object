# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'screen-object'

RSpec::Matchers.define :be_running_process do
  match do |child_process|
    Process.kill(0, child_process.pid) == 1
  rescue Exception => msg
    false
  end

  failure_message do |_child_process|
    'Expected the provided process to be running.'
  end

  failure_message_when_negated do |_child_process|
    'Expected the provided process to not be running.'
  end
end
