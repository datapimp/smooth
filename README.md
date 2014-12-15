# Smooth

Smooth provides a way of developing JSON APIs on top of SQL Databases that is, well, smooth. 

Smooth provides a ruby library and a front end graphical application
that make the process of developing APIs for your web and mobile
applications really productive. 

#### General idea: in the abstract

A resource is, generally, a database backed collection of models. A
resource can be accessed by users who have different roles and relations
to the data.  A resource is accessed in one of two ways: queries, and
commands.  The resource can be presented in different views.

#### The benefits of a declarative, data driven programming style

As a developer you get API interface inspection capabilities 
for free by coding your API in the smooth style.  These capabilities can give you a lot of power 
for your every day development practice.

Generating documentation, generating custom querying and reporting
tools, generating API client libraries, generating automated test code,
and a number of other tasks become much much easier.

#### The Smooth approach starts with declarations

In smooth we develop resources by describing or declaring data about the
different functions an API client will need access to to provide its
users the means of interacting with their data that they need.

##### Commands:

Commands handle API requests whose intent is to change data in the
resource. A user updating their profile. A person adding a new recipe
to their cookbook. A moderator removing a rude comment on their blog. 

We define the set of commands available and what information they
require:

- In what ways can a user change the data?
- What specific parameters must an API client pass to these commands?
- Describe what they mean for a developer?
- What type of data, what values?

##### Queries:

API clients often have large sets of data that they need to reduce to a  
manageable size to render in some view in their application or dynamic
page on their website.

- In what ways can a user or role filter the data? 
- Specifically what parameters would an API client pass? 
- What type of data, what values?
- Should a user only be allowed to see a hard coded subset of records? 

##### Serializers:

Given a query which returns a set of zero or more records, we will often
want to present this data in an optimized format.  We'll want to convert 
a specific timestamp into a description of the amount of time that has
passed.  We'll want to display individual things in a table, or maybe as a pie chart. 

In smooth we enumerate:

- In what ways would an API client want to see this data? 
- As individual objects? As a reduced / aggregated report?
- In what ways does the data change depending on who is looking at it?
- Are there different serializers for different roles?
- What are each of the attributes and what do they mean?

## Coding the smooth way 

There are a few distinctly different ways of working with code *sunglasses* smoothly.

- Use it in your rails application, edit the different classes of ruby
  objects whose file names, locations, and class names follow a familiar
  naming convention.

- Use it in a standalone ruby application as a rack compatible
  application or middleware.  File organization and class naming approach
  follows same familiar naming conventions.

- Use the DSL to build an entire application from one or more configuration
  files organized however you want.

- Use the smooth developer mode to build the structure of your API and
  resources visually and from a user interface.  Customize small methods
  with configuration, and if necessary, custom code.

- Use the smooth developer mode and don't write any code at all.
  (Obviously you are limited in what you can do with this approach, but
  for simple apps this is often effective.)

### Example Code

```
# Sample App Structure (Rails or Standalone)

- app
  - models
    - book.rb
  - commands
    - create_book.rb
    - update_book.rb
  - queries
    - book_query.rb
  - serializers
    - book_serializer.rb
    - book_summary_serializer.rb
```

#### Queries

```ruby
class BookQuery < Smooth::Query
  params do
    desc "Filter the books by a wildcard title"
    string :title_is_like, operator: "like"

    desc "Filter the books published after a certain year"
    integer :published_after_year, operator: "greater_than_or_equal_to", min_length: 4
  end
end
```

Run the query:

```ruby
BookQuery.as(current_user).query_with(params) #=> Book: ActiveRecord::Relation
```

Inspect the query interface:

```
BookQuery.interface 

{
  optional_parameters:{
    "title_is_like": {
      description: "Filter the books by wildcard title" 
    }
  }
}
```

### TODO: Command Example 
### TODO: Serializers Example
### TODO: Router Example
### TODO: Backbone + Ember Data Model Generator
### TODO: Interactive API Documentation Generator
### TODO: Objective-C CoreData Configuration Generator 

## Installation

Add this line to your application's Gemfile:

    gem 'smooth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smooth

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
