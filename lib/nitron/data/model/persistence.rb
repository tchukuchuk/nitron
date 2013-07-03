module Nitron
  module Data
    class Model < NSManagedObject
      module Persistence
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def create(attributes={})
            begin
              model = create!(attributes)
            rescue Nitron::RecordNotSaved
            end
            model
          end

          def create!(attributes={})
            model = new(attributes)
            model.save!
            model
          end

          def new(attributes={})
            new_in_moc(nil, attributes)
          end

          def new_in_moc(moc, attributes = {})
            alloc.initWithEntity(entity_description, insertIntoManagedObjectContext:moc).tap do |model|
              model.instance_variable_set('@new_record', true)
              model.attributes = attributes
            end
          end
        end

        def attributes=(attributes)
          setValuesForKeysWithDictionary(attributes)
          #attributes.each { |keyPath, value| setValue(value, forKey:keyPath) }
        end

        def destroy
          if context = managedObjectContext
            context.deleteObject(self)
            error = Pointer.new(:object)
            context.save(error)
          end

          @destroyed = true
          freeze
        end

        def destroyed?
          @destroyed || false
        end

        def new_record?
          @new_record || false
        end

        def persisted?
          !(new_record? || destroyed?)
        end

        def save
          begin
            save!
          rescue Nitron::RecordNotSaved
            return false
          end
          true
        end

        def save!
          unless context = managedObjectContext
            context = UIApplication.sharedApplication.delegate.managedObjectContext
            context.insertObject(self)
          end

          error = Pointer.new(:object)
          unless context.save(error)
            managedObjectContext.deleteObject(self)
            raise Nitron::RecordNotSaved, self and return false
          end
          true
        end

      end
    end
  end
end
