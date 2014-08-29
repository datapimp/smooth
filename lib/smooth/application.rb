module Smooth
  class Application
    attr_reader :options

    class User < Hashie::Mash
    end

    def initialize(options={}, &block)
      @options = options
      instance_eval(&block) if block_given?

      config do
        self.root = options[:root]
      end

      boot unless options[:defer]
    end

    def config &block
      Smooth.config(&block)
    end

    def console
      require 'pry'
      Pry.start(self, {})
    end

    def system_user
      @system_user ||= User.new(email: "system@smooth.io", role: "system")
    end

    def api
      @api ||= Smooth(options[:api] || :default)
    end

    def smooth
      @smooth ||= api.as(system_user)
    end

    def resource *args, &block
      api.send(:resource, *args)
    end

    def query *args
      smooth.send(:query, *args)
    end

    def command *args
      smooth.send(:run_command, *args)
    end

    def load_models
      Dir[config.models_path.join("**/*.rb")].each do |f|
        require config.models_path.join(f)
      end
    end

    def boot
      @boot ||= begin
                  Smooth.active_record.establish_connection
                  load_models()
                  Smooth.eager_load_from_app_folders()
                end
    end

  end
end
