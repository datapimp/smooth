module Smooth
  module UserAdapter
    # Allows for using the current_user making an API request
    # as the source of all queries, and commands run against
    # Smooth resources.
    #
    # Example:
    #
    #   current_user.smooth.query("books.mine", published_before: 2014)
    #
    # Piping all queries to the Smooth Resources through the same interface
    # makes implementing a declarative, role based access control policy pretty
    # easy.
    #
    # You could even add the following methods to all of your ApplicationController
    #
    # Example:
    #
    # class ApplicationController < ActionController::Base
    #   def run_query *args, &block
    #     current_user.smooth.send(:query, *args, &block)
    #   end
    #
    #   def run_command *args, &block
    #     current_user.smooth.send(:run_command, *args, &block)
    #   end
    # end
    #
    # class BooksController < ApplicationController
    #   def index
    #     render :json => run_query("books", params)
    #   end
    # end
    def smooth(api=:default)
      Smooth.fetch_api(api).as(self)
    end
  end
end
