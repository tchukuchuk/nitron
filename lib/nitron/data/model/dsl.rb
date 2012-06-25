module Nitron
module Data
module Model
  module DSL
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def attribute(*args)
      end

      def belongs_to(*args)
      end

      def has_and_belongs_to_many(*args)
      end

      def has_many(*args)
      end

      def has_one(*args)
      end
    end
  end
end
end
end
