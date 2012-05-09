class AppDelegate
  def managedObjectContext
    @managedObjectContext ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = Spry::Entity.registeredEntityClasses.map(&:entityDescription)
      coordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)

      # TODO: configurable DB URL
      # TODO: DB name should default to application name
      documentsDirectory = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).lastObject;
      storeURL = documentsDirectory.URLByAppendingPathComponent("db.sqlite")

      error_ptr = Pointer.new(:object)
      unless coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:nil, error:error_ptr)
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = coordinator

      context
    end
  end
end
