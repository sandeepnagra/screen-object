# frozen_string_literal: true

When(/^I verify the existence of the checkbox$/) do
  puts "Checking for the existence of button using exists method. Should be true.  --  #{on(Screen).remember_me?}"
end

Then(/^I should see the return value as true on checkbox existence$/) do
  raise unless on(Screen).remember_me?

  puts on(Screen).remember_me_checked?
  on(Screen).remember_me_uncheck
  sleep 2
  puts on(Screen).remember_me_checked?
end
