module Nitron
module UI
  module DataBindingSupport
    def model
      @_model
    end

    def model=(model)
      @_model = model

      DataBinder.shared.bind(model, view)
    end

    def viewDidLoad
      super

      DataBinder.shared.bind(model, view)
    end
  end
end
end
