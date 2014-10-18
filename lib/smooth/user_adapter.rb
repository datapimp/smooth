module Smooth
  module UserAdapter
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:attr_accessor, :last_request_params, :last_request_headers)

      base.send(:before_create, -> { generate_token(Smooth.config.auth_token_column) })
    end

    def generate_token(column)
      if self.class.column_names.include?(column.to_s)
        write_attribute(column, SecureRandom.urlsafe_base64)
      end
    end

    module ClassMethods
      def find_for_smooth_api_request(id, passed_authentication_token)
        where(id: id, authentication_token: passed_authentication_token).first
      end

      def find_for_token_authentication(passed_authentication_token)
        id, token = passed_authentication_token.split(':')
        find_for_smooth_api_request(id, token)
      end

      def anonymous(params = nil, headers = nil)
        User.new.tap do |user|
          user.last_request_params = params if params
          user.last_request_headers = headers if headers
          user.making_anonymous_request = true
        end
      end
    end

    def making_anonymous_request=(setting)
      @making_anonymous_request = !!(setting)
    end

    def anonymous?
      !!(@making_anonymous_request)
    end

    def smooth_authentication_token
      read_attribute(:authentication_token)
      "#{ id }:#{ token }"
    end

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
    def smooth(api = :default)
      Smooth.fetch_api(api).as(self)
    end
  end
end
