module Calabash
  module TargetState
    # @!visibility private
    class DefaultTargetState
      include Calabash::Utility

      def initialize(device_from_environment: nil,
                      target_from_environment: nil)
        @set_default_device_from_environment_method = device_from_environment
        @set_default_target_from_environment_method = target_from_environment

        @default_device_state = State::Unknown.new
        @default_target_state = State::Unknown.new
      end

      class State
        class Unknown < State; end

        class UserSet < State
          attr_reader :value

          def initialize(value)
            @value = value
          end
        end

        # Tried to set from user call, but failed to do so
        class UserFailedToSet < State
          attr_reader :error

          def initialize(error)
            @error = error
          end
        end

        class EnvironmentSet < State
          attr_reader :value

          def initialize(value)
            @value = value
          end
        end

        # Tried to set from environment, but failed to do so
        class EnvironmentFailedToSet < State
          attr_reader :error

          def initialize(error)
            @error = error
          end
        end
      end

      def obtain_default_target
        if [State::Unknown].include?(@default_device_state.class)
          set_default_device_from_environment
        end

        if [State::EnvironmentFailedToSet].include?(@default_device_state.class)
          raise "Could not set the default device-target automatically: #{@default_device_state.error.message}"
        end

        if [State::UserFailedToSet].include?(@default_device_state.class)
          raise "Could not set the default device-target: #{@default_device_state.error.message}"
        end

        if [State::Unknown].include?(@default_target_state.class)
          set_default_target_from_environment
        end

        if [State::EnvironmentFailedToSet].include?(@default_target_state.class)
          raise "Could not set the default target automatically: #{@default_target_state.error.message}"
        end

        if [State::UserFailedToSet].include?(@default_target_state.class)
          raise "Could not set the default target: #{@default_device_state.error.message}"
        end

        @default_target_state.value
      end

      def set_default_device_from_environment
        if [State::EnvironmentSet, State::UserSet].include?(@default_target_state.class)
          raise 'Cannot set the default device from environment, the default target has already been set'
        end

        case @default_device_state
          when State::Unknown, State::EnvironmentFailedToSet, State::EnvironmentSet
            begin
              result = @set_default_device_from_environment_method.call
              @default_device_state = State::EnvironmentSet.new(result)

              # Set the default target now that we have set the default device
              set_default_target_from_environment
            rescue => e
              Calabash::Logger.debug("Error while setting default device from ENV #{e.message}")
              Calabash::Logger.debug(e.backtrace[0..5].join("\n"))
              @default_device_state = State::EnvironmentFailedToSet.new(e)
            end
          when State::UserSet, State::UserFailedToSet
            raise 'Cannot set default device from environment, user already set it'
        end
      end

      def set_default_device_from_user(&block)
        if [State::EnvironmentSet, State::UserSet].include?(@default_target_state.class)
          raise 'Cannot set the default device, the default target has already been set'
        end

        case @default_device_state
          when State::Unknown, State::EnvironmentFailedToSet, State::EnvironmentSet
            case @default_target_state
              when State::Unknown, State::EnvironmentFailedToSet, State::EnvironmentSet, State::UserFailedToSet
                begin
                  result = block.call
                  @default_device_state = State::UserSet.new(result)

                  # Set the default target now that we have set the default device
                  set_default_target_from_environment
                rescue => e
                  @default_device_state = State::UserFailedToSet.new(e)

                  # Eagerly raise the error when the user sets the default device
                  raise e
                end
              when State::UserSet
            end
          when State::UserSet, State::UserFailedToSet
            raise 'Cannot set default device from environment, user already set it'
        end
      end

      def set_default_target_from_environment
        unless [State::EnvironmentSet, State::UserSet].include?(@default_device_state.class)
          raise 'Cannot set the default target, the default device has not been set'
        end

        case @default_target_state
          when State::Unknown, State::EnvironmentFailedToSet, State::EnvironmentSet
            begin
              result = @set_default_target_from_environment_method.call(@default_device_state.value)
              @default_target_state = State::EnvironmentSet.new(result)
            rescue => e
              @default_target_state = State::EnvironmentFailedToSet.new(e)
            end
          when State::UserSet, State::UserFailedToSet
            raise 'Cannot set default target from environment, user already set it'
        end
      end

      def set_default_target_from_user(&block)
        unless [State::EnvironmentSet, State::UserSet].include?(@default_device_state.class)
          raise 'Cannot set the default target, the default device has not been set'
        end

        case @default_target_state
          when State::Unknown, State::EnvironmentFailedToSet, State::EnvironmentSet
            begin
              result = block.call(@default_device_state.value)
              @default_target_state = State::EnvironmentSet.new(result)
            rescue => e
              @default_target_state = State::EnvironmentFailedToSet.new(e)

              # Eagerly raise the error when the user sets the default target
              raise e
            end
          when State::UserSet, State::UserFailedToSet
            raise 'Cannot set default target from environment, user already set it'
        end
      end
    end
  end
end