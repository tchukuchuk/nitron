module Nitron
module UI
  module OutletSupport
    def viewDidLoad
      super

      outletBinder = OutletBinder.new
      outletBinder.bind(self, view)
    end
  end
end
end
