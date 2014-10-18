module Smooth
  class Response
    attr_reader :outcome, :serializer_options

    attr_accessor :request_headers, :serializer, :event_namespace, :command_action, :success, :object, :serializer_klass, :current_user

    def initialize(outcome, serializer_options = {})
      @outcome = outcome
      @serializer_options = serializer_options
    end

    def to_rack
      [status, headers, [body]]
    end

    def headers
      {
        'Content-Type' => 'application/json'
      }
    end

    def options
      if success? && serializer
        (@serializer_options || {}).merge(serializer: serializer, scope: current_user)
      else
        @serializer_options.merge(scope: current_user)
      end
    end

    def body
      serializer.new(object, options).to_json(options)
    end

    def object
      @object || begin
        if success?
          outcome.result
        else
          outcome.errors.message
        end
      end
    end

    def success?
      @success || (outcome && outcome.success?)
    end

    def status
      case
      when success?
        200
      else
        400
      end
    end
  end

  class ErrorResponse < Response
    def initialize(error_message, _request_object, *_args)
      @error_message = error_message
    end

    def success?
      false
    end

    def body
      {
        error: error_message
      }
    end
  end
end
