module Influx
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def install_initializer
      initializer 'influx.rb', File.read(File.expand_path('../templates/influx.rb', __FILE__))
    end
  end
end
