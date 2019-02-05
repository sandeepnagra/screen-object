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

module ScreenObject
  module AppElements

    class Element

      attr_reader :locator

      def initialize(locator)
        if locator.is_a?(String)
          # warn "#{DateTime.now.strftime("%F %T")} WARN ScreenObject Element [DEPRECATION] Passing the locator as a single string with locator type and value sepaarted by ~ is deprecated and will no longer work in version 2.0.0. Use a hash instead (ex: button(:login, id: 'button_id') lib/screen-object/accessors/element.rb:#{__LINE__}"
          @locator=locator.split(":")
        elsif locator.is_a?(Hash)
          @locator=locator.first
        else
          raise "Invalid locator type: #{locator.class}"
        end
      end

      def driver
        $driver
      end

      def click
        element.click
      end

      def value
        element.value
      end

      def exists?
        begin
          element.displayed?
        rescue
          false
        end
      end

      def element
        driver.find_element(locator[0],locator[1])
      end

      def elements
        driver.find_elements(:"#{locator[0]}","#{locator[1]}")
      end

      def element_attributes
        %w[name resource-id value text]
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

      def scroll(direction = 'down', touch_count = 1, duration = 1000)
        # driver.execute_script 'mobile: scrollTo',:element => element.ref
        # driver.execute_script("mobile: scroll",:direction => direction.downcase, :element => element.ref)
        size = driver.window_size
        x = size.width/2
        y = size.height/2
        if direction != 'up' && direction != 'down' && direction != 'left' && direction != 'right'
          CXA.output_text 'Only upwards and downwards and leftwards and rightwards scrolling are supported for now'
        end
        if direction == 'up'
          Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y*0.5), end_x: x, end_y: y + (y*0.5),:touchCount => touch_count,:duration => duration).perform
        elsif direction == 'down'
          Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y).to_int, end_x: (x), end_y: y * 0.5,:touchCount => touch_count,:duration => duration).perform
        elsif direction == 'left'
          Appium::TouchAction.new(driver).swipe(start_x: (x * 0.6), start_y: y, end_x: (x * 0.3), end_y: y,:touchCount => touch_count,:duration => duration).perform
        else direction == 'right'
        Appium::TouchAction.new(driver).swipe(start_x: (x * 0.3), start_y: y, end_x: (x * 0.6), end_y: y,:touchCount => touch_count,:duration => duration).perform
        end
      end

      def scroll_find(name, direction = 'down', num_loop = 15)
        driver.manage.timeouts.implicit_wait = 1
        for i in 0..num_loop
          begin
            if (element.displayed?)
              puts "scroll #{direction} to #{name}"
              break
            end
          rescue
            scroll(direction)
            raise("could not find element: #{name} on screen") if (i==num_loop)
            false
          end
        end
      end

      def scroll_element(name, direction = 'down')
        # element = driver.find_element(locator[0],self.locator[1])
        if element.displayed?
          driver.manage.timeouts.implicit_wait = 1
          touch_count = 1, duration = 1000
          element_details = element.rect
          start_x = element_details.x
          end_x = element_details.x + element_details.width
          start_y = element_details.y
          end_y = element_details.y + element_details.height
          if direction == "up"
            Appium::TouchAction.new(driver).swipe(start_x: end_x * 0.5, start_y: (start_y + (element_details.height * 0.2)), end_x: end_x * 0.5, end_y: (end_y - (element_details.height * 0.2)),:touchCount => touch_count,:duration => duration).perform
          elsif direction == "down"
            Appium::TouchAction.new(driver).swipe(start_x: end_x * 0.5, start_y: (end_y - (element_details.height * 0.2)), end_x: start_x * 0.5, end_y: (start_y + (element_details.height * 0.3)),:touchCount => touch_count,:duration => duration).perform
          elsif direction == "left"
            Appium::TouchAction.new(driver).swipe(start_x: end_x * 0.9, start_y: end_y - (element_details.height/2), end_x: start_x, end_y: end_y - (element_details.height/2),:touchCount => 2,:duration => 0).perform
          else direction == "right"
          Appium::TouchAction.new(driver).swipe(start_x: end_x * 0.1, start_y: end_y - (element_details.height/2), end_x: end_x * 0.9, end_y: end_y - (element_details.height/2),:touchCount => 2,:duration => 0).perform
          end
        end
      rescue
        raise("#{name} is not displayed") if i==num_loop
      end

      def scroll_to_text(text, direction = 'down')
        driver.manage.timeouts.implicit_wait = 1
        for i in 0..num_loop
          begin
            if element.displayed?
              puts "scroll #{direction} and found element: #{text}"
              break
            end
          rescue
            scroll(direction)
            false
          end
          raise("#{text} is not displayed") if i==num_loop
        end
      end

      def scroll_to_exact_text(text)
        scroll_to_text(text)
      end

      def scroll_for_element_click(name, direction, num_loop = 15)
        driver.manage.timeouts.implicit_wait = 1
        for i in 0..num_loop
          begin
            if (element.displayed?)
              element.click
              puts "Clicked on element: #{name}"
              break
            end
          rescue
            scroll(direction)
            false
          end
          raise("#{name} is not displayed") if i==num_loop
        end
      end

      def scroll_for_dynamic_element_click (expected_text,num_loop = 15)
        driver.manage.timeouts.implicit_wait = 1
        for i in 0..num_loop
          if dynamic_xpath(expected_text).displayed?
            element.click
            puts "Clicked on #{expected_text}"
            break
          else
            scroll
            element.click
          end
        end
      rescue
        raise("#{expected_text} is not displayed") if i==num_loop
      end

      def click_text(text, direction=:down)
        driver.manage.timeouts.implicit_wait = 0
        for i in 0..num_loop
          begin
            if driver.find("#{text}").display.nil?
              driver.find("#{text}").click
              puts "clicked on text:  #{text}"
              break
            end
          rescue
            scroll(direction)
            false
          end
          raise("#{text} is not displayed") if i==num_loop
        end
      end

      def click_dynamic_text(text)
        if dynamic_text_exists?(text)
          element.click
        else
          scroll_to_text(text)
          element.click
        end
      end

      def click_exact_text(text)
        if exists?
          click
        else
          scroll_to_exact_text(text)
          element.click
        end
      end

      def click_dynamic_exact_text(text)
        if dynamic_text_exists?(text)
          element.click
        else
          scroll_to_exact_text(text)
          element.click
        end
      end

    end
  end
end
