require "spec_helper"

describe "The Smooth Command" do
  let(:books) { Smooth.current_api.resource("Books") }
  let(:command) { books.fetch(:command, :like) }

  it "should know the resource name" do
    expect(command.resource_name).to eq("Books")
  end

  it "should know the command action" do
    expect(command.command_action).to eq("like")
  end

  it "should know the event namespace" do
    expect(command.event_namespace).to eq("like.book")
  end

  it "should know the model class" do
    expect(command.model_class).to equal(Book)
  end

  describe "Interface Documentation" do
    it "should document the interface" do
      expect(command.interface_documentation).not_to be_empty
    end

    it "should allow for descriptions of the filters" do
      expected = "You can manually pass true or false.  If you leave it off, it will toggle the liking status"
      expect(command.input_descriptions[:like]).to eq(expected)

      # we didn't document this so it should be blank
      expect(command.input_descriptions[:left_out]).to be_blank
    end
  end

  describe "Automatic model scoping" do
    it "should provide a reference to the model scope" do
      class Book < ActiveRecord::Base
        scope :published_after, ->(year) { where(year_published: year) }
        scope :no_args, -> {all}
      end

      k = Class.new(Smooth::Command) do
        self.model_class  = Book

        scope(:published_after)

        required do
          string :title
        end

        def execute
          scope.where(title: title).first_or_create
        end
      end

      # This is just laziness since i don't have a user model yet.
      # I am just making sure that this value makes it to the scope anyway
      book = k.as(2001).run(title:"sup").result

      expect(book.year_published).to eq(2001)
      expect(book.title).to eq("sup")
    end
  end

  describe "Current user awareness" do
    it "should be aware of who is running the command" do
      k = Class.new(Smooth::Command) do
        required do
          integer :argument
        end

        def execute
          argument + current_user
        end
      end

      expect(k.as(1).run(argument: 2).result).to eq(3)
    end
  end

  describe "Event Tracking Integration" do
    it "should track events" do
      bucket = []

      Smooth.subscribe_to(/like.book/)  do |event|
        bucket << event
      end

      command.run()

      expect(bucket).not_to be_empty
    end
  end
end
