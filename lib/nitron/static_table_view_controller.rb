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

    def viewWillAppear(animated)
      view.dataSource = @_dataSource
      view.delegate = self

      # The data binding module may wrap view.delegate, so run it after we've set up.
      super
    end
  end
end

