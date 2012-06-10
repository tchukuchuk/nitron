require 'nitron/version'

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), "nitron/**/*.rb")).each do |file|
    app.files.unshift(file)
  end

  app.files.unshift(File.join(File.dirname(__FILE__), 'nitron/view_controller.rb'))
  app.files.unshift(File.join(File.dirname(__FILE__), 'nitron/ui/data_binding_support.rb'))
  app.files.unshift(File.join(File.dirname(__FILE__), 'nitron/ui/outlet_support.rb'))
  app.files.unshift(File.join(File.dirname(__FILE__), 'nitron/ui/action_support.rb'))

  unless app.frameworks.include?("CoreData")
    app.frameworks << "CoreData"
  end
end
