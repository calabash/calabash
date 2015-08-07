require 'fileutils'
require 'pathname'

module Calabash

  # A public API for taking screenshots.
  module Screenshot
    # @!visibility private
    def self.screenshot_directory_prefix
      @@screenshot_directory_prefix
    end

    # Set the screenshot directory prefix.
    # @!visibility private
    def self.screenshot_directory_prefix=(value)
      if class_variable_defined?(:@@screenshots_taken) &&
          @@screenshots_taken != 0
        raise 'Cannot change the screenshot directory prefix after a screenshot has been taken'
      end

      @@screenshot_directory_prefix = value
    end

    # @!visibility private
    self.screenshot_directory_prefix = 'test_run_'

    # Takes a screenshot and saves it.
    #
    # If `name` is a relative path or a file name, then the file is stored in
    # the directory specified by the ENV variable CAL_SCREENSHOT_DIR, or by
    # default in the relative directory 'screenshots'. The files are saved in a
    # sub directory named test_run_n, where n is unique and incrementing for
    # each new test run. The filename of the screenshot will be `name`.
    # If `name` is not given (nil), the screenshot will be saved as
    # screenshot_N, where N is the total amount of screenshots taken for the
    # test run.
    #
    # If the name given is an absolute path, then Calabash will save the
    # screenshot to the absolute directory given.
    #
    # If the name given starts with ./ (e.g. `screenshot('./foo.png')`) then
    # the filename will be saved relative to the current working directory.
    #
    # If the file specified by `name` has no extension then the filename will
    # default to name + '.png'.
    #
    # If the directories specified do not exist, Calabash will create them.
    #
    # @param [String] name Name of the screenshot.
    # @return [String] Path to the screenshot
    def screenshot(name=nil)
      Device.default.screenshot(name)
    end

    # Takes a screenshot and embeds it in the test report. This method is only
    # available/useful when running in the context of cucumber.
    # @see Screenshot#screenshot
    def screenshot_embed(name=nil)
      path = screenshot(name)
      embed(path, 'image/png', name || File.basename(path))
    end

    # @!visibility private
    def self.obtain_screenshot_path!(name=nil)
      @@screenshots_taken ||= 1

      if name.nil?
        name = "screenshot_#{@@screenshots_taken}.png"
      end

      name = "#{name}.png" if File.extname(name).empty?

      @@screenshots_taken += 1

      if name.start_with?('./')
        name = File.join(Dir.pwd, "#{name[2..-1]}")
      end

      file_name = File.expand_path(name, screenshot_directory)

      unless Dir.exist?(File.dirname(file_name))
        FileUtils.mkdir_p(File.dirname(file_name))
      end

      file_name
    end

    # @!visibility private
    def self.screenshot_directory
      @@screenshot_directory ||= new_screenshot_sub_directory
    end

    # @!visibility private
    def self.new_screenshot_sub_directory
      count = screenshot_directory_test_run_directories.count
      File.join(Environment::SCREENSHOT_DIRECTORY,
                "#{screenshot_directory_prefix}#{count+1}")
    end

    # @!visibility private
    def self.screenshot_directory_test_run_directories
      dir = File.expand_path(File.join(Environment::SCREENSHOT_DIRECTORY, '*'))

      Dir.glob(dir).select do |file|
        File.directory?(file) &&
        File.basename(file) =~ /^#{screenshot_directory_prefix}\d+$/
      end
    end
  end
end
