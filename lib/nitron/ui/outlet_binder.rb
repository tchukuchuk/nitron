module Nitron
module UI
  class OutletBinder
    def bind(controller, view)
      discover(controller, view)
      wire(controller, view)
    end

  private

    def discover(controller, view)
      view.outlets.each do |outlet, subview|
        controller.instance_variable_set("@#{outlet}", subview)
        controller.class.send(:attr_reader, outlet) unless controller.class.respond_to?(outlet)
      end
    end

    def wire(controller, view)
      handlers = []

      controller.class.outletHandlers.each do |outlet, attributes|
        handler = attributes[:handler]

        unless controller.respond_to?(outlet)
          unless attributes[:default]
            puts "Unable to find outlet for '#{outlet}'. Did you specify it in your XIB/Storyboard?"
          end

          next
        end

        # TODO: weak ref in handler
        evalHandler = proc { controller.instance_eval(&handler) }
        handlers << evalHandler

        controller.send(outlet).addTarget(evalHandler, action:"call", forControlEvents:UIControlEventTouchUpInside)
      end

      handlers
    end
  end
end
end
