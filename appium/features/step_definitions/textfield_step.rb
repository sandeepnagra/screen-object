# frozen_string_literal: true

When(/^I verify the existence of the text filed return value should be true$/) do
  puts "Checking for the existence of button using exists method. Should be true.  --  #{on(Screen).username_exists?}"
  raise unless on(Screen).username_exists?

  on(Screen).enter_username('adf')
end
