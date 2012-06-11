module Nitron
module UI
  class DataBoundTableDelegate
    def initWithDelegate(delegate)
      if init
        @delegate = delegate
      end

      self
    end

    def method_missing(method, *args, &block)
      if @delegate
        @delegate.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method)
      if method == "tableView:willDisplayCell:forRowAtIndexPath"
        true
      elsif @delegate
        @delegate.respond_to?(method)
      else
        super
      end
    end

    def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
      if @delegate && @delegate.respond_to?("tableView:willDisplayCell:forRowAtIndexPath:")
        @delegate.tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
      end

      model = tableView.dataSource.objectAtIndexPath(indexPath)

      Nitron::UI::DataBinder.shared.bind(model, cell)
    end
  end
end
end
