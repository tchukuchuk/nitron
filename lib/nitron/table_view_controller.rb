module Nitron
  class TableViewController < ViewController
    def self.collection(&block)
      options[:collection] = block
    end

    def self.group_by(name, opts={})
      options[:groupBy] = name.to_s
      options[:groupIndex] = opts[:index] || false
    end

    def self.options
      @options ||= {
        collection: lambda { [] },
        groupBy:    nil,
        groupIndex: false,
      }
    end
    
    # The idea behind this is that it should be possible to
    # replace the datasource and rely on Motion's GC to
    # clean up after us.
    #
    # This allows for code like:
    #
    #   def onFilterResults(searchText)
    #     mutateDataSource { Task.where('name contains[ac] "foo"') }
    #   end
    #
    # This method is effective for filtering, but can
    # also be used for reordering as:
    #
    #    def onSortAlpha
    #      mutateDataSource { Task.order('name[ac]') }
    #    end
    #
    # N.b.: The default behavior is to reload the
    # data, as the TableView is a data-backed control
    # and why bother filtering or reordering if you
    # don't plan to display? But... in the odd case
    # where you want to do the reload yourself, simply
    # pass +false+ as the argument to mutateDataSource
    # and the automatic reload will be suppressed.
    # 
    def reload(reload = true, &block)
      self.class.options[:collection] = block
      @_dataSource = evaluateDataSource
      view.dataSource = @_dataSource
      view.reloadData if reload
    end

  protected

    def controllerDidChangeContent(controller)
      view.reloadData()
    end

    def dataSource
      @_dataSource ||= evaluateDataSource
    end
    
    def evaluateDataSource
      collection = self.instance_eval(&self.class.options[:collection])

      case collection
      when Array
        ArrayDataSource.alloc.initWithCollection(collection, className:self.class.name)
      when NSFetchRequest
        CoreDataSource.alloc.initWithRequest(collection, owner:self, sectionNameKeyPath:self.class.options[:groupBy], options:self.class.options)
      else
        raise "Collection block must return an Array, or an NSFetchRequest"
      end
    end

    def prepareForSegue(segue, sender:sender)
      model = nil

      if view.respond_to?(:indexPathForSelectedRow)
        if view.indexPathForSelectedRow
          model = dataSource.objectAtIndexPath(view.indexPathForSelectedRow)
        end
      end

      if model
        controller = segue.destinationViewController
        if controller.respond_to?(:model=)
          controller.model = model
        end
      end
    end

    def setValue(value, forKey: key)
      if key == "staticDataSource"
        raise "Static tables are not supported by TableViewController! Please use StaticTableViewController instead."
      else
        super
      end
    end

    def viewDidLoad
      super

      view.dataSource = dataSource
    end

  protected

    class ArrayDataSource
      def initWithCollection(collection, className:className)
        if init
          @collection = collection
          @className = className
        end

        self
      end

      def numberOfSectionsInTableView(tableView)
        1
      end

      def objectAtIndexPath(indexPath)
        @collection[indexPath.row]
      end

      def sectionForSectionIndexTitle(title, atIndex:index)
        nil
      end

      def tableView(tableView, cellForRowAtIndexPath:indexPath)
        @cellReuseIdentifier ||= "#{@className.gsub("ViewController", "")}Cell"
        unless cell = tableView.dequeueReusableCellWithIdentifier(@cellReuseIdentifier)
          puts "Unable to find a cell named #{@cellReuseIdentifier}. Have you set the reuse identifier of the UITableViewCell?"
          return
        end

        cell
      end

      def tableView(tableView, numberOfRowsInSection:section)
        @collection.size
      end
    end

    class CoreDataSource
      def initWithRequest(request, owner:owner, sectionNameKeyPath:sectionNameKeyPath, options:options)
        if init
          context = UIApplication.sharedApplication.delegate.managedObjectContext

          @className = owner.class.name
          @controller = NSFetchedResultsController.alloc.initWithFetchRequest(request,
                                                                              managedObjectContext:context,
                                                                              sectionNameKeyPath:sectionNameKeyPath,
                                                                              cacheName:nil)
          @controller.delegate = owner
          @options = options

          errorPtr = Pointer.new(:object)
          unless @controller.performFetch(errorPtr)
            raise "Error fetching data"
          end
        end

        self
      end

      def numberOfSectionsInTableView(tableView)
        @controller.sections.size
      end

      def objectAtIndexPath(indexPath)
        @controller.objectAtIndexPath(indexPath)
      end

      def sectionForSectionIndexTitle(title, atIndex:index)
        @collection.sectionForSectionIndexTitle(title, atIndex:index)
      end

      def sectionIndexTitlesForTableView(tableView)
        if @options[:groupIndex]
          @controller.sectionIndexTitles
        else
          nil
        end
      end

      def tableView(tableView, cellForRowAtIndexPath:indexPath)
        @cellReuseIdentifier ||= "#{@className.gsub("ViewController", "")}Cell"
        unless cell = tableView.dequeueReusableCellWithIdentifier(@cellReuseIdentifier)
          puts "Unable to find a cell named #{@cellReuseIdentifier}. Have you set the reuse identifier of the UITableViewCell?"
          return nil
        end

        cell
      end

      def tableView(tableView, numberOfRowsInSection:section)
        @controller.sections[section].numberOfObjects
      end

      def tableView(tableView, titleForHeaderInSection:section)
        @controller.sections[section].name
      end
    end
  end
end
