module Nitron
module UI
  module DataBindingSupport
    def dealloc
      if @_bindings
        @_bindings = nil
      end

      if @_model
        @_model = nil
      end

      super
    end

    def model
      @_model
    end

    def model=(model)
      @_model = model

      DataBinder.shared.bind(model, view)
    end

    def viewDidLoad
      super

      @_bindings = DataBinder.shared.bind(model, view)
    end
  end
end
end
