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
        :selected   => lambda { |entity| },
        :groupBy    => nil,
        :groupIndex => false
      }
    end

    def self.group_by(name, opts={})
      options[:groupBy] = name.to_s
      options[:groupIndex] = opts[:index] || false
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
          EntityAdapter.new(items, self, self.class.options[:groupBy])
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

    def numberOfSectionsInTableView(tableView)
      collection.numberOfSections
    end

    def sectionIndexTitlesForTableView(tableView)
      if self.class.options[:groupIndex]
        collection.sectionIndexTitles
      else
        nil
      end
    end

    def sectionForSectionIndexTitle(title, atIndex:index)
      collection.sectionForSectionIndexTitle(title, index)
    end

    def tableView(tableView, titleForHeaderInSection:section)
      collection.titleForSection(section)
    end

    def viewDidLoad
      view.dataSource = self
      view.delegate   = self
    end

    def viewWillAppear(animated)
      super

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

      def numberOfSections
        1
      end

      def numberOfRowsInSection(section)
        @collection.size
      end

      def objectAtIndexPath(indexPath)
        @collection[indexPath.row]
      end

      def titleForSection(section)
        nil
      end
    end

    class EntityAdapter
      def initialize(collection, owner, sectionNameKeyPath)
        context = UIApplication.sharedApplication.delegate.managedObjectContext

        @controller = NSFetchedResultsController.alloc.initWithFetchRequest(collection,
                                                                            managedObjectContext:context,
                                                                            sectionNameKeyPath:sectionNameKeyPath,
                                                                            cacheName:nil)
        @controller.delegate = owner

        errorPtr = Pointer.new(:object)
        unless @controller.performFetch(errorPtr)
          raise "Error fetching data"
        end
      end

      def numberOfRowsInSection(section)
        @controller.sections[section].numberOfObjects
      end

      def numberOfSections
        @controller.sections.size
      end

      def objectAtIndexPath(indexPath)
        @controller.objectAtIndexPath(indexPath)
      end

      def sectionIndexTitles
        @controller.sectionIndexTitles
      end

      def sectionForSectionIndexTitle(title, atIndex:index)
        @collection.sectionForSectionIndexTitle(title, atIndex:index)
      end

      def titleForSection(section)
        @controller.sections[section].name
      end
    end
  end
end
