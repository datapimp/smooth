module Smooth
  class Api
    module SinatraAdapter
      def sinatra
        app = @sinatra_application_klass ||= Class.new(Sinatra::Base)

        @sinatra ||= begin
                       _resources.each do |name, resource|
                         resource.router.apply_to(app)
                       end

                       app
                     end
      end
    end
  end
end
