require 'calabash'

Before('@shared_element') do
  @uia_strategy = :shared_element
end

Before('@host') do
  @uia_strategy = :shared_element
end

Before('@preferences') do
  @uia_strategy = :preferences
end

Before('@ensure_ipad_1x') do
  app = Calabash::IOS::Application.new('./binaries/iPhoneOnly.app')
  Calabash::Application.default = app

  xcode_version = RunLoop::Xcode.new.version
  simulator_version = "#{xcode_version.major + 2}.#{xcode_version.minor}"
  simulator_name = "iPad Air (#{simulator_version} Simulator)"

  server = Calabash::IOS::Server.default
  Calabash::Device.default = Calabash::IOS::Device.new(simulator_name, server)
end

Before do |scenario|
  if scenario.respond_to?(:scenario_outline)
    scenario = scenario.scenario_outline
  end

  AppLifeCycle.on_new_scenario(scenario)
  Cucumber.wants_to_quit = false

  if @uia_strategy
    options = {:uia_strategy => @uia_strategy}
  else
    options = {}
  end

  start_app(options)
end

After do
  @uia_strategy = nil
end

module AppLifeCycle
  # Since this is a module, the methods in the Cucumber World are not
  # available inside the scope of this module. We can safely include Calabash
  # because we will not affect the scope outside this module. The methods are
  # loaded as class (static) methods.
  class << self
    include Calabash
  end

  DEFAULT_RESET_BETWEEN = :never
  DEFAULT_RESET_METHOD = :reinstall

  RESET_BETWEEN = if Calabash::Environment.variable('RESET_BETWEEN')
                    Calabash::Environment.variable('RESET_BETWEEN').downcase.to_sym
                  else
                    DEFAULT_RESET_BETWEEN
                  end

  RESET_METHOD = if Calabash::Environment.variable('RESET_METHOD')
                   Calabash::Environment.variable('RESET_METHOD').downcase.to_sym
                 else
                   DEFAULT_RESET_METHOD
                 end

  def self.on_new_scenario(scenario)
    if @last_feature.nil? && RESET_BETWEEN == :never
      ensure_app_installed
    end

    if should_reset?(scenario)
      reset
    end

    @last_feature = scenario.feature
  end

  private

  def self.should_reset?(scenario)
    case RESET_BETWEEN
      when :scenarios
        true
      when :features
        scenario.feature != @last_feature
      when :never
        false
      else
        raise "Invalid reset between option '#{RESET_BETWEEN}'"
    end
  end

  def self.reset
    case RESET_METHOD
      when :reinstall
        install_app
      when :clear
        ensure_app_installed
        clear_app_data
      when '', nil
        raise 'No reset method given'
      else
        raise "Invalid reset method '#{RESET_METHOD}'"
    end
  end
end
