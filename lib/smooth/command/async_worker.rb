module Smooth
  class Command::AsyncWorker

    if !Smooth.config.async_provider
      raise 'Must specify an async provider. e.g. Sidekiq::Worker on Smooth.config.async_provider'
    end

    def self.options(*args)
      send(:sidekiq_options, *args) if defined?(Sidekiq)
    end

    def perform serialized_payload
      if hash = memory_store.read(serialized_payload)
        api, object_path, payload = hash.values_at('api', 'object_path', 'payload')
        current_user = payload['current_user'] || hash['current_user']

        chain = Smooth(api).lookup_object_by(object_path)
        chain = chain.as(current_user) if current_user

        chain.run(payload)
      end
    end

    def memory_store
      Smooth.config.memory_store
    end
  end
end
