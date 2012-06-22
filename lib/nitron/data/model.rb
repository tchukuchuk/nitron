module Nitron
  class Model < NSManagedObject

    include Data::Model::CoreData
    include Data::Model::FinderMethods
    include Data::Model::Persistence
    include Data::Model::Validations

    def inspect
      properties = entity.properties.map { |property| "#{property.name}: #{valueForKey(property.name).inspect}" }
      "#<#{entity.name} #{properties.join(", ")}>"
    end

  end
end