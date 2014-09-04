require 'smooth/dsl'

api "My Application" do
  version :v1

  authentication_strategy :header, "X-AUTH-TOKEN"

  user_class User do
    include(Smooth::UserAdapter)
  end

  desc "Public users include anyone with access to the URL"
  policy :public_users do
    # commands / queries can be set to true or false to allow
    # all commands and queries defined for the books resource.
    #allow :books, :commands => false, :queries => true

    # we can also pass an array of queries or commands
    # allow :books, :commands => [:like]
  end

  desc "Authenticated users register and are given an auth token"
  policy :logged_in_users do
    authenticate_with :header => 'X-AUTH-TOKEN', :param => :auth_token
    #allow :books, :commands => true, :queries => true
  end

  desc "Admin users have the admin flag set to true"
  policy :admin_users do
    same_as :logged_in_users

    # what method should we call on the current_user to see if
    # it is eligible for this policy?
    test :admin?

    # an alternative.  checks to see if the method 'role' returns 'admin'
    # test :role => "admin"
  end
end
