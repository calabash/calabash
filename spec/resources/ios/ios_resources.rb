require 'singleton'

class IOSResources

  include Singleton

  def active_xcode
    @active_xcode ||= Calabash::Luffa::active_xcode
  end

  def active_xcode_version
    @active_xcode_version ||= Calabash::Luffa::active_xcode.version
  end

  def resources_dir
    @resources_dir ||= File.join(File.dirname(__FILE__))
  end

  def app_bundle_path
    @app_bundle_path ||= File.join(resources_dir, 'CalSmoke-cal.app')
  end

  def bundle_id
    @bundle_id ||= 'xamarin.CalSmoke-cal'
  end
end
