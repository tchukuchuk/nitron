module Nitron
module UI
  module OutletSupport
    def setValue(value, forUndefinedKey:key)
      unless self.class.respond_to?(key)
        self.class.send(:attr_reader, key)
      end

      instance_variable_set("@#{key}", value)
    end

    def viewDidLoad
      super

      outletBinder = OutletBinder.new
      outletBinder.bind(self, view)
    end
  end
end
end
