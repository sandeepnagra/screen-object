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

require 'appium_lib'
require 'screen-object/load_appium'
require 'screen-object/accessors'
require 'screen-object/elements'
require 'screen-object/screen_factory'
require 'screen-object/accessors/element'

# this module adds screen object when included.
# This module will add instance methods and screen object that you use to define and interact with mobile objects

module ScreenObject

  def self.included(cls)
    cls.extend ScreenObject::Accessors
  end

  def driver
    ScreenObject::AppElements::Element.new('').driver
  end

  def swipe(start_x,start_y,end_x,end_y,touch_count,duration)
    driver.swipe(:start_x => start_x, :start_y => start_y, :end_x => end_x, :end_y => end_y,:touchCount => touch_count,:duration => duration)
  end

  def landscape
    driver.driver.rotate :landscape
  end

  def portrait
    driver.driver.rotate :portrait
  end
  
  def back
    driver.back
  end

  def wait_until(timeout = 30, message = nil, &block)
    default_wait = driver.default_wait if driver
    driver.no_wait if driver
    wait = Selenium::WebDriver::Wait.new(timeout: timeout, message: message)
    wait.until &block
    driver.set_wait(default_wait) if driver
  end

  def wait_step(timeout = 5, message = nil, &block)
    default_wait = driver.default_wait if driver
    wait = Selenium::WebDriver::Wait.new(:timeout => driver.set_wait(timeout), :message => message)
    wait.until &block
    driver.set_wait(default_wait) if driver
  end

  def enter
    driver.send_keys(:enter)
  end

  def gesture(arg)
    Appium::TouchAction.new(driver).swipe(start_x: arg[0], start_y: arg[1], end_x: arg[2], end_y: arg[3], duration: arg[4]).perform
    sleep 0.5
  rescue RuntimeError => e
    raise("Error during gesture \n Error Details: #{e}")
  end

  # Scrolls device screen in a direction
  #
  # @param direction [symbol] The direction to search for an string
  # @param duration   [Integer] The amount of times in seconds we want to scroll to find the element
   # @param distance [float] between 0.1 to 0.9 down from [0.9 .. 0], up [01 .. 0.9]
  def scroll(direction = :down, distance = 0.5, duration = 1000)
    size = driver.window_size
    x = size.width / 2
    y = size.height / 2
    loc = case direction
          when :up then    [x, y, x, (y + (y * distance)), duration]
          when :down then  [x, y, x, y * distance, duration]
          when :left then  [x * 0.6, y, x * 0.3, y, duration]
          when :right then [x * 0.3, y, x * 0.6, y, duration]
          else
            raise('Only up, down, left and right scrolling are supported')
          end
    gesture(loc)
  end

  def scroll_down
    scroll(:down)
  end

  def scroll_up
    scroll(:up)
  end

  def swipe_left
    scroll(:left)
  end

  def swipe_right
    scroll(:right)
  end

  # Scroll Down in a direction until a string that matches is found,
  #
  # @param text      [String] The text you are looking for on the screen
  def scroll_down_to_text(text)
    scroll_text_to_view(text, :down)
  end

  # Scroll Up in a direction until a string that matches is found,
  #
  # @param text      [String] The text you are looking for on the screen
  def scroll_up_to_text(text)
    scroll_text_to_view(text, :up)
  end

  # Scrolls in a direction until a string that matches is found,
  #
  # @param text      [String] The text you are looking for on the screen
  # @param direction [symbol] The direction to search for an string
  # @param timeout   [Integer] The amount of times in seconds we want to scroll to find the element
  # @return          [Boolean]
  def scroll_text_to_view(text, direction = :down, timeout = 40)
    wait_until(timeout,'Unable to find element') do
      return true if text_visible?(text)
      scroll(direction)
      false
    end
  end

  # Scrolls in a direction if a text that matches is not found. return false,  otherwise return true
  # Some locators on ios and android return true/false but a few would generate and error.
  # this is the reason why there is a else condition and a rescue.
  # @param text       [String] The text you are looking for on the screen
  # @return          [Boolean]
  def text_visible?(text)
    driver.no_wait if driver
    if driver.find(text).displayed?
      true
    else
      false
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  # Create an object to exactly match the first element with target value
  # @param value [String] the value to search for
  # @return [String]
  def webview_text_visible?(value)
    driver.string_visible_exact('*', value)
  rescue RuntimeError => e
    raise("Could not find text \"#{value}\" on the current screen: #{e}")
  end

  # Click on the first element with target value that contains search value
  # @param text [String] the value to search for
  # @return [Nil]
  def tap_text(str_pattern = "*", text)
    if driver.device_is_ios?
      driver.string_visible_contains(str_pattern, text).click
    else
      driver.complex_find_contains(str_pattern,text).click
    end
  end
  alias_method :click_text, :tap_text

  # Click exact text that matches the first element with target value
  # @param text [String] the value to search for
  # @return [Nil]
  def tap_exact_text(text)
    driver.find(text).click
  rescue Appium::Core::Wait::TimeoutError => e
    raise("Could not find text \"#{text_val}\" on the current screen: #{e}")
  end
  alias_method :click_exact_text, :tap_exact_text

  def drag_and_drop_element(source_locator,source_locator_value,target_locator,target_locator_value)
    l_draggable = driver.find_element(source_locator,source_locator_value)
    l_droppable = driver.find_element(target_locator,target_locator_value)
    obj1= Appium::TouchAction.new
    obj1.long_press(:x => l_draggable.location.x,:y => l_draggable.location.y).move_to(:x => l_droppable.location.x,:y => l_droppable.location.y).release.perform
  end

  def keyboard_hide
    begin
      driver.hide_keyboard if driver.is_keyboard_shown
    rescue
      false
    end
  end

  def wait_for_text(text, timeout = 30)
    wait_until(timeout,"text << #{text} >> is not visible", & ->{driver.find("#{text}").displayed? })
  end

end
