module Spry
  class Entity < NSManagedObject
    # TODO: flesh this out
    ATTRIBUTE_TYPES = {
      String  => NSStringAttributeType,
      Time    => NSDateAttributeType
    }

    def self.context
      UIApplication.sharedApplication.delegate.managedObjectContext
    end

    def self.entityDescription
      @entityDescription ||= begin
        entity = NSEntityDescription.alloc.init
        entity.name = self.name
        entity.managedObjectClassName = entity.name
        entity.properties = @attributes

        entity
      end
    end

    def self.field(name, options={})
      attributeDescription = NSAttributeDescription.alloc.init
      attributeDescription.name = name.to_s
      attributeDescription.optional = false
      attributeDescription.attributeType = ATTRIBUTE_TYPES[options[:type]]

      unless attributeDescription.attributeType
        raise "Unknown field type: #{options[:type]}"
      end

      @attributes << attributeDescription
    end

    def self.inherited(subclass)
      subclass.instance_variable_set(:@attributes, [])

      registeredEntityClasses << subclass
    end

    def self.registeredEntityClasses
      @registeredEntityClasses ||= []
    end

    def self.new
      self.alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:nil)
    end

    def destroy
      self.class.context.deleteObject(self)

      save()
    end

    def save
      unless isDeleted
        self.class.context.insertObject(self) if managedObjectContext == nil
      end

      error_ptr = Pointer.new(:object)
      unless self.class.context.save(error_ptr)
        raise "Error when saving the model: #{error_ptr[0].description}"
      end
    end
  end
end
