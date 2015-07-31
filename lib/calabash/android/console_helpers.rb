module Calabash
  module ConsoleHelpers
    def self.render(data, indentation)
      if visible?(data)
        type = data['type']
        simple_name = type.split('.').last.split('$').last

        str_type = if data['type'] == 'dom'
                     "#{Color.yellow("[")}#{simple_name}:#{Color.yellow("#{data['nodeName']}]")} "
                   else
                     Color.yellow("[#{simple_name}] ")
                   end

        text = nil

        if data['value']
          unless data['value'].empty?
            if data['value'].length > 45
              text = "#{data['value'][0,45]}[...]"
            else
              text = data['value']
            end

            newline_index = text.index("\n")

            unless newline_index.nil?
              text = "#{text[0,newline_index]}[...]"
            end
          end
        end

        str_id = data['id'] ? "[id:#{Color.blue(data['id'])}] " : ''
        str_label = data['label'] ? "[contentDescription:#{Color.green(data['label'])}] " : ''
        str_text = text ? "[text:#{Color.magenta(text)}] " : ''
        output("#{str_type}#{str_id}#{str_label}#{str_text}", indentation)
        output("\n", indentation)
      end
    end

    def self.visible?(data)
      (data['type'] != '[object Exception]' && data['visible']) ||
          data['children'].map{|child| visible?(child)}.any?
    end
  end
end
