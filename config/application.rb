require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TokenApp
  class Application < Rails::Application
      # Use TorqueBox::Infinispan::Cache for the Rails cache store
  if defined? TorqueBox::Infinispan::Cache
    config.cache_store = :torquebox_store
  end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = `timedatectl status |grep zone |sed -e 's/[[:space:]]*Time zone:\(.*\) (.*)$/\1/g'`.strip

    if config.time_zone.blank?
      config.time_zone = "UTC"
    end

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    version_file = File.join([(ENV['RSNA_ROOT'] || "").strip,"version"])

    if File.exists?(version_file)
      config.edge_version = File.read(version_file).strip
    else
      config.edge_version = ""
    end
  end
end
