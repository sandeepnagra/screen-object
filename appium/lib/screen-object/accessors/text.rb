# frozen_string_literal: true

# ***********************************************************************************************************
# SPDX-Copyright: Copyright (c) Capital One Services, LLC
# SPDX-License-Identifier: Apache-2.0
# Copyright 2016 Capital One Services, LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# ***********************************************************************************************************

module ScreenObject
  module AppElements
    class Text < AppElements::Element
      def text
        element.text
      end

      def click
        element.click
      end

      def dynamic_text_exists?(dynamic_text)
        dynamic_xpath(dynamic_text).displayed?
      rescue StandardError
        false
      end

      def dynamic_text(dynamic_text)
        dynamic_xpath(dynamic_text).displayed?
        text
      rescue StandardError
        false
      end

      def has_text?(text)
        items = elements
        text_value = ''
        items.each do |item|
          text_value = if driver.device_is_android?
                         item.text.strip
                       else
                         item.text.strip
                       end
          return true if text_value.casecmp?(text.strip.to_s)
        end
        msg = "Expected Text: #{text}  \nFound Text: #{text_value}"
        raise(msg)
      end

      def with_text(text)
        items = elements
        text_value = ''
        items.each do |item|
          text_value = item.attribute('text').strip
          return item if text_value.casecmp?(text.strip.to_s)
        end
        msg = "Unable to find element with text: #{text}"
        raise(msg)
      end
    end
  end
end
