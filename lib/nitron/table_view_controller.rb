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
        :collection   => lambda { },
        :groupBy      => nil,
        :groupIndex   => false,
      }
    end

  protected

    def controllerDidChangeContent(controller)
      view.reloadData()
    end

    def dataSource
      @_dataSource ||= begin
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
    end

    def prepareForSegue(segue, sender:sender)
      model = dataSource.objectAtIndexPath(view.indexPathForSelectedRow)

      if sender.is_a?(UITableViewCell)
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

    def tableView(tableView, willDisplayCell:cell, forRowAtIndexPath:indexPath)
      model = dataSource.objectAtIndexPath(indexPath)

      dataBinder = Nitron::UI::DataBinder.new
      dataBinder.bind(model, cell, :observe => false)
    end

    def viewDidLoad
      super

      view.dataSource = dataSource
      view.delegate = self
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
