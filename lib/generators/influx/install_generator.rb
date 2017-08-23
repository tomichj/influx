module Influx
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    class_option :subscriber,
                 optional: true,
                 type: :string,
                 banner: 'subscriber',
                 desc: "Specify the subscriber class name if you will use anything other than '::User'"

    def initialize(*)
      super
      assign_names!(subscriber_class_name)
    end

    def install_initializer
      copy_file 'influx.rb', 'config/initializers/influx.rb'
      if options[:subscriber]
        inject_into_file(
          'config/initializers/influx.rb',
          "  config.subscriber = '#{options[:subscriber]}'\n",
          after: "Influx.configure do |config|\n"
        )
      end
    end

    def install_route
      route "mount StripeEvent::Engine => '/stripe/events'"
    end

    private
    def subscriber_class_name
      options[:subscriber] ? options[:subscriber].classify : '::User'
    end

    def assign_names!(name)
      @class_path = name.include?('/') ? name.split('/') : name.split('::')
      @class_path.map!(&:underscore)
      @file_name = @class_path.pop
    end
  end
end
