require 'io/console'

module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Doctor
      # @!visibility private
      def parse_doctor_arguments!
        platform = @arguments.shift
        if platform.eql?('ios')
          set_platform!(:ios)
        elsif platform.eql?('android')
          set_platform!(:android)
        else
          fail("Invalid setup to diagnose '#{platform}'")
        end
        diagnose
      end

      # @!visibility private
      def diagnose
        begin
        Logger.info("Diagnosing your #{@platform} setup")
        illnesses = [DirIllness.new, FileIllness.new]
        to_cure = []
        illnesses.each { |illness|
          diagnosis_result = illness.diagnose
          if diagnosis_result[:ok]
            well_message = "#{'☀'.green} #{diagnosis_result[:description]}"
            Logger.info(well_message)
          else
            ill_message = "#{'☂'.red} #{diagnosis_result[:description]}"
            to_cure << {message: ill_message, illness: illness}
            Logger.warn(ill_message)
          end
        }
        if to_cure.length == 0
          to_cure_message = 'You are fine!'
        elsif to_cure.length == 1
          to_cure_message = 'One illness needs to be cured.'
        else
          to_cure_message = "#{to_cure.length} illnesses needs to be cured."
        end
        Logger.info("Diagnosis is finished. #{to_cure_message}")
        if to_cure.length > 0
          to_manually_cure = to_cure.select { |cure_info|
            !cure_info[:illness].can_auto_cure
          }
          if to_manually_cure.length > 0
            Logger.info("\nYour setup can't be cured automatically. You need to do the following:")
            to_manually_cure.each { |cure_info|
              Logger.warn(" - #{cure_info[:illness].cure}")
            }
            Logger.info("\nRun the doctor again after the manual cure#{to_manually_cure.length > 1?'s':''} has beed performed.")
          else
            uncured = []
            to_cure.each { |cure_info|
              unless cure_info[:illness].cure
                uncured << cure_info
              end
            }
            if uncured.length > 0
              illnesses_text = uncured.length == 1?'1 illness':"#{uncured.length} illnesses"
              Logger.warn("\nYour setup still have #{illnesses_text}. Run the doctor again after to cure #{uncured.length == 1?'it':'them'}.")
            else
              Logger.info("\nAll illnesses has been cured. Congratulations!")
            end
          end
        end
        rescue => e
          Logger.error e.message
          e.backtrace.each { |line| Logger.error line }
        end
      end

      private

      class Illness

        def can_auto_cure
          @can_auto_cure
        end

        def initialize(opts={})
          @can_auto_cure = opts[:can_auto_cure]
        end

        def diagnose
          raise "Diagnose not implemented for illness '#{this.class.name}'"
        end

        def cure
          raise "Cure not implemented for illness '#{this.class.name}'"
        end

        def well(description)
          {ok: true, description: description}
        end

        def ill(description)
          {ok: false, description: description}
        end

        def should_cure?(message)
          valid_answers = ['y', 'yes', 'n', 'no']
          answer = nil
          until valid_answers.include?(answer)
            Logger.warn('Answer not recognized') if answer
            answer = prompt("#{message} (yes/no)")
          end
          answer.eql?('y') || answer.eql?('yes')
        end

        # @!visibility private
        def prompt(message, secure = false)
          puts message

          if secure
            STDIN.noecho(&:gets).chomp
          else
            STDIN.gets.chomp
          end
        end
      end

      class AutoCureIllness < Illness

        def initialize
          super({can_auto_cure: true})
        end
      end

      class ManualCureIllness < Illness

        def initialize
          super({can_auto_cure: false})
        end
      end

      class DirIllness < ManualCureIllness

        CHECK_PATH = '/tmp/calabash-doctor'

        def diagnose
          if Dir.exist?(CHECK_PATH)
            well("#{CHECK_PATH} exists")
          else
            ill("#{CHECK_PATH} does NOT exist")
          end
        end

        def cure
          "Manually create a directory at: #{CHECK_PATH}"
        end
      end

      class FileIllness < AutoCureIllness

        CHECK_PATH = '/tmp/calabash-doctor/demo'

        def diagnose
          if File.exist?(CHECK_PATH)
            well("#{CHECK_PATH} exists")
          else
            ill("#{CHECK_PATH} does NOT exist")
          end
        end

        def cure
          if should_cure?("Create the file: #{CHECK_PATH}")
            `touch #{CHECK_PATH}`
            true
          else
            false
          end
        end
      end
    end
  end
end
