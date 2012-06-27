$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  app.development do
    app.files << "lib/spec/spec_delegate.rb"
    app.delegate_class = "SpecDelegate"
  end

  app.name = "NitronTestSuite"
  app.identifier = "io.nitron.testsuite"
end


