module Nitron
module UI
  class OutletBinder
    def bind(controller, view)
      view.outlets.each do |outlet, subview|
        controller.instance_variable_set("@#{outlet}", subview)
        controller.class.send(:attr_reader, outlet) unless controller.class.respond_to?(outlet)
      end
    end
  end
end
end
