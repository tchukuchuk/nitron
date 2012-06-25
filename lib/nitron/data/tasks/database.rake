require 'fileutils'

namespace :db do
  desc "Migrates the data model by generating the schema from models"
  task :migrate do
    generated_schema = build()

    # Create db/schema.xcdatamodeld if necessary.
    FileUtils.mkdir_p(File.join("db", "schema.xcdatamodeld"))

    # Load current schema and version.
    current_schema = nil
    if version = get_current_schema_version()
      File.open(File.join(get_current_schema(), "contents")) do |f|
        current_schema = f.read
      end
    end

    # TODO: better diff? If we change the output at all, this re-migrates.
    if current_schema != generated_schema
      version = (version || 0) + 1
      latest_schema_path = xcdatamodeld_path("schema.#{version}.xcdatamodel")
      unless Dir.exists?(latest_schema_path)
        Dir.mkdir(latest_schema_path)
      end

      File.open(File.join(latest_schema_path, "contents"), "w") do |file|
        file.write(generated_schema)
      end

      set_current_schema(version)

      unless File.symlink?("resources/schema.xcdatamodeld")
        File.symlink("../db/schema.xcdatamodeld", "resources/schema.xcdatamodeld")
      end

      puts "Migrated data model to version #{version}"
    end
  end

  desc "Rolls the schema back to the previous version"
  task :rollback do
    version = get_current_schema_version()

    fail "No schema found!" if version == nil
    fail "Can't rollback a schema already at version 1!" if version == 1

    schema = get_current_schema()

    set_current_schema(version - 1)
    FileUtils.rm_rf(schema)

    puts "Rolled back data model to version #{version - 1}"
  end

  namespace :schema do
    desc "Dump an XML representation of the current schema to STDOUT"
    task :dump do
      current_schema = get_current_schema()
      fail "No schema found!" unless current_schema

      puts File.open(File.join(get_current_schema(), "contents")).read
    end
  end

  desc "Retrieves the current schema version of the data model"
  task :version do
    version = get_current_schema_version()
    fail "No schema found!" unless version

    puts "Current version: #{version}"
  end

  def build
    model_files = Dir.glob("app/models/*.rb") do |filename|
      File.open(filename) { |file| eval(file.read) }
    end

    model_attributes = {
      :name => "",
      :userDefinedModelVersionIdentifier => "",
      :type => "com.apple.IDECoreDataModeler.DataModel",
      :documentVersion => "1.0",
      :lastSavedToolsVersion => "1171",
      :systemVersion => "11D50",
      :minimumToolsVersion => "Automatic",
      :macOSVersion => "Automatic",
      :iOSVersion => "Automatic"
    }

    builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
      xml.model(model_attributes) do
        Nitron::Model.subclasses.each do |model|
          xml.entity(:name => model[:name], :representedClassName => model[:name]) do
            model[:attributes].each do |attr|
              xml.attribute(attr)
            end

            model[:relationships].each do |rl|
              xml.relationship(rl)
            end
          end
        end
      end
    end

    builder.to_xml
  end

  def get_current_schema
    plist = xcdatamodeld_path(".xccurrentversion")
    return nil unless File.exists?(plist)

    xcdatamodeld_path(Nokogiri::XML(File.open(plist)).at_xpath("/plist/dict/string").text)
  end

  def get_current_schema_version
    return nil unless path = get_current_schema

    version = nil
    path.match(/\.([0-9]+)\.xcdatamodel$/) do |match|
      version = match[1].to_i
    end

    version
  end

  def set_current_schema(version)
    File.open(xcdatamodeld_path(".xccurrentversion"), "w") do |file|
      file.write(<<-PLIST)
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>_XCCurrentVersionName</key>
  <string>schema.#{version}.xcdatamodel</string>
</dict>
</plist>
PLIST
    end
  end

  def xcdatamodeld_path(*args)
    parts = ["db", "schema.xcdatamodeld"] + args

    File.join(parts)
  end
end

module Nitron
  class Model
    class << self
      def attribute(name, type, options={})
        if type == Time
          type = "Date"
        end

        model_metadata[:attributes][name] = {
          :name => name,
          :attributeType => type.to_s,
          :syncable => "YES"
        }
      end

      def belongs_to(name)
        relationship_for(self.name, name).update({
          :name => name,
          :optional => "YES",
          :minCount => "1",
          :maxCount => "1",
          :deletionRule => "Nullify",
          :syncable => "YES"
        })
      end

      def has_one(name, options)
        options[:class] = options[:class].to_s
        options[:inverse_of] = options[:inverse_of].to_s

        relationship_for(self.name, name).update({
          :name => name,
          :optional => "YES",
          :deletionRule => "Nullify",
          :destinationEntity => options[:class],
          :inverseName => options[:inverse_of].to_s,
          :inverseEntity => options[:class],
          :minCount => "1",
          :maxCount => "1",
          :syncable => "YES"
        })

        relationship_for(options[:class], options[:inverse_of]).update({
          :destinationEntity => self.name,
          :inverseEntity => self.name,
          :inverseName => name
        })
      end

      def has_many(name, options)
        options[:class] = options[:class].to_s
        options[:inverse_of] = options[:inverse_of].to_s

        relationship_for(self.name, name).update({
          :name => name,
          :optional => "YES",
          :toMany => "YES",
          :deletionRule => "Nullify",
          :destinationEntity => options[:class],
          :inverseName => options[:inverse_of].to_s,
          :inverseEntity => options[:class],
          :syncable => "YES"
        })

        relationship_for(options[:class], options[:inverse_of]).update({
          :destinationEntity => self.name,
          :inverseEntity => self.name,
          :inverseName => name
        })
      end

      def model_metadata(entity_class = nil)
        entity_class ||= name

        @@models ||= {}
        @@models[entity_class] ||= {
          :name => entity_class,
          :attributes => {},
          :relationships => {}
        }
      end

      def relationship_for(entity_class, name)
        model_metadata(entity_class)[:relationships][name.to_s] ||= {}
      end

      def subclasses
        subclasses = []

        @@models.keys.sort.each do |name|
          model = @@models[name]

          subclasses << {
            :name => model[:name],
            :attributes => model[:attributes].values.sort { |a,b| a[:name] <=> b[:name] },
            :relationships => model[:relationships].values.sort { |a,b| a[:name] <=> b[:name] }
          }
        end

        subclasses
      end
    end
  end
end


