module Nitron
  module Data
    class Relation < NSFetchRequest
      include Data::Relation::CoreData
      include Data::Relation::FinderMethods

      def initWithClass(klass)
        self.entity = klass.entity_description if init
        self
      end
    end
  end
end
