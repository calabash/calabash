require 'io/console'

module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Doctor
      # @!visibility private
      def parse_doctor_arguments!
        setup_to_diagnose = @arguments.shift
        unless setup_to_diagnose.eql?('ios') || setup_to_diagnose.eql?('android') || setup_to_diagnose.eql?('tryout')
          fail("Invalid setup to diagnose '#{name_for_setup(setup_to_diagnose)}'")
        end
        diagnose(setup_to_diagnose)
      end

      def name_for_setup(setup)
        if setup.eql?('ios')
          'iOS'
        elsif setup.eql?('android')
          'Android'
        elsif setup.eql?('tryout')
          'Try-out'
        else
          setup
        end
      end

      # @!visibility private
      def diagnose(setup_to_diagnose)
        Logger.info("Diagnosing your #{name_for_setup(setup_to_diagnose)} setup")
        illnesses = []
        if setup_to_diagnose.eql?('tryout')
          illnesses << DirIllness.new
          illnesses << FileIllness.new
        else
          illnesses << OldRubyIllness.new
          if setup_to_diagnose.eql?('ios')
            illnesses << MissingXcodeIllness.new
            illnesses << MissingXcodeCommandLineToolsIllness.new
            illnesses << DevToolsSecurityIllness.new
            illnesses << AuthorizationDbIllness.new
          elsif setup_to_diagnose.eql?('android')
            illnesses << NotSetAndroidHomeEnvVarIllness.new
            illnesses << MissingAndroidScriptIllness.new
            illnesses << MissingAdbIllness.new
            illnesses << MissingAndroidEmulatorIllness.new
          end
        end
        to_cure = []
        illnesses.each { |illness|
          diagnosis_result = illness.diagnose
          if diagnosis_result[:ok]
            well_message = "#{'√'.green} #{diagnosis_result[:description]}"
            Logger.info(well_message)
          else
            ill_message = "#{'x'.red} #{diagnosis_result[:description]}"
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
        cure(to_cure) if to_cure.length > 0
      end

      def cure(to_cure)
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

      private

      class Illness
        attr_reader :can_auto_cure

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

        def cure
          # A auto cure illness should return true or false
          # based on the result of the cure
          super
        end
      end

      class ManualCureIllness < Illness

        def initialize
          super({can_auto_cure: false})
        end

        def cure
          # A manual cure illness should return a string
          # explaining how to cure it
        end
      end

      class NotSetEnvVarIllness < ManualCureIllness

        def initialize(env_var)
          @env_var = env_var
        end

        def diagnose
          if ENV[@env_var]
            well("The environment variable '#{@env_var}' is set to: #{ENV[@env_var]}")
          else
            ill("The environment variable '#{@env_var}' is NOT set")
          end
        end

        def cure
          "Manually set up the environment variable '#{@env_var}'"
        end
      end

      class NotSetPathEnvVarIllness < NotSetEnvVarIllness

        def diagnose
          result = super
          return result unless result[:ok]
          path = ENV[@env_var]
          if Dir.exist?(path)
            well("'#{@env_var}' is set to a valid path: #{path}")
          else
            ill("The environment variable '#{@env_var}' is set to '#{path}' but it is NOT valid")
          end
        end
      end

      require_relative 'doctor/tryout'
      require_relative 'doctor/ruby'
      require_relative 'doctor/ios'
      require_relative 'doctor/android'
    end
  end
end