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
      if control.respond_to?(:text=)
        control.text = model.valueForKeyPath(keyPath)
      end
    end
  end
end
end
