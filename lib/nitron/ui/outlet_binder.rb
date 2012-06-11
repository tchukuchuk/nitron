module Nitron
module UI
  class OutletBinder
    def bind(controller, view)
      # Emulate IB's outlets by using KVC.
      view.outlets.each do |outlet, subview|
        controller.setValue(subview, forKey:outlet)
      end
    end
  end
end
end
