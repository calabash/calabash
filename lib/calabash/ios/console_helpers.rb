module Calabash
  module ConsoleHelpers
    def self.render(data, indentation)
      if visible?(data)
        type = data['type']

        str_type = if data['type'] == 'dom'
                     "#{Color.yellow("[")}#{type}:#{Color.yellow("#{data['nodeName']}]")} "
                   else
                     Color.yellow("[#{type}] ")
                   end

        str_id = data['id'] ? "[id:#{Color.blue(data['id'])}] " : ''
        str_label = data['label'] ? "[label:#{Color.green(data['label'])}] " : ''
        str_text = data['value'] ? "[text:#{Color.magenta(data['value'])}] " : ''
        output("#{str_type}#{str_id}#{str_label}#{str_text}", indentation)
        output("\n", indentation)
      end
    end
  end
end
