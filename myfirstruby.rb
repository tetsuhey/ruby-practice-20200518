class MegaGreeter
    attr_accessor :names
  
    # Create the object
    def initialize(names = "World")
      @namesObj = names
    end
  
    # Say hi to everybody
    def say_hi
      if @namesObj.nil?
        puts "..."
      elsif @namesObj.respond_to?("each")
        # @names is a list of some kind, iterate!
        @namesObj.each do |name|
          puts "Hello #{name}!"
        end
      else
        puts "Hello #{@namesObj}!"
      end
    end
  
    # Say bye to everybody
    def say_bye
      if @namesObj.nil?
        puts "..."
      elsif @namesObj.respond_to?("join")
        # Join the list elements with commas
        puts "Goodbye #{@namesObj.join(", ")}.  Come back soon!"
      else
        puts "Goodbye #{@namesObj}.  Come back soon!"
      end
    end
  end
  
  
  if __FILE__ == $0
    mg = MegaGreeter.new
    mg.say_hi
    mg.say_bye
  
    # Change name to be "Zeke"
    mg.names = "Zeke"
    mg.say_hi
    mg.say_bye
  
    # Change the name to an array of names
    mg.names = ["Albert", "Brenda", "Charles",
                "Dave", "Engelbert"]
    mg.say_hi
    mg.say_bye
  
    # Change to nil
    mg.names = nil
    mg.say_hi
    mg.say_bye
  end