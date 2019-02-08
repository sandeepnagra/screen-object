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

  def gesture(x1,y1,x2,y2,duration)
    Appium::TouchAction.new($driver).swipe(start_x: x1, start_y: y1, end_x: x2, end_y: y2,duration: duration).perform
  rescue
    raise("Error during gesture")
  end

  def scroll(direction = :down, duration = 1000)
    size = driver.window_size
    x = size.width/2
    y = size.height/2
    case direction
    when :up then loc = [x, y*0.5, x, (y + (y*0.5)),duration]
    when :down then loc =[x, y, x, y * 0.5,duration]
    when :left then loc = [x * 0.6, y, x * 0.3, y,duration]
    when :right then loc =[x * 0.3, y, x * 0.6, y,duration]
    else
      raise('Only upwards and downwards scrolling are supported')
    end
    gesture(loc[0],loc[1],loc[2],loc[3],loc[4])
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

  def swipe_element(locator, direction = :down, duration = 1000)
    my_element = driver.find_element(locator.locator.first,locator.locator.last).rect
    start_x = my_element.x
    end_x = my_element.x + my_element.width
    start_y = my_element.y
    end_y = my_element.y + my_element.height
    height = my_element.height
    case direction
    when :up then  loc = [end_x * 0.5, (start_y + ( height * 0.2)), end_x * 0.5, (end_y - (height * 0.2)),duration]
    when :down then  loc = [end_x * 0.5, (end_y - (height * 0.2)), start_x * 0.5, (start_y + (height * 0.3)), duration]
    when :left then  loc = [end_x * 0.9,  end_y - (height/2), start_x, end_y - (height/2), duration]
    when :right then  loc = [end_x * 0.1, end_y - (height/2), end_x * 0.9, end_y - (height/2), duration]
    else
      raise('Only upwards and downwards scrolling are supported')
    end
    gesture(loc[0],loc[1],loc[2],loc[3],loc[4])
  end
  
  def scroll_find(locator, direction = 'down', num_loop = 15)
    driver.manage.timeouts.implicit_wait = 1
    for i in 0..num_loop
      begin
        if driver.find_element(locator.locator.first,locator.locator.last).displayed?
          break
        end
      rescue
        scroll(direction)
        false
      end
      raise("#{locator.locator} is not displayed") if i==num_loop
    end
  end

  def scroll_to_click(locator, direction)
    scroll_find(locator, direction)
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
