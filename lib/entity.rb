module Spry
  class Entity < NSManagedObject
    # TODO: flesh this out
    ATTRIBUTE_TYPES = {
      String  => NSStringAttributeType,
      Time    => NSDateAttributeType
    }

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
  end
end
