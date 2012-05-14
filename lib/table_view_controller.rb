module Nitron
  class TableViewController < UITableViewController
    def self.collection(&block)
      options[:collection] = block
    end

    def self.options
      @options ||= {
        :collection => lambda { },
        :title      => self.name.gsub("ViewController", ""),
        :layout     => lambda { |cell, entity| },
        :selected   => lambda { |entity| }
      }
    end

    def self.layout(&block)
      options[:layout] = block
    end

    def self.selected(&block)
      options[:selected] = block
    end

    def self.title(title=nil, &block)
      if block_given?
        options[:title] = block
      elsif title
        options[:title] = title
      end
    end

  protected

    def push(controllerClass, args={})
      controller = controllerClass.alloc.init

      args.each do |property, value|
        controller.send("#{property.to_s}=", value)
      end

      navigationController.pushViewController controller, animated:true
    end

  protected

    def collection
      @collection ||= begin
        items = self.instance_eval(&self.class.options[:collection])

        case items
        when Array
          ArrayAdapter.new(items)
        when NSFetchRequest
          EntityAdapter.new(items, self)
        else
          raise "collection block must return either an Array or an NSFetchRequest"
        end
      end
    end

    def controllerDidChangeContent(controller)
      view.reloadData()
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)
      @cellReuseIdentifier ||= "#{self.class.options[:entity_name]}Cell"
      cell = view.dequeueReusableCellWithIdentifier(@cellReuseIdentifier) ||
        UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:@cellReuseIdentifier)

      self.instance_exec(cell, collection.objectAtIndexPath(indexPath), &self.class.options[:layout])

      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      self.instance_exec(collection.objectAtIndexPath(indexPath), &self.class.options[:selected])
    end

    def tableView(tableView, numberOfRowsInSection:section)
      collection.numberOfRowsInSection(section)
    end

    def viewDidLoad
      view.dataSource = self
      view.delegate   = self
    end

    def viewWillAppear(animated)
      if self.class.options[:title].respond_to?(:call)
        self.title = self.instance_eval(&self.class.options[:title])
      else
        self.title = self.class.options[:title]
      end
    end

  protected

    class ArrayAdapter
      def initialize(collection)
        @collection = collection
      end

      def objectAtIndexPath(indexPath)
        @collection[indexPath.row]
      end

      def numberOfRowsInSection(section)
        @collection.size
      end
    end

    class EntityAdapter
      def initialize(collection, owner)
        context = UIApplication.sharedApplication.delegate.managedObjectContext

        @controller = NSFetchedResultsController.alloc.initWithFetchRequest(collection,
                                                                            managedObjectContext:context,
                                                                            sectionNameKeyPath:nil,
                                                                            cacheName:nil)
        @controller.delegate = owner

        errorPtr = Pointer.new(:object)
        unless @controller.performFetch(errorPtr)
          raise "Error fetching data"
        end
      end

      def objectAtIndexPath(indexPath)
        @controller.objectAtIndexPath(indexPath)
      end

      def numberOfRowsInSection(section)
        @controller.sections[section].numberOfObjects
      end
    end
  end
end
