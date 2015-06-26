module Calabash
  module ConsoleHelpers
    # Outputs all visible elements as a tree
    def tree
      ConsoleHelpers.dump(Device.default.dump)
      nil
    end

    def classes
      query("*").map{|e| e['class']}.uniq
    end

    def ids
      query("*").map{|e| e['id']}.compact
    end

    def self.dump(json_data)
      json_data['children'].each {|child| write_child(child)}
    end

    def self.write_child(data, indentation=0)
      render(data, indentation)

      data['children'].each do |child|
        write_child(child, indentation+1)
      end
    end

    def self.render(data, indentation)
      raise AbstractMethodError
    end

    def self.output(string, indentation)
      (indentation*2).times {print " "}
      print "#{string}"
    end

    def self.visible?(data)
      data['visible'] || data['children'].map{|child| visible?(child)}.any?
    end
  end
end
