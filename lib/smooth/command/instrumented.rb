module Smooth
  class Command < Mutations::Command
    module Instrumented
      def self.included(base)
        base.extend(ClassMethods)
        base.enable_event_tracking! # if Smooth.config.enable_event_tracking_by_default?
      end

      module Overrides
        def run
          run_with_instrumentation
        end
      end

      module Restored
        def run
          run_with_outcome
        end
      end

      module ClassMethods
        def enable_event_tracking!
          send(:include, Smooth::Event::Adapter)
          send(:include, Overrides)
        end

        def disable_event_tracking!
          send(:include, Restored)
        end
      end

      def run_with_instrumentation
        outcome = run_with_outcome

        if outcome.success?
          result = outcome.result
          track_event("#{ event_namespace }", result: result, inputs: inputs, current_user: current_user)
          result
        else
          track_event("errors/#{ event_namespace }", errors: outcome.errors, inputs: inputs, current_user: current_user)
          outcome
        end
      end

      def run_with_outcome
        return validation_outcome if has_errors?
        validation_outcome(execute)
      end
    end
  end
end
