class AppDelegate
  def managedObjectContext
    @managedObjectContext ||= begin
      applicationName = NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleName")

      documentsDirectory = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).lastObject;
      storeURL = documentsDirectory.URLByAppendingPathComponent("#{applicationName}.sqlite")

      options = {
        NSMigratePersistentStoresAutomaticallyOption => true,
        NSInferMappingModelAutomaticallyOption => true
      }

      error_ptr = Pointer.new(:object)
      if metadata = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL:storeURL, error:error_ptr)
        puts metadata.inspect
      end

      error_ptr = Pointer.new(:object)
      unless persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:storeURL, options:options, error:error_ptr)
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = persistentStoreCoordinator

      context
    end
  end

  def managedObjectModel
    @managedObjectModel ||= begin
      momds = NSBundle.mainBundle.URLsForResourcesWithExtension("momd", subdirectory:".")
      unless momds
        return nil
      end

      model = NSManagedObjectModel.alloc.initWithContentsOfURL(momds.first)#.mutableCopy
=begin
      model.entities.each do |entity|
        begin
          Kernel.const_get(entity.name)
          entity.setManagedObjectClassName(entity.name)

        rescue NameError
          entity.setManagedObjectClassName("Model")
        end
      end
=end
      model
    end
  end

  def persistentStoreCoordinator
    @coordinator ||= NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(managedObjectModel)
  end
end

