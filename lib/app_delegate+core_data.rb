class AppDelegate
  def managedObjectContext
    @managedObjectContext ||= begin
      # TODO: configurable DB URL
      # TODO: DB name should default to application name
      documentsDirectory = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).lastObject;
      storeURL = documentsDirectory.URLByAppendingPathComponent("db.sqlite")

      error_ptr = Pointer.new(:object)
      unless persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:nil, error:error_ptr)
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context = NSManagedObjectContext.alloc.init
      context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      context.persistentStoreCoordinator = persistentStoreCoordinator

      context
    end
  end

  def persistentStoreCoordinator
    @coordinator ||= begin
      model = NSManagedObjectModel.alloc.init
      model.entities = Nitron::Entity.registeredEntityClasses.map(&:entityDescription)

      NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
    end
  end
end
