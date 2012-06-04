module Nitron
  class StaticTableViewController < ViewController
    def setValue(value, forKey: key)
      if key == "staticDataSource"
        @_dataSource = value
      else
        super
      end
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      cell = tableView.cellForRowAtIndexPath(indexPath)

      if outlet = cell.outlets.first
        handler = self.class.outletHandlers[outlet[0]]

        if handler
          self.instance_eval(&handler[:handler])
        end
      end
    end

    def tableView(tableView, heightForRowAtIndexPath:indexPath)
      cell = @_dataSource.tableView(tableView, cellForRowAtIndexPath:indexPath)

      cell.bounds.size.height
    end

    def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
      Nitron::UI::DataBinder.shared.bind(model, cell)
    end

    def viewWillAppear(animated)
      super

      view.dataSource = @_dataSource
      view.delegate = self
    end
  end
end

