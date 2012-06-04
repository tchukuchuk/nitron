module Nitron
module UI
  module DataBindingSupport
    def dealloc
      super

      if @_bindings
        @_bindings.each { |binding| binding.unbind }
        @_bindings = []
      end
    end

    def model
      @_model
    end

    def model=(model)
      @_model = model

      if @_bindings
        @_bindings.each do |binding|
          binding.bind(model)
        end
      end
    end

    def viewDidLoad
      super

      dataBinder = DataBinder.new
      @_bindings = dataBinder.bind(model, view)
    end
  end
end
end
