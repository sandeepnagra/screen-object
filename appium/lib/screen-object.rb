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

  def wait_until(timeout = 5, message = nil, &block)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout, message: message)
    wait.until &block
  end

  def wait_step(timeout = 5, message = nil, &block)
    default_wait = driver.default_wait
    wait = Selenium::WebDriver::Wait.new(:timeout => driver.set_wait(timeout), :message => message)
    wait.until &block
    driver.set_wait(default_wait)
  end

  def enter
    #pending implementation
  end

  def scroll(direction = :down, touch_count = 1, duration = 500)
    size = driver.window_size
    x = size.width/2
    y = size.height/2
    if direction != :up && direction != :down && direction != :left && direction != :right
      CXA.output_text 'Only upwards and downwards and leftwards and rightwards scrolling are supported for now'
    end
    if direction == :up
      Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y*0.5), end_x: x, end_y: y + (y*0.5),:touchCount => touch_count,:duration => duration).perform
    elsif direction == :down
      Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y).to_int, end_x: (x), end_y: y * 0.5,:touchCount => touch_count,:duration => duration).perform
    elsif direction == :left
      Appium::TouchAction.new(driver).swipe(start_x: (x * 0.6), start_y: y, end_x: (x * 0.3), end_y: y,:touchCount => touch_count,:duration => duration).perform
    else direction == :right
    Appium::TouchAction.new(driver).swipe(start_x: (x * 0.3), start_y: y, end_x: (x * 0.6), end_y: y,:touchCount => touch_count,:duration => duration).perform
    end
  end
  def swipe_element(locator, direction = :down, touch_count = 1, duration = 500)
    element = driver.find_element(locator.locator.first,locator.locator.last).size
    x = element.width
    y = element.height
    if direction == :up
      Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y*0.5), end_x: x, end_y: y + (y*0.5),:touchCount => touch_count,:duration => duration).perform
    elsif direction == :down
      Appium::TouchAction.new(driver).swipe(start_x: (x), start_y: (y).to_int, end_x: (x), end_y: y * 0.5,:touchCount => touch_count,:duration => duration).perform
    elsif direction == :left
      Appium::TouchAction.new(driver).swipe(start_x: (x * 0.6), start_y: y, end_x: (x * 0.2), end_y: y,:touchCount => touch_count,:duration => duration).perform
    else direction == :right
    Appium::TouchAction.new(driver).swipe(start_x: (x * 0.2), start_y: y, end_x: (x * 0.6), end_y: y,:touchCount => touch_count,:duration => duration).perform
    end

  end
  def scroll_to_text(text_val, direction = :down, num_loop = 15)
    driver.manage.timeouts.implicit_wait = 1
    for i in 0..num_loop
      begin
        if driver.find("#{text_val}").display.nil?
          puts "found element #{text_val}"
          break
        end
      rescue Selenium::WebDriver::Error::NoSuchElementError
        scroll(direction)
        false
      end
      raise("#{text_val} is not displayed") if i==num_loop
    end
  end

  def scroll_find(locator, direction = :down, num_loop = 15)
    driver.manage.timeouts.implicit_wait = 1
    for i in 0..num_loop
      begin
        if (driver.find_element(locator.locator.first,locator.locator.last).displayed?)
          break
        end
      rescue
        scroll(direction)
        false
      end
      raise("#{locator.locator} is not displayed") if i==num_loop
    end
  end

  def scroll_down_click(locator, num_loop = 15)
    driver.manage.timeouts.implicit_wait = 1
    for i in 0..num_loop
      begin
        if (driver.find_element(locator.locator.first,locator.locator.last).displayed?)
          driver.find_element(locator.locator.first,locator.locator.last).click
          break
        end
      rescue
        scroll(:down)
        false
      end
      raise("#{locator.locator} is not displayed") if i==num_loop
    end
  end

  def scroll_up_find(locator, num_loop = 15)
    driver.manage.timeouts.implicit_wait = 1
    for i in 0..num_loop
      begin
        if (driver.find_element(locator.locator.first,locator.locator.last).displayed?)
          break
        end
      rescue
        scroll(:up)
        false
      end
      raise("#{locator.locator} is not displayed") if i==num_loop
    end
  end

  def scroll_up_click(locator, num_loop = 15)
    for i in 0..num_loop
      begin
        if (driver.find_element(locator.locator.first,locator.locator.last).displayed?)
          driver.find_element(locator.locator.first,locator.locator.last).click
          break
        end
        scroll(:up)
        false
      end
      raise("#{locator.locator} is not displayed") if i==num_loop
    end
  end

  def drag_and_drop_element(source_locator,source_locator_value,target_locator,target_locator_value)
    l_draggable = driver.find_element(source_locator,source_locator_value)
    l_droppable = driver.find_element(target_locator,target_locator_value)
    obj1= Appium::TouchAction.new
    obj1.long_press(:x => l_draggable.location.x,:y => l_draggable.location.y).move_to(:x => l_droppable.location.x,:y => l_droppable.location.y).release.perform
  end

  def keyboard_hide
    begin
    driver.hide_keyboard
    rescue
      false
    end
  end
  
end
