module Calabash
  module Android
    class Application < Calabash::Application
      attr_reader :test_server_path

      def initialize(application_path, test_server_path, options = {})
        @application_path = application_path
        @test_server_path = test_server_path
        @logger = options[:logger] || Logger.new
      end

      def package_name
        package_line = aapt_dump(@application_path, 'package').first
        raise "'package' not found in aapt output" unless package_line
        m = package_line.match(/name='([^']+)'/)
        raise "Unexpected output from aapt: #{package_line}" unless m
        m[1]
      end

      def main_activity
        begin
          @logger.log("Trying to find launchable activity")
          launchable_activity_line = aapt_dump(@application_path, "launchable-activity").first
          raise "'launchable-activity' not found in aapt output" unless launchable_activity_line
          m = launchable_activity_line.match(/name='([^']+)'/)
          raise "Unexpected output from aapt: #{launchable_activity_line}" unless m
          @logger.log("Found launchable activity '#{m[1]}'")
          m[1]
        rescue => e
          @logger.log("Could not find launchable activity, trying to parse raw AndroidManifest. #{e.message}")

          manifest_data = `"#{Environment.tools_dir}/aapt" dump xmltree "#{@application_path}" AndroidManifest.xml`
          regex = /^\s*A:[\s*]android:name\(\w+\)\=\"android.intent.category.LAUNCHER\"/
          lines = manifest_data.lines.collect(&:strip)
          indicator_line = nil

          lines.each_with_index do |line, index|
            match = line.match(regex)

            unless match.nil?
              raise 'More than one launchable activity in AndroidManifest' unless indicator_line.nil?
              indicator_line = index
            end
          end

          raise 'No launchable activity found in AndroidManifest' unless indicator_line

          intent_filter_found = false

          (0..indicator_line).reverse_each do |index|
            if intent_filter_found
              match = lines[index].match(/\s*E:\s*activity-alias/)

              raise 'Could not find target activity in activity alias' if match

              match = lines[index].match(/^\s*A:\s*android:targetActivity\(\w*\)\=\"([^\"]+)/){$1}

              if match
                @logger.log("Found launchable activity '#{match}'")

                return match
              end
            else
              unless lines[index].match(/\s*E: intent-filter/).nil?
                @logger.log("Read intent filter")
                intent_filter_found = true
              end
            end
          end

          raise 'Could not find launchable activity'
        end
      end
    end
  end
end