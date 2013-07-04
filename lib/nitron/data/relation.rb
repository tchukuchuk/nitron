module Nitron
  class Relation < NSFetchRequest
    include Data::Relation::CoreData
    include Data::Relation::FinderMethods

    attr_reader :context

    def initWithClass(klass, context = UIApplication.sharedApplication.delegate.managedObjectContext)
      if init
        self.entity = klass.entity_description
        @context = context
      end
      self
    end
  end
end
