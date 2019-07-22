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

require 'screen-object'

module ScreenObject
  module AppElements
    class Element
      include ScreenObject
      attr_reader :locator

      def initialize(locator)
        if locator.is_a?(String)
          #warn "#{DateTime.now.strftime("%F %T")} WARN ScreenObject Element [DEPRECATION] Passing the locator as a single string with locator type and value sepaarted by ~ is deprecated and will no longer work in version 2.0.0. Use a hash instead (ex: button(:login, id: 'button_id') lib/screen-object/accessors/element.rb:#{__LINE__}"
          @locator=locator.split("~")
        elsif locator.is_a?(Hash)
          @locator=locator.first
        else
          raise "Invalid locator type: #{locator.class}"
        end
      end

      def driver
        $driver
      end

      def tap
          element.click
      end
      alias_method :click, :tap

      def value
          element.value
      end

      def exists?
        driver.no_wait if driver
        begin
          element.displayed?
        rescue
          false
        end
      end

      def element
        driver.find_element(:"#{locator[0]}",locator[1])
      end

      def elements
        driver.find_elements(:"#{locator[0]}",locator[1])
      end

      def element_attributes
        %w[name resource-id value text]
      end

      # method for returning element position and size.
      # @return [hash]
      def get_position
        my_element = element.rect
        {
            start_x: my_element.x,
            end_x: my_element.x + my_element.width,
            start_y: my_element.y,
            end_y: my_element.y + my_element.height,
            height: my_element.height,
            width: my_element.width
        }
      rescue RuntimeError => err
        raise("Error Details: #{err}")
      end

      def dynamic_xpath(text)
        concat_attribute=[]
        element_attributes.each{|i| concat_attribute << %Q(contains(@#{i}, '#{text}'))}
        puts  "//#{locator[0]}[#{concat_attribute.join(' or ')}]"
        locator1="xpath~//#{locator[0]}[#{concat_attribute.join(' or ')}]"
        @locator=locator1.split("~")
        element
      end

      def dynamic_text_exists? dynamic_text
        begin
          dynamic_xpath(dynamic_text).displayed?
        rescue
          false
        end
      end

      # method for checking if element is visible.
      # Some locators on ios and android return true/false but a few would generate and error.
      # this is the reason why there is a else condition and a rescue.
      # @param [direction] 'default :down, :up'
      # @return [boolean]
      def element_visible?
        default_wait = driver.default_wait if driver
        driver.no_wait if driver
        if exists?
          driver.set_wait(default_wait) if driver
          true
        else
          false
        end
      rescue RuntimeError
        false
      end

      # method for scrolling until element is visible.
      # this will NOT return any value.
      # @param [direction] 'Down', 'up'
      def scroll_element_to_view(direction = :down, time_out = 30)
        wait_until(time_out,'Unable to find element') do
          return true if element_visible?
          scroll(direction)
        end
      end

      # method for scrolling until element is visible and click.
      # this will NOT return any value.
      # @param [direction] 'Down', 'up'
      def scroll_element_to_tap(direction= :down, time_out = 40)
        wait_until(time_out,'Unable to find element') do
          if element_visible?
            click
            true
          else
            scroll(direction)
          end
        end
      end
      alias_method :scroll_element_to_click, :scroll_element_to_tap

      # method for swiping a specific element on the screen.
      # this is the reason why there is a else condition and a rescue.
      # @param [direction] :down, :up , :left, :right
      # @param [duration] 1000 milliseconds

      def swipe_screen_element(direction = :down, duration = 1000)
        my_element = element.rect
        start_x = my_element.x
        end_x = my_element.x + my_element.width
        start_y = my_element.y
        end_y = my_element.y + my_element.height
        height = my_element.height
        loc = case direction
              when :up then    [end_x * 0.5, (start_y + (height * 0.2)), end_x * 0.5, (end_y - (height * 0.2)), duration]
              when :down then  [end_x * 0.5, (end_y - (height * 0.2)), start_x * 0.5, (start_y + (height * 0.3)), duration]
              when :left then  [end_x * 0.9,  end_y - (height / 2), start_x, end_y - (height / 2), duration]
              when :right then [end_x * 0.1, end_y - (height / 2), end_x * 0.9, end_y - (height / 2), duration]
              else
                raise('Only upwards and downwards scrolling are supported')
              end
        gesture(loc)
      end

      def scroll_element_down
        swipe_screen_element(:down)
      end

      def scroll_element_up
        swipe_screen_element(:up)
      end

      def swipe_element_left
        swipe_screen_element(:left, 2000)
      end

      def swipe_element_right
        swipe_screen_element(:right, 2000)
      end

      def scroll_dynamic_text_to_tap (expected_text)
        if dynamic_xpath(expected_text).displayed?
          click
        else
          scroll
          click
        end
      end
      alias_method :scroll_dynamic_text_to_click, :scroll_dynamic_text_to_tap

      # Find the first element containing value
      # @param value [String] the value to search for
      # @return [Element]
      def get_element_by_text(value)
        if value.to_s.strip.empty?
          raise('parameter for get_element_by_text function cannot be empty string')
        else
          driver.find(value)
        end
      end

      # Find all element children
      # @param identifier [symbol] the identifier to search for
      # @param name [String] element name to search for
      # @return [Elements]
      def get_children(identifier, name)
        element.find_elements(identifier, name)
      end

      # Find all element siblings
      # @param str_xpath [String] the parent xpath identifier to search for
      # @param parent_xpath [String] the xpath identifier to search for
      # @return [Elements]
      def get_parent(str_xpath, parent_xpath)
        element.find_elements(xpath, "//ancestor::*[*[#{str_xpath}]][#{parent_xpath}]")
      end

      # Find all element siblings
      # @param sibling_xpath [String] the xpath identifier to search for
      # @return [Elements] an array of elements
      def get_siblings(sibling_xpath)
        element.find_elements(xpath:"*//following-sibling::#{sibling_xpath}")
      end

      # Find the first element exactly matching value
      # @param value [String] the value to search for
      # @return [Element]
      def get_element_by_exact_text(value)
        if value.to_s.strip.empty?
          raise('parameter for get_element_by_exact_text function cannot be empty string')
        else
          driver.find_exact(value)
        end
      end

      def has_text(text)
        items = elements
        items.each do |item|
          if item.is_a? String
            text_value = if driver.device_is_android?
                           item.text.strip
                         else
                           item.value.strip
                         end
            return true if text_value.casecmp?(text.strip.to_s)
          else
            text_value = item.text
            return true if text_value == text
          end
          false
        end
      end
    end
  end
end
