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

      if cell.respond_to?(:binding)
        binding = cell.binding
        if binding && binding.length > 0
          method = binding + "Selected"

          if respond_to?(method)
            send(method)
          end
        end
      end
    end

    def tableView(tableView, heightForRowAtIndexPath:indexPath)
      cell = @_dataSource.tableView(tableView, cellForRowAtIndexPath:indexPath)

      cell.bounds.size.height
    end

    def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
      dataBinder = Nitron::UI::DataBinder.new
      dataBinder.bind(model, cell.contentView, :observe => false)
    end

    def viewWillAppear(animated)
      super

      view.dataSource = @_dataSource
      view.delegate = self
    end
  end
end

