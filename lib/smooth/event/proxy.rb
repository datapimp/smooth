class Smooth::Event::Proxy
  def self.on(*args, &block)
    Smooth::Event.send(:subscribe_to, *args, &block)
  end

  def self.trigger(*args, &block)
    Smooth::Event.send(:track_event, *args, &block)
  end
end
