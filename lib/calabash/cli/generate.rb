require 'fileutils'

module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Generate
      # @!visibility private
      def parse_generate_arguments!
        if File.exist?('features')
          puts "A features directory already exists. Please remove this to continue."
          exit 1
        end

        if File.exist?('config')
          puts "A config directory already exists. Please remove this to continue."
          exit 1
        end

        cucumber_config = File.read(file(File.join('config', 'cucumber.yml.skeleton')))

        env = File.read(file(File.join('features', 'support', 'env.rb.skeleton')))
        dry_run = File.read(file(File.join('features', 'support', 'dry_run.rb.skeleton')))
        sample_feature = File.read(file(File.join('features', 'sample.feature.skeleton')))
        calabash_steps = File.read(file(File.join('features', 'step_definitions', 'sample_steps.rb.skeleton')))

        hooks = File.read(file(File.join('features', 'support', 'hooks.rb.skeleton')))

        FileUtils.mkdir('config')

        File.open(File.join('config', 'cucumber.yml'), 'w') {|file| file.write(cucumber_config) }

        FileUtils.mkdir('features')
        FileUtils.mkdir('features/step_definitions')
        FileUtils.mkdir('features/support')

        File.open(File.join('features', 'sample.feature'), 'w') {|file| file.write(sample_feature) }
        File.open(File.join('features', 'step_definitions', 'sample_steps.rb'), 'w') {|file| file.write(calabash_steps) }
        File.open(File.join('features', 'support', 'hooks.rb'), 'w') {|file| file.write(hooks) }
        File.open(File.join('features', 'support', 'env.rb'), 'w') {|file| file.write(env) }
        File.open(File.join('features', 'support', 'dry_run.rb'), 'w') {|file| file.write(dry_run) }

        gemfile = File.readlines(file(File.join('Gemfile.skeleton')))

        unless File.exist?('Gemfile')
          File.open('Gemfile', 'w') do |file|
            gemfile.each do |skeleton_line|
              if skeleton_line == "gem 'calabash'\n"
                file.write("#{skeleton_line.strip}, '#{Calabash::VERSION}'\n")
              else
                file.write(skeleton_line)
              end
            end
          end
        end

        gitignore = File.read(file(File.join('.gitignore')))

        unless File.exist?('.gitignore')
          File.open('.gitignore', 'w') {|file| file.write(gitignore) }
        end
      end

      # @!visibility private
      def file(file)
        File.join(Calabash::Environment::SKELETON_DIR_PATH, file)
      end

      # @!visibility private
      def msg(title, &block)
        puts "\n" + "-"*10 + title + "-"*10
        block.call
        puts "-"*10 + "-------" + "-"*10 + "\n"
      end


    end
  end
end
