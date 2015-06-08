module Calabash
  module KeyboardTypes

    #UIKeyboardTypeDefault,
    #UIKeyboardTypeASCIICapable,
    #UIKeyboardTypeNumbersAndPunctuation,
    #UIKeyboardTypeURL,
    #UIKeyboardTypeNumberPad,
    #UIKeyboardTypePhonePad,
    #UIKeyboardTypeNamePhonePad,
    #UIKeyboardTypeEmailAddress,
    #UIKeyboardTypeDecimalPad,
    #UIKeyboardTypeTwitter,
    #UIKeyboardTypeWebSearch,

    UI_KEYBOARD_TYPE =
          {
                0 => :default,
                1 => :ascii_capable,
                2 => :numbers_and_punctuation,
                3 => :url,
                4 => :number_pad,
                5 => :phone_pad,
                6 => :name_phone_pad,
                7 => :email,
                8 => :decimal,
                9 => :twitter,
                10 => :web_search
          }

    def canonical_keyboard_type(ui_keyboard_type)
      if ui_keyboard_type.is_a?(Fixnum)
        UI_KEYBOARD_TYPE[ui_keyboard_type]
      else
        raise "Expected '#{ui_keyboard_type}' to be a Fixnum"
      end
    end

    def ui_keyboard_type(canonical_keyboard_type)
      if canonical_keyboard_type.is_a?(Symbol)
        Hash[UI_KEYBOARD_TYPE.map(&:reverse)][canonical_keyboard_type]
      else
        raise "Expected '#{canonical_keyboard_type}' to be a Symbol"
      end
    end


    def keyboard_type_with_query(query_str, opts={})
      default_opts = {:timeout_message => "After waiting '#{query_str}' did not find a match"}
      opts = default_opts.merge(opts)

      res = nil

      wait_for(opts) do
        res = query(query_str, :keyboardType)
        not res.nil?
      end

      unless res.count == 1
        screenshot_and_raise "Expected exactly one element to be returned by '#{query_str}' but found '#{res}'"
      end

      canonical_keyboard_type(res.first)
    end

    def keyboard_type_from_step_argument(arg)
      case arg
        when 'ascii' then
          target = :ascii_capable
        when 'number' then
          target = :number_pad
        when 'phone' then
          target = :phone_pad
        when 'name and phone' then
          target = :name_phone_pad
        else
          target = "#{arg.gsub(' ', '_')}".to_sym
      end
      target
    end

    def ensure_keyboard_type(query_str, type, opts={})
      target_ui_type = ui_keyboard_type(type)
      if target_ui_type.nil?
        raise "Expected '#{type}' to be a valid canonical type for '#{UI_KEYBOARD_TYPE}'"
      end

      current = keyboard_type_with_query(query_str, opts)
      unless current.eql?(type)
        res = query("#{query_str}", {:setKeyboardType => target_ui_type})
        if res.empty?
          screenshot_and_raise "Could not set keyboard type for '#{query_str}' to '#{target_ui_type}' found '#{res}'"
        end
      end
    end
  end
end

World(Calabash::KeyboardTypes)
