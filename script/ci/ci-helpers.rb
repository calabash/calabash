#!/usr/bin/env ruby

def log_cmd(msg)
  puts "\033[36mEXEC: #{msg}\033[0m" if msg
end

def log_pass(msg)
  puts "\033[32mPASS: #{msg}\033[0m" if msg
end

def log_fail(msg)
  puts "\033[31mFAIL: #{msg}\033[0m" if msg
end

def do_system(cmd, opts={})
  default_opts = {:pass_msg => nil,
                  :fail_msg => nil,
                  :exit_on_nonzero_status => true,
                  :env_vars => {},
                  :log_cmd => true,
                  :obscure_fields => []}
  merged_opts = default_opts.merge(opts)

  obscure_fields = merged_opts[:obscure_fields]

  if not obscure_fields.empty? and merged_opts[:log_cmd]
    obscured = cmd.split(' ').map do |token|
      if obscure_fields.include? token
        "#{token[0,1]}***#{token[token.length-1,1]}"
      else
        token
      end
    end
    log_cmd obscured.join(' ')
  elsif merged_opts[:log_cmd]
    log_cmd cmd
  end

  exit_on_err = merged_opts[:exit_on_nonzero_status]
  unless exit_on_err
    system 'set +e'
  end

  env_vars = merged_opts[:env_vars]
  res = system(env_vars, cmd)
  exit_code = $?.exitstatus

  if res
    log_pass merged_opts[:pass_msg]
  else
    log_fail merged_opts[:fail_msg]
    exit exit_code if exit_on_err
  end
  system 'set -e'
  exit_code
end

def travis_ci?
  ENV['TRAVIS']
end

def update_rubygems
  do_system('gem update --system',
            {:pass_msg => 'Updated rubygems.',
             :fail_msg => 'Could not update rubygems.'})
end

def uninstall_gem(gem_name)
  do_system("gem uninstall -Vax --force --no-abort-on-dependent #{gem_name}",
            {:pass_msg => "uninstalled '#{gem_name}'",
             :fail_msg => "could not uninstall '#{gem_name}'"})
end

def install_gem(gem_name, opts={})
  default_opts = {:prerelease => false,
                  :no_document => true}
  merged_opts = default_opts.merge(opts)

  pre = merged_opts[:prerelease] ? '--pre' : ''
  no_document = merged_opts[:no_document] ? '--no-document' : ''

  do_system("gem install #{no_document} #{gem_name} #{pre}",
            {:pass_msg => "Installed '#{gem_name}'",
             :fail_msg => "Could not install '#{gem_name}'"})
end
