# Internal class to provide current user awareness to the
module Smooth
  class Command < Mutations::Command
    class RunProxy
      attr_accessor :current_user, :cmd

      def initialize(current_user, cmd)
        @current_user = current_user
        @cmd = cmd
      end

      def run! *args
        cmd.new(*args).tap {|c| c.current_user = current_user }.run!
      end

      def run *args
        cmd.new(*args).tap {|c| c.current_user = current_user }.run
      end
    end
  end
end

