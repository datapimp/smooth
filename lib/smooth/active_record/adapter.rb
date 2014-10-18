module Smooth
  module AR
    class Adapter
      class << self
        def configure
        end

        def in_use?
          connection.in_use?
        rescue ActiveRecord::ConnectionNotEstablished
          false
        end

        def connection
          ActiveRecord::Base.connection
        end

        def establish_connection
          @connection = ActiveRecord::Base.establish_connection(Smooth.config.active_record)
        end
      end
    end
  end
end
