module Macro
  class Base
    def self.has_many(name)
      puts "#{self} has many #{name}"

      define_method(name) do
        puts "#{name} has been defined"
      end
    end
  end
end

class Checklist < Macro::Base
  has_many :target
end

phase1 = Checklist.new
phase1.target

