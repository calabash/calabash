require 'json'

module Calabash
  module Android
    # @!visibility private
    module Gestures
      class MultiTouchGesture
        attr_reader :gestures
        attr_accessor :timeout

        def initialize(gestures = [])
          unless gestures.is_a?(Array)
            gestures = [gestures]
          end

          @gestures = gestures
          @timeout = Calabash::Gestures::DEFAULT_GESTURE_WAIT_TIMEOUT
        end

        def +(gesture_collection)
          MultiTouchGesture.new(@gestures + gesture_collection.gestures)
        end

        def add_gesture
          gestures = @gestures
          MultiTouchGesture.new(gestures + gesture_collection.gestures)
        end

        def <<(gesture)
          @gestures << gesture
        end

        def add_touch(touch, index=0)
          gestures = @gestures
          gestures[index] << touch
          MultiTouchGesture.new(gestures)
        end

        def add_touch!(touch, index=0)
          @gestures = add_touch(touch, index).gestures
        end

        def merge(multi_touch_gesture)
          MultiTouchGesture.new(gestures.map.with_index {|gesture, index| gesture + multi_touch_gesture.gestures[index]})
        end

        def merge!(multi_touch_gesture)
          @gestures = merge(multi_touch_gesture).gestures
        end

        def to_json(*object)
          {
              query_timeout: @timeout.to_f,
              gestures: @gestures
          }.to_json(*object)
        end

        def query=(query)
          @gestures.each {|gesture| gesture.query=query}
        end

        def reset_query
          @gestures.each {|gesture| gesture.reset_query}
        end

        def offset=(offset)
          @gestures.each {|gesture| gesture.offset=offset}
        end

        def max_execution_time
          (@gestures.map {|gesture| gesture.max_execution_time}).max
        end

        def queries
          gestures.map(&:queries).flatten.uniq.reject(&:nil?)
        end
      end

      class Gesture
        attr_reader :touches

        def initialize(touches = [], query = nil)
          unless touches.is_a?(Array)
            touches = [touches]
          end

          @touches = []

          touches.each do |touch|
            @touches << Touch.new(touch)
          end

          @query = query
        end

        def from(touch)
          to(touch)
        end

        def to(touch)
          if touch.is_a?(Hash)
            touch = Touch.new(touch)
          end

          unless (last_touch = @touches.last).nil?
            touch.x ||= last_touch.x
            touch.y ||= last_touch.y
          end

          Gesture.new(@touches << touch, @query)
        end

        def +(gesture)
          Gesture.new(@touches + gesture.touches, @query)
        end

        def add_touch(touch)
          touches = @touches
          Gesture.new(touches << touch, @query)
        end

        def <<(touch)
          @touches << touch
        end

        def to_json(*object)
          {
              query_string: @query && @query.to_s,
              touches: @touches
          }.to_json(*object)
        end

        def query=(query)
          @query = query
        end

        def reset_query
          touches.each {|touch| touch.query=nil}
        end

        def offset=(offset)
          @touches.each {|touch| touch.offset=offset}
        end

        def max_execution_time
          (@touches.map {|touch| touch.wait + touch.time}).reduce(:+)
        end

        def queries
          (@touches.map(&:query).uniq + [@query]).reject(&:nil?)
        end

        def self.with_parameters(multi_touch_gesture, params={})
          multi_touch_gesture.query = params[:query] if params[:query]
          multi_touch_gesture.timeout = params[:timeout] if params[:timeout]

          multi_touch_gesture
        end

        def self.generate_tap(touch_hash)
          MultiTouchGesture.new(Gesture.new(Touch.new(touch_hash)))
        end

        def self.tap(opt={})
          touch = opt[:touch] || {}
          touch[:x] ||= (opt[:x] || 50)
          touch[:y] ||= (opt[:y] || 50)
          touch[:time] ||= (opt[:time] || 0.1)
          touch[:release] = touch[:release].nil? ? (opt[:release].nil? ? true : opt[:release]) : touch[:release]
          touch[:wait] ||= (opt[:wait] || 0)
          touch[:offset] ||= opt[:offset]

          generate_tap(touch)
        end

        def self.double_tap(opt={})
          self.tap(opt).merge(self.tap({wait: 0.1}.merge(opt)))
        end

        def self.generate_swipe(from_hash, to_hash, opt={})
          from_params = from_hash.merge(opt).merge(opt[:from] || {})
          to_params = {time: 0}.merge(to_hash).merge(opt[:to] || {})

          if opt[:flick]
            to_params.merge!(wait: 0)
          else
            to_params = {wait: 0.2}.merge(to_params)
          end

          self.tap({release: false}.merge(from_params)).merge(self.tap(to_params))
        end

        def self.swipe(direction, opt={})
          from = {x: 50, y: 50}
          to = {x: 50, y: 50}

          case direction
            when :left
              from[:x] = 90
              to[:x] = 10
            when :right
              from[:x] = 10
              to[:x] = 90
            when :up
              from[:y] = 90
              to[:y] = 10
            when :down
              from[:y] = 10
              to[:y] = 90
            else
              raise "Cannot swipe in #{direction}"
          end

          opt[:time] ||= 0.3

          generate_swipe(from, to, opt)
        end

        def self.generate_pinch_out(from_arr, to_arr, opt={})
          self.generate_swipe(from_arr[0], to_arr[0], opt) + self.generate_swipe(from_arr[1], to_arr[1], opt)
        end

        def self.pinch(direction, opt={})
          opt[:from] ||= []
          opt[:from][0] = (opt[:from][0] || {}).merge(opt)
          opt[:from][1] = (opt[:from][1] || {}).merge(opt)
          opt[:to] ||= []
          opt[:to][0] ||= {}
          opt[:to][1] ||= {}

          from = [{x: 40, y: 40}.merge(opt[:from][0]), {x: 60, y: 60}.merge(opt[:from][1])]
          to = [{x: 10, y: 10}.merge(opt[:to][0]), {x: 90, y: 90}.merge(opt[:to][1])]

          case direction
            when :out

            when :in
              from,to = to,from
            else
              raise "Cannot pinch #{direction}"
          end

          generate_pinch_out(from, to)
        end
      end

      class Touch
        attr_accessor :x, :y, :offset_x, :offset_y, :wait, :time, :release, :query

        def initialize(touch)
          if touch.is_a?(Touch)
            touch = touch.to_hash
          end

          touch[:offset] ||= {}
          touch[:offset_x] ||= touch[:offset][:x]
          touch[:offset_y] ||= touch[:offset][:y]

          @x = touch[:x]
          @y = touch[:y]
          @offset_x = touch[:offset_x] || 0
          @offset_y = touch[:offset_y] || 0
          @wait = touch[:wait] || 0
          @time = touch[:time] || 0
          @release = touch[:release].nil? ? false : touch[:release]
          @query = touch[:query]
        end

        def merge(touch)
          Touch.new(to_hash.merge(touch.to_hash))
        end

        def to_hash
          {
              x: @x,
              y: @y,
              offset_x: @offset_x || 0,
              offset_y: @offset_y || 0,
              wait: @wait.to_f,
              time: @time.to_f,
              release: @release,
              query: @query && @query
          }
        end

        def to_json(object = Hash)
          hash = to_hash
          hash[:query_string] = hash[:query] && hash[:query].to_s
          hash.to_json(object)
        end

        def +(touch)
          hash = to_hash
          hash[:x] += touch.x
          hash[:y] += touch.y
          hash[:offset_x] += touch.offset_x
          hash[:offset_y] += touch.offset_y
          Touch.new(hash)
        end

        def -(touch)
          hash = to_hash
          hash[:x] -= touch.x
          hash[:y] -= touch.y
          hash[:offset_x] -= touch.offset_x
          hash[:offset_y] -= touch.offset_y
          Touch.new(hash)
        end

        def offset=(offset)
          @offset_x = offset[:x]
          @offset_y = offset[:y]
        end
      end

      # @!visibility private
      define_method(:_pan_screen_up) do |options={}|
        from = {x: 50, y: 90}
        to = {x: 50, y: 10}

        pan("* id:'content'", from, to, options)
      end

      # @!visibility private
      define_method(:_pan_screen_down) do |options={}|
        from = {x: 50, y: 10}
        to = {x: 50, y: 90}

        pan("* id:'content'", from, to, options)
      end

      # @!visibility private
      define_method(:_flick_screen_up) do |options={}|
        from = {x: 50, y: 90}
        to = {x: 50, y: 10}

        flick("* id:'content'", from, to, options)
      end

      # @!visibility private
      define_method(:_flick_screen_down) do |options={}|
        from = {x: 50, y: 10}
        to = {x: 50, y: 90}

        flick("* id:'content'", from, to, options)
      end

      # @!visibility private
      define_method(:_pinch_screen) do |options={}|
        Calabash::Internal.with_current_target(required_os: :android) do |target|
          target.pinch(direction, "* id:'content'", options)
        end
      end
    end
  end
end
