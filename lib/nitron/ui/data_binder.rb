module Nitron
module UI
  class DataBinder
    def self.shared
      @singleton ||= alloc.init
    end

    def bind(model, view, options={})
      bindings = []

      view.dataBindings.each do |keyPath, subview|
        if subview.respond_to?(:text=)
          subview.text = model.valueForKeyPath(keyPath)
        end
      end

      bindings
    end
  end
end
end
