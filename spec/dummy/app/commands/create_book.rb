class CreateBook < Smooth.config.command_class
  def execute
    model_class.create(title: title)
  end
end
