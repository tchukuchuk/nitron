module Nitron
module UI
  module ActionSupport
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def on(outlet, &block)
        actions[outlet.to_s] = { :handler => block }
      end

      def actions
        @_actions ||= {
          "cancel" => { :handler => proc { close }, :default => true },
          "done"   => { :handler => proc { close }, :default => true }
        }
      end
    end

    def _dispatch(sender)
      if action = @_actions[sender]
        instance_eval &action[:handler]
      end
    end

    def dealloc
      @_actions.clear

      super
    end

    def viewDidLoad
      super

      @_actions = {}

      self.class.actions.each do |outlet, action|
        if respond_to?(outlet)
          target = send(outlet)
          @_actions[target] = self.class.actions[outlet]

          target.addTarget(self, action:"_dispatch:", forControlEvents:UIControlEventTouchUpInside)
        end
      end
    end
  end
end
end
