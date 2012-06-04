module Nitron
module UI
  module OutletSupport
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def on(outlet, &block)
        outletHandlers[outlet.to_s] = { :handler => block }
      end

      def outletHandlers
        @_outletHandlers ||= {
          "cancel" => { :handler => proc { close }, :default => true },
          "done"   => { :handler => proc { close }, :default => true }
        }
      end
    end

    def dealloc
      super

      @_handlers = []
    end

    def viewDidLoad
      super

      outletBinder = OutletBinder.new
      @_handlers = outletBinder.bind(self, view)
    end
  end
end
end
