module Nitron
module UI
  class DataBinder
    def self.shared
      @singleton ||= alloc.init
    end

    def bind(model, view, options={})
      if view.is_a?(UITableView)
        view.delegate = DataBoundTableDelegate.alloc.initWithDelegate(view.delegate)
        return [view.delegate]
      end

      view.dataBindings.each do |keyPath, subview|
        bindControl(model, subview, keyPath)
      end

      nil
    end

  private

    def bindControl(model, control, keyPath)
      value = model.valueForKeyPath(keyPath)

      if control.respond_to?(:text=)
        control.text = value
      elsif control.respond_to?(:image=)
        control.image = value
      elsif control.respond_to?(:value=)
        control.value = value
      elsif control.respond_to?(:on=)
        control.on = value
      elsif control.respond_to?(:progress=)
        control.progress = value
      elsif control.respond_to?(:date=)
        control.date = value
      else
        puts "Sorry, data binding is not supported for an instance of '#{control.class.name}' :("
      end

    rescue
      puts "***ERROR: Failed to bind value #{value.inspect} (read from '#{model.class.name}.#{keyPath}') to #{control.inspect}"

      raise
    end
  end
end
end
