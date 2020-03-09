=begin
***********************************************************************************************************
SPDX-Copyright: Copyright (c) Capital One Services, LLC
SPDX-License-Identifier: Apache-2.0
Copyright 2016 Capital One Services, LLC
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License. 
***********************************************************************************************************
=end

=begin
::README FOR THIS FILE::
To save time with each method comments here is the run down of the methods

Each method generates a new method that performs a certain action on the element

FOR EXAMPLE:
```Button.new(xpath: 'UIButtonField')```
      :: can also be defined as ::
```button(:login_button, "xpath~//UIButtonField")```

now we can call as methods anywhere we have instantiated the screen-object method calls:
`login_button`      # defaults to click for button elements(varies by element type)
`login_button_text` # returns the text/value for the login button
`login_button?`     # returns if the element #visible attribute

  and so on, there are many scroll methods and a few other utility methods
=end

module ScreenObject

  # contains  module level methods that are added into your screen objects.
  # when you include the ScreenObject module.  These methods will be generated as services for screens.

  # include Gem 'screen-object' into project Gemfile to add this Gem into project.
  # include require 'screen-object' into environment file. doing this , it will load screen object methods for usage..

  module Accessors

    # Button class generates all the methods related to different operations that can be performed on the button.
    # DEFAULT ACTION:: .click
    def button(name, locator)

      # generates method for clicking the button.
      define_method(name) do
        ScreenObject::AppElements::Button.new(locator).tap
      end

      # generates a method for underlying ScreenObject element
      # @returns [ScreenObject::AppElements::Button]
      define_method("#{name}_element") do
        ScreenObject::AppElements::Button.new(locator)
      end

      # generates a method for element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::Button.new(locator).exists?
      end

      # generates a method for element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::Button.new(locator).enabled?
      end

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates method for element.attribute("text")
      # @return [String]
      define_method("#{name}_text") do
        if driver.device_is_android?
          ScreenObject::AppElements::Button.new(locator).text
        else
          ScreenObject::AppElements::Button.new(locator).value
        end
      end
      alias_method :"#{name}_value", :"#{name}_text"

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::Button.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      ## Scroll Methods Below ##

      # generates method for scrolling on the screen and click on the button.
      # scroll to the first element with locator and click.
      # this method will not return any value.
      define_method("scroll_down_to_tap_#{name}") do
        ScreenObject::AppElements::Button.new(locator).scroll_element_to_tap
      end
      alias_method :"scroll_down_to_click_#{name}", :"scroll_down_to_tap_#{name}"

      # generates method for scrolling on the screen and click on the button.
      # scroll to the first element with locator and click.
      # this method will not return any value.
      define_method("scroll_up_to_tap_#{name}") do
        ScreenObject::AppElements::Button.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"

      # generates method for scrolling down on the screen to the button.
      # scroll to the first element with locator.
      # this method will not return any value.
      define_method("scroll_down_to_#{name}") do
        # direction = options[:direction] || 'down', 'up'
        ScreenObject::AppElements::Button.new(locator).scroll_element_to_view
      end

      # generates method for scrolling up on the screen to the button.
      # scroll to the first element with locator.
      # this method will not return any value.
      define_method("scroll_up_to_#{name}") do
        ScreenObject::AppElements::Button.new(locator).scroll_element_to_view(:up)
      end

      # generates method for scrolling on iOS application screen and click on button. This method should be used when button text is dynamic..
      # this should be used for iOS platform.
      # scroll to the first element with exact target dynamic text or name.
      # this method will not return any value.
      # @param [text] is the actual text of the button containing.
      # DSL to scroll on iOS application screen and click on button. This method should be used when button text is dynamic..
      # button(:login_button,"UIButtonField")  # button API should have class name as shown in this example.
      # OR
      # button(:login_button,"UIButtonField/UIButtonFieldtext")  # button API should have class name as shown in this example.
      # def scroll_button
      #   login_button_scroll_dynamic(text)    # This will not return any value. we need to pass button text or name as parameter.
      #                                          It will scroll on the screen until object with same name found and click on
      #                                          the object i.e. button. This is iOS specific method and should not be used
      #                                          for android application.
      # end
      define_method("#{name}_scroll_dynamic") do |text|
        ScreenObject::AppElements::Button.new(locator).scroll_for_dynamic_element_tap(text)
      end

      # generates method for scrolling on Android application screen and click on button. This method should be used when button text is static...
      # this should be used for Android platform.
      # scroll to the first element containing target static text or name.
      # this method will not return any value.
      # DSL to scroll on Android application screen and click on button. This method should be used when button text is static...
      # @param [text] is the actual text of the button containing.
      # button(:login_button,"xpath~//UIButtonField")
      # def scroll_button
      #   login_button_scroll_(text)  # This will not return any value. we need to pass button text or
      #                                 name[containing targeted text or name] as parameter.It will scroll on the
      #                                 screen until object with same name found and click on the
      #                                 object i.e. button. This is Android specific method and should not be used
      #                                 for iOS application. This method matches with containing text for the
      #                                 button on the screen and click on it.
      # end
      define_method("#{name}_scroll_") do |text|
        ScreenObject::AppElements::Button.new(locator).tap_text(text)
      end

      # generates method for scrolling on Android application screen and click on button. This method should be used when button text is dynamic......
      # this should be used for Android platform.
      # scroll to the first element containing target dynamic text or name.
      # this method will not return any value.
      # DSL to scroll on Android application screen and click on button. This method should be used when button text is dynamic......
      # @param [text] is the actual text of the button containing.
      # button(:login_button,"UIButtonField")  # button API should have class name as shown in this example.
      # OR
      # button(:login_button,"UIButtonField/UIButtonFieldtext")  # button API should have class name as shown in this example.
      #
      # def scroll_button
      #   login_button_scroll_dynamic_(text) # This will not return any value. we need to pass button text or name
      #                                        [containing targeted text or name] as parameter.It will scroll on the screen
      #                                        until object with same name found and click on the object i.e. button.
      #                                        This is Android specific method and should not be used for iOS application.
      #                                        This method matches with containing text for the button on the screen and click on it.
      #
      # end
      define_method("#{name}_scroll_dynamic_") do |text|
        ScreenObject::AppElements::Button.new(locator).tap_dynamic_text(text)
      end

      # generates method for scrolling on the screen and click on the button.
      # this should be used for Android platform.
      # scroll to the first element with exact target static text or name.
      # this method will not return any value.
      # DSL to scroll on Android application screen and click on button. This method should be used when button text is static. it matches with exact text.
      # @param [text] is the actual text of the button containing.
      # button(:login_button,"xpath~//UIButtonField")
      # def scroll_button
      #   login_button_scroll_exact_(text)       # This will not return any value. we need to pass button text or name
      #                                            [EXACT text or name] as parameter. It will scroll on the screen until
      #                                            object with same name found and click on the object i.e. button.
      #                                            This is Android specific method and should not be used for iOS application.
      #                                            This method matches with exact text for the button on the screen and click on it.
      #
      # end
      define_method("#{name}_scroll_exact_") do |text|
        ScreenObject::AppElements::Button.new(locator).tap_exact_text(text)
      end

      # generates method for scrolling on the screen and click on the button.
      # This should be used for Android platform.
      # Scroll to the first element with exact target dynamic text or name.
      # this method will not return any value.
      # DSL to scroll on Android application screen and click on button. This method should be used when button text is dynamic. it matches with exact text.
      # @param [text] is the actual text of the button containing.
      # button(:login_button,"UIButtonField")  # button API should have class name as shown in this example.
      # OR
      # button(:login_button,"UIButtonField/UIButtonFieldtext")  # button API should have class name as shown in this example.
      # def scroll_button
      #   login_button_scroll_dynamic_exact_(text) # This will not return any value. we need to pass button text or name
      #                                             [EXACT text or name] as parameter. It will scroll on the screen until object
      #                                             with same name found and click on the object i.e. button. This is Android specific
      #                                             method and should not be used for iOS application. This method matches with exact
      #                                             text for the button on the screen and click on it.
      #
      # end
      define_method("#{name}_scroll_dynamic_exact_") do |text|
        ScreenObject::AppElements::Button.new(locator).tap_dynamic_exact_text(text)
      end
    end
    # end of button class.


    # Checkbox class generates all the methods related to different operations that can be performed on the check box on the screen.
    # DEFAULT ACTION:: .click the checkbox
    def checkbox(name, locator)

      # generates method for tapping the checkbox. checked, or unchecked this will still proc.
      define_method(name) do
        ScreenObject::AppElements::CheckBox.new(locator).tap
      end

      # generates method for returning the underlying ScreenObject element to allow
      # @return [ScreenObject::AppElements::CheckBox]
      define_method("#{name}_element") do
        ScreenObject::AppElements::CheckBox.new(locator)
      end

      # generates a method for returning element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::CheckBox.new(locator).exists?
      end

      # generates a method for element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::CheckBox.new(locator).enabled?
      end

      # generates a method for returning element.attribute("checked")
      # @returns [Boolean]
      define_method("#{name}_checked?") do
        ScreenObject::AppElements::CheckBox.new(locator).checked?
      end

      # generates method for checking the checkbox object, does nothing if already checked.
      # this will not return any value
      define_method("check_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).check
      end

      # generates method for un-checking the checkbox, does nothing if already unchecked.
      # this will not return any value
      define_method("uncheck_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).uncheck
      end

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates method for element.attribute("text")
      # @return [String]
      define_method("#{name}_text") do
        if driver.device_is_android?
          ScreenObject::AppElements::CheckBox.new(locator).text
        else
          ScreenObject::AppElements::CheckBox.new(locator).value
        end
      end
      alias_method :"#{name}_value", :"#{name}_text"

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::CheckBox.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      ## Scroll Methods Below ##

      # generates method for scrolling on the screen and click on the CheckBox.
      # scroll to the first CheckBox with locator and click.
      # this method will not return any value.
      # checkbox(:email_checkbox, id: 'UIButtonField')
      # def scroll_checkbox
      #  scroll_down_to_click_email_checkbox # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. checkbox.
      define_method("scroll_down_to_tap_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).scroll_element_to_tap(:down)
      end
      alias_method :"scroll_down_to_click_#{name}", :"scroll_down_to_tap_#{name}"

      # generates method for scrolling on the screen and click on the CheckBox.
      # scroll to the first CheckBox with locator and click.
      # this method will not return any value.
      # checkbox(:email_checkbox, id: 'UIButtonField')
      # def scroll_checkbox
      #  scroll_up_to_click_email_checkbox # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. checkbox.
      define_method("scroll_up_to_tap_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"

      # generates method for scrolling on the screen until checkbox is visible.
      # scroll to the first CheckBox with locator.
      # this method will not return any value.
      # checkbox(:email_checkbox, id: 'UIButtonField')
      # def scroll_checkbox
      #  scroll_down_to_email_checkbox # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. checkbox.
      define_method("scroll_down_to_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).scroll_element_to_view
      end

      # generates method for scrolling on the screen until checkbox is visible.
      # scroll to the first CheckBox with locator.
      # this method will not return any value.
      # checkbox(:email_checkbox, id: 'UIButtonField')
      # def scroll_checkbox
      #  scroll_up_to_email_checkbox # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. checkbox.
      define_method("scroll_up_to_#{name}") do
        ScreenObject::AppElements::CheckBox.new(locator).scroll_element_to_view(:up)
      end
    end

    # Text class generates all the methods related to different operations that can be performed on the text object on the screen.
    # DEFAULT ACTION:: return the value/text
    def text(name,locator)

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates a method to return element.attribute("text")
      # @return [String]
      define_method(name) do
        if driver.device_is_android?
          ScreenObject::AppElements::Text.new(locator).text
        else
          ScreenObject::AppElements::Text.new(locator).value
        end
      end
      alias_method :"#{name}_text", :"#{name}"

      # generates a method to return underlying ScreenObject element
      # @return [ScreenObject::AppElements::Text]
      define_method("#{name}_element") do
        ScreenObject::AppElements::Text.new(locator)
      end

      # generates a method for returning element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::Text.new(locator).exists?
      end

      # generates a method for element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::Button.new(locator).enabled?
      end

      # generates a method for clicking the element
      # @returns [Boolean]
      define_method("tap_#{name}") do
        ScreenObject::AppElements::Text.new(locator).tap
      end
      alias_method :"click_#{name}", :"tap_#{name}"

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::Text.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      # generates method for checking dynamic text object.
      # this will return actual test for an object.
      # @example check if 'Welcome' text is displayed on the page
      # @param [text] is the actual text of the button containing.
      # suppose 'Welcome guest' text appears on the screen for non logged in user and it changes when user logged in on the screen and appears as 'Welcome <guest_name>'. this would be treated as dynamic text since it would be changing based on guest name.
      # DSL to check if the text that is sent as argument exists on the screen. Returns true or false
      # text(:welcome_guest,"xpath~//UITextField")
      # def dynamic_welcome_guest(Welcome_<guest_name>)
      # welcome_text_dynamic?(welcome_<guest_name>)  # This will return true or false based welcome text exists on the screen.
      # end
      define_method("#{name}_dynamic_text") do |text|
        ScreenObject::AppElements::Text.new(locator).dynamic_text(text)
      end

      define_method("#{name}_has_text?") do |text|
        ScreenObject::AppElements::Text.new(locator).has_text(text)
      end

      define_method("#{name}_elements") do
        ScreenObject::AppElements::Text.new(locator).elements
      end

      ## Scroll Methods Below ##

      # generates method for scrolling on the screen and click on the text.
      # scroll to the first CheckBox with locator and click.
      # this method will not return any value.
      # checkbox(:first_name, id: 'my_name')
      # def scroll_text
      #  scroll_up_to_click_first_name # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. Text.
      define_method("scroll_up_to_tap_#{name}") do
        # direction = options[:direction] || 'up'
        ScreenObject::AppElements::Text.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"

      # generates method for scrolling on the screen and click on the text.
      # scroll to the first CheckBox with locator and click.
      # this method will not return any value.
      # checkbox(:first_name, id: 'my_name')
      # def scroll_text
      #  scroll_down_to_click_first_name # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. Text.
      define_method("scroll_down_to_tap_#{name}") do
        ScreenObject::AppElements::Text.new(locator).scroll_element_to_tap(:down)
      end
      alias_method :"scroll_down_to_click_#{name}", :"scroll_down_to_tap_#{name}"
      # generates method for scrolling text object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' text is displayed on the page
      # text(:welcome_text,"xpath~//UITextField")
      # DSL for scrolling down to the Welcome text.
      # def scroll_welcome_text
      #   scroll_down_to_welcome_text  # This will scroll down to the Welcome text on the screen.
      # end
      define_method("scroll_down_to_#{name}") do
        ScreenObject::AppElements::Text.new(locator).scroll_element_to_view(:down)
      end

      # generates method for scrolling text object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' text is displayed on the page
      # text(:welcome_text,"xpath~//UITextField")
      # DSL for scrolling down to the Welcome text.
      # def scroll_welcome_text
      #   scroll_up_to_welcome_text  # This will scroll down to the Welcome text on the screen.
      # end
      define_method("scroll_up_to_#{name}") do
        # direction = options[:direction] || 'down'
        ScreenObject::AppElements::Text.new(locator).scroll_element_to_view(:up)
      end

      # generates method for checking dynamic text object.
      # this will return true or false based on object is displayed or not.
      # @example check if 'Welcome' text is displayed on the page
      # @param [text] is the actual text of the button containing.
      # suppose 'Welcome guest' text appears on the screen for non logged in user and it changes when user logged in on the screen and appears as 'Welcome <guest_name>'. this would be treated as dynamic text since it would be changing based on guest name.
      # DSL to check if the text that is sent as argument exists on the screen. Returns true or false
      # text(:welcome_guest,"xpath~//UITextField")
      # def dynamic_welcome_guest(Welcome_<guest_name>)
      # welcome_text_dynamic?(welcome_<guest_name>)  # This will return true or false based welcome text exists on the screen.
      # end
      define_method("#{name}_dynamic?") do |text|
        ScreenObject::AppElements::Text.new(locator).dynamic_text_exists?(text)
      end
    end

    # text_field class generates all the methods related to different operations that can be performed on the text_field object on the screen.
    # DEFAULT ACTION: .text/.value
    def text_field(name,locator)

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates a method to return element.attribute("text")
      # @return [String]
      define_method("#{name}") do
        ScreenObject::AppElements::TextField.new(locator).text
      end

      # generates a method to return underlying ScreenObject element
      # @return [ScreenObject::AppElements::TextField]
      define_method("#{name}_element") do
        ScreenObject::AppElements::TextField.new(locator)
      end

      # generates method for setting text into text field.
      # There is no return value for this method.
      # def set_username_text_field(username)
      #   self.username=username   # This method will enter text into username text field.
      # end
      define_method("#{name}=") do |text|
        ScreenObject::AppElements::TextField.new(locator).text=(text)
      end

      # generates method for clear text from the text field element
      define_method("clear_#{name}") do
        ScreenObject::AppElements::TextField.new(locator).clear
      end

      # generates a method for returning element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::TextField.new(locator).exists?
      end

      # generates a method for returning element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::TextField.new(locator).enabled?
      end

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates method for element.attribute("text")
      # @return [String]
      define_method("#{name}_text") do
        if driver.device_is_android?
          ScreenObject::AppElements::TextField.new(locator).text
        else
          ScreenObject::AppElements::TextField.new(locator).value
        end
      end
      alias_method :"#{name}_value", :"#{name}_text"

      # returns the underlying element collection to allow
      # @return [Collection of TextFields]
      # text_field(:login,"xpath~//UITextField")
      # def get_login_elements
      #   login_elements # This will not return the underlying ScreenObject::AppElements::TextField object.
      #                  the return elements can use all the inherited methods of the driver
      #                  like: .click, .text etc. which are needed in certain cases
      # end
      define_method("#{name}_elements") do
        ScreenObject::AppElements::TextField.new(locator).elements
      end

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::TextField.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      ## Scroll Methods Below ##

      # generates method for scrolling text field object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' text is displayed on the page
      # text(:welcome_text_field,"xpath~//UITextField")
      # def scroll_welcome_text_field
      #   scroll_down_to_welcome_text_field  # This will scroll down to the Welcome text field on the screen.
      # end
      define_method("scroll_down_to_#{name}") do
        # direction = 'down'
        ScreenObject::AppElements::TextField.new(locator).scroll_element_to_view
      end

      # generates method for scrolling text field object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' text is displayed on the page
      # text(:welcome_text_field,"xpath~//UITextField")
      # def scroll_welcome_text_field
      #   scroll_up_to_welcome_text_field  # This will scroll up to the Welcome text field on the screen.
      # end
      define_method("scroll_up_to_#{name}") do
        # direction = 'up'
        ScreenObject::AppElements::TextField.new(locator).scroll_element_to_view(:up)
      end

      # generates method for scrolling on the screen and click on the text field.
      # scroll to the first element with locator and click to set focus.
      # this method will not return any value.
      # text(:welcome_textfield,"xpath~//UITextField")
      # def scroll_welcome_text_field
      #  scroll_down_to_click_welcome_textfield # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e.textField                 on the object i.e. image.
      define_method("scroll_down_to_tap_#{name}") do
        # direction = 'down'
        ScreenObject::AppElements::TextField.new(locator).scroll_element_to_tap
      end
      alias_method :"scroll_down_to_click_#{name}",  :"scroll_down_to_tap_#{name}"

      # generates method for scrolling on the screen and click on the image.
      # scroll to the first element with locator and click to set focus.
      # this method will not return any value.
      # text(:welcome_textfield,"xpath~//UITextField")
      # def scroll_welcome_text_field
      #  scroll_up_to_click_welcome_textfield  # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e.textField.
      define_method("scroll_up_to_tap_#{name}") do
        ScreenObject::AppElements::TextField.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"
    end

    # Image class generates all the methods related to different operations that can be performed on the image object on the screen.
    # DEFAULT ACTION:: .click/.tap
    def image(name,locator)

      # generates method for clicking image
      define_method("#{name}") do
        ScreenObject::AppElements::Image.new(locator).tap
      end

      # generates a method to return underlying ScreenObject element
      # @return [ScreenObject::AppElements::Image]
      define_method("#{name}_element") do
        ScreenObject::AppElements::Image.new(locator)
      end

      # generates a method for returning element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::Image.new(locator).exists?
      end

      # generates a method for returning element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::Image.new(locator).enabled?
      end

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates method for element.attribute("text")
      # @return [String]
      define_method("#{name}_text") do
        if driver.device_is_android?
          ScreenObject::AppElements::Image.new(locator).text
        else
          ScreenObject::AppElements::Image.new(locator).value
        end
      end
      alias_method :"#{name}_value", :"#{name}_text"

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::Image.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      ## Scroll Methods Below ##

      # generates method for scrolling image object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' image is displayed on the page
      # text(:welcome_image, id: 'my_image')
      # def scroll_welcome_image
      #   scroll_down_to_welcome_image # This will scroll down to the Welcome image on the screen.
      # end
      define_method("scroll_down_to_#{name}") do
        # direction = options[:direction] || 'down'
        ScreenObject::AppElements::Image.new(locator).scroll_element_to_view(:down)
      end

      # generates method for scrolling image object to view.
      # this will NOT return any value.
      # @example check if 'Welcome' image is displayed on the page
      # text(:welcome_image, id: 'my_image')
      # def scroll_welcome_image
      #   scroll_up_to_welcome_image # This will scroll down to the Welcome image on the screen.
      # end
      define_method("scroll_up_to_#{name}") do
        # direction = options[:direction] || 'down'
        ScreenObject::AppElements::Image.new(locator).scroll_element_to_view(:up)
      end

      # generates method for scrolling on the screen and click on the button.
      # scroll to the first element with locator and click.
      # this method will not return any value.
      # image(:login_image,"xpath~//UIButtonField")
      # def scroll_down_image
      #  scroll_down_to_click_login_image # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. Image.                  on the object i.e. image.
      define_method("scroll_down_to_tap_#{name}") do
        ScreenObject::AppElements::Image.new(locator).scroll_element_to_tap
      end
      alias_method :"scroll_down_to_click_#{name}", :"scroll_down_to_tap_#{name}"

      # generates method for scrolling on the screen and click on the image.
      # scroll to the first element with locator and click.
      # this method will not return any value.
      # image(:login_image,"xpath~//UIButtonField")
      # def scroll_image
      #  scroll_up_to_click_login_image # This will not return any value. It will scroll on the screen until object found and click
      #                        on the object i.e. Image.
      define_method("scroll_up_to_tap_#{name}") do
        ScreenObject::AppElements::Image.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"
    end

    # table class generates all the methods related to different operations that can be performed on the table object on the screen.
    def table(name, locator)
      #generates method for counting total no of cells in table
      define_method("#{name}_cell_count") do
        ScreenObject::AppElements::Table.new(locator).cell_count
      end

      # returns the underlying ScreenObject element to allow
      # use of all inherited AppElements::Element methods
      # this also makes it more consistent with PageObject gem
      # which provides a _element method for any type of accessor
      # @return [ScreenObject::AppElements::Table]
      # table(:monthly_statement,"id~monthStatement")
      # def get_monthly_statement_element
      #   monthly_statement_element # This will not return the underlying ScreenObject::AppElements::Table object
      #                  which can use all the inherited methods of ScreenObject::AppElements::Element
      #                  like: .click, .value, .element etc. which are needed in certain cases
      # end
      define_method("#{name}_element") do
        ScreenObject::AppElements::Table.new(locator)
      end
    end

    # elements class generates all the methods related to general elements operation
    def element(name, locator)

      # generates method for elements object
      define_method("#{name}") do
        ScreenObject::AppElements::Element.new(locator)
      end

      # generates a method for returning element.attribute("visible")
      # @returns [Boolean]
      define_method("#{name}?") do
        ScreenObject::AppElements::Element.new(locator).exists?
      end

      # generates a method for returning element.attribute("enabled")
      # @returns [Boolean]
      define_method("#{name}_enabled?") do
        ScreenObject::AppElements::Element.new(locator).exists?
      end

      # note: Android elements do not contain an attribute for #._value, that is why we do the device check.
      # generates method for element.attribute("text")
      # @return [String]
      define_method("#{name}_text") do
        if driver.device_is_android?
          ScreenObject::AppElements::Element.new(locator).text
        else
          ScreenObject::AppElements::Element.new(locator).value
        end
      end
      alias_method :"#{name}_value", :"#{name}_text"

      # generates a method that returns the .rect of the element
      # @returns [Array]
      define_method("#{name}_position") do
        ScreenObject::AppElements::Element.new(locator).get_position
      end
      alias_method :"#{name}_location", :"#{name}_position"

      # returns the underlying element collection to allow
      # @return [Collection of element]
      # element(:login,"xpath~//UITextField")
      # def get_login_elements
      #   login_elements # This will not return the underlying ScreenObject::AppElements::TextField object.
      #                  the return elements can use all the inherited methods of the driver
      #                  like: .click, .text etc. which are needed in certain cases
      # end
      define_method("#{name}_elements") do
        ScreenObject::AppElements::Element.new(locator).elements
      end

      # generates method for scrolling down on both Android and iOS application screen and click on element.
      # scroll to the first element with locator and click on it.
      # this method will not return any value.
      # element(:login_button,"UIButtonField/UIButtonFieldtext")
      #   click_login_button

      define_method("tap_#{name}") do
        # direction = options[:direction] || 'down'
        ScreenObject::AppElements::Element.new(locator).scroll_element_to_tap
      end
      alias_method :"click_#{name}", :"tap_#{name}"

      # generates method for scrolling down on both Android and iOS application screen and click on element.
      # scroll to the first element with locator and click on it.
      # this method will not return any value.
      # element(:login_button,"UIButtonField/UIButtonFieldtext")
      #   scroll_down_to_click_login_button

      define_method("scroll_down_to_tap_#{name}") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_to_tap
      end
      alias_method :"scroll_down_to_click_#{name}", :"scroll_down_to_tap_#{name}"

      # generates method for scrolling down on both Android and iOS application screen and click on element.
      # scroll to the first element with locator and click on it.
      # this method will not return any value.
      # element(:login_button,"UIButtonField/UIButtonFieldtext")
      #   scroll_up_to_click_login_button

      define_method("scroll_up_to_tap_#{name}") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_to_tap(:up)
      end
      alias_method :"scroll_up_to_click_#{name}", :"scroll_up_to_tap_#{name}"

      # generates method for scrolling down on both Android and iOS application screen.
      # scroll to the first element with locator.
      # this method will not return any value.
      # element(:login_button,"UIButtonField/UIButtonFieldtext")
      #   scroll_down_to_login_button

      define_method("scroll_down_to_#{name}") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_to_view(:down)
      end

      # generates method for scrolling down on both Android and iOS application screen.
      # scroll to the first element with locator.
      # this method will not return any value.
      # element(:login_button,"UIButtonField/UIButtonFieldtext")
      #   scroll_up_to_login_button
      define_method("scroll_up_to_#{name}") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_to_view(:up)
      end

      # generates method for scrolling a specific element on screen
      # This can be used for both IOS and Android platform.
      # Scroll to the element down and up
      # this method will not return any value.
      # element(:vertical_scroll_view, class: 'android.support.v7.widget.RecyclerView')
      # vertical_scroll_view_scroll_down
      define_method("#{name}_scroll_down") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_down
      end

      # generates method for scrolling a specific element on screen
      # This can be used for both IOS and Android platform.
      # Scroll to the element down and up
      # this method will not return any value.
      # element(:vertical_scroll_view, class: 'android.support.v7.widget.RecyclerView')
      # vertical_scroll_view_scroll_up
      define_method("#{name}_scroll_up") do
        ScreenObject::AppElements::Element.new(locator).scroll_element_up
      end

      # generates method for scrolling a specific element on screen
      # This can be used for both IOS and Android platform.
      # Scroll to the element left and right
      # this method will not return any value.
      # element(:change_box, id: 'horizontal_scroll_view')
      # change_box_swipe_left
      define_method("#{name}_swipe_left") do
        ScreenObject::AppElements::Element.new(locator).swipe_element_left
      end

      # generates method for scrolling a specific element on screen
      # This can be used for both IOS and Android platform.
      # Scroll to the element left and right
      # this method will not return any value.
      # element(:change_box, id: 'horizontal_scroll_view')
      # change_box_swipe_right
      define_method("#{name}_swipe_right") do
        ScreenObject::AppElements::Element.new(locator).swipe_element_right
      end
    end
  end # end of Accessors module
end # end of screen object module
