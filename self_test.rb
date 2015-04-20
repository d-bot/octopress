class Test

  attr_accessor :file

  def initialize
    self.file = File.open("self_at.txt", 'r')
    self.file.each do |line|
      if line =~ /line4/
        puts "read line4 so far"
        continue(self)
      end
    end
  end

  def continue(obj)
    p obj.file.take_while { |line| not(line =~ /line9/) }
    print_rest(self)
  end

  def print_rest(obj)
    puts "print the rest..."
    obj.file.each { |line| puts line }
  end
end

test = Test.new

#test.file.each { |line| puts line }
