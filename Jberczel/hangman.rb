require 'yaml'

class Hangman
  def initialize
    
#     looks like this is how to open, then how to read    
#     store info as content
    content = File.open('5desk.txt', 'r') { |file| file.read } # loads dictionary file
    
#     i guess it splits it by whitespace, in this case by line
    valid_words = content.split.select { |word| word.length.between?(5,12) }  # filters words 5-12 letters
    
#     it selects from the list of valid words, makes it lower case    
#     .size returns the size of the valid words, not sure why it does that
    @word = valid_words[rand(valid_words.size)].downcase.split('') #selects random word
    
#     create a new array that is the size of the selected word from above    
#     i think it puts _ for the length of the word
    @display = Array.new(@word.length, '_')
    
#     looks like this is the array to track to wrong guesses
    @misses = Array.new # tracks guesses that were not in word

#     initialize the number of guesses
    @turns = 6 #turns left before game over
  end

  # simulates one game of hangman
  def play
  # this is the default result, that is reached if the while loop completes
    result = "Sorry, you lose.  The word was #{@word.join}."
    
    
  # while there are remaining turns
    while @turns > 0
      
  # display & guess methods are to show info to user
      
      display # displays number of letters, misses, turns remaining
      guess # prompts user for letters
  
=begin
      
  none? [{ |obj| block }] 
 true or false
  Passes each element of the collection to the given block. The method returns true if the block 
  never returns true for all elements. If the block is not given, none? will return true only if 
  none of the collection members is true
=end
  
  
  # i think it means if the method never returns true for all of the elements but i'm not sure
      if @display.none? { |i| i == '_' }
  
  # winning result
        result = "#{@display.join('  ')}\nCongrats, you win!"
        @turns = 0
      end
    end
    puts result
  end

  # displays relevant info to user
  def display
  
  # for each i, print i  
  # i is the letter
    @display.each { |i| print "#{i}  " }
    puts "\n"
  
  # missed are joined by the ", "
    puts "Misses: #{@misses.join(', ')}"
  
  # @ refers to the instance variable
    puts "Turns Remaining: #{@turns}"
  end

  def guess
    print 'Enter guess: '
    input = gets.chomp
    puts "\n"

  # so user can save
    if input == 'save'
  # call save method
      save_game
      puts 'Game has been saved.', "\n"
      
  # if the input does not match any of the elements in word variable
  # if the number of matches for word is none
  
    elsif @word.none? { |w| w == input } # add unfound letter to misses array, reduce turns

  # push it to the misses array
      @misses << input
  # decrement turns
      @turns -= 1
      
    else
  # add letter to display array
      @word.each_with_index do |letter, i| # add letter to display array
  # i guess this makes sure it matches the correct position? 
        @display[i] = letter if letter == input
      end
    end
  end
end

def load_game
  # the name of the saved file
  
  # assumes file exists
  content = File.open('games/saved.yaml', 'r') { |file| file.read }
  YAML.load(content) # returns a Hangman object
end

def save_game
  # make directory, unless it already exists. i think that's what it says
  Dir.mkdir('games') unless Dir.exist? 'games'

  # name & location of file
  filename = 'games/saved.yaml'
  File.open(filename, 'w') do |file|
    file.puts YAML.dump(self)
  end
end

# method used to validate y/n responses from users
def valid_answer(q)
  input = ''

  # keep going until user types in y or n
  until input == 'y' || input == 'n'
    print q
    input = gets.chomp
  end
  input
end

# main program loop
puts "\nWELCOME TO HANGMAN\n"
loop do 
  # i guess this gives instruction to user but also takes in the input
  input = valid_answer('Do you want to load previously saved game (y/n)? ')
  puts "Thank you.  You can save game at any moment by typing 'save'."

  # new Hangman class
  game = input == 'y' ? load_game : Hangman.new
  # call play method
  game.play
  input2 = valid_answer('Play another game (y/n)? ')
  break if input2 == 'n'
end