require 'csv'

class Hangman
  @save_id=0

#   instance variables, can now use @
  attr_reader :value, :guessed
  
#   initialize w/ these parameters
  def initialize(value=nil,turns=1,guessed=[],dashes=[])
    
#   i guess this is similar to java constructor?
    @value = value
    @turns=turns
    @guessed = guessed
    @dashes = dashes
    
#   use value from above
    getWord(@value)

#   to display answer for debugging reasons
# puts @value

#   call intro wh/ displays info to user
    intro
    playGame
  end


  def getWord(value)
    @value = value
    
#   if no value
    if @value.nil?
      dictionary = '5desk.txt'
#   try to get a new value from the file
      @value = File.new(dictionary,'r').readlines[rand]
      File.open(dictionary,"r+") do |file|

#   this works b/c each line has 1 word only
        #get length of dictionary dynamically
        word_count = file.readlines.size
        #generate a random number between 0 and word_count (to choose random word)    
        word=rand(word_count).ceil
        
         # rewind method call. This moves the file pointer back to the start of the file so we can read what have written:
        file.rewind
        file.readlines.each_with_index do |value, index|
          if index == word 
          # if value.to_s.length > 5 && value.to_s.length < 13
          #   @value = value.downcase.chomp
          # else
          #   #todo: update this so it won't pick words that are out of range
          #   @value = value.downcase.chomp
          # end

#   only b/w 5 and 12
            unless value.to_s.length > 5 && value.to_s.length < 13
              getWord
            else
              
#   lower case it
              @value = value.downcase.chomp
              
#   number of dashes is equal to length of word
              @value.length.times {|i| @dashes << " _ "}
            end
          end
        end
      end
    else
      
#   i'm thinking this is like a try catch. not sure
      if @dashes.nil?
      @value.length.times {|i| @dashes << " _ "}
      end
    end
    
  end
  def intro
    puts "\nWelcome to Hangman!"
    puts "\nYou have 10 turns to guess the correct word. Good luck!"
    puts "Enter \"SAVE\" at any time to save your game."
  end

  def playGame
#   while still have turns left
    while @turns < 11
      
#   display turns instance variable
      puts "\n***** Number of turns remaining: #{11-@turns} *****"
      puts
#   i guess it joins the dashes
      puts @dashes.join

      puts "Guess a letter!"
      
#   makes it lowercase for comparison
      guess = gets.downcase.chomp
      
#   make sure there was a response
      if guess == ''
        puts "Invalid guess. Guess again."
        playGame

#   for the save commmand
      elsif guess == "save"
#   call the method & exit
        save_game
        exit
      end
#   use the guess as the parameter

#   i think it makes sure the letter hasn't already been used
      checkGuessed(guess)
      checkWord(guess)
      if checkVictory
        exit
      end
      
    end 
    puts "Game over! You lose! The word was: #{@value}"
  end 

  def checkGuessed(letter)
#   check the guessed array(?) & see if it includes the letter the user input
    if @guessed.include?(letter)
      puts "You've already guessed \"#{letter}\"! Guess again!"
      playGame
    else
#   otherwise add it to the guessed array(?)
      @guessed << letter
    end
  end

  def checkWord(letter)

#   i think it is checking the word & separating it into indices?
#   check the char (current letter) with input?
    @value.split('').each_with_index do |char,index|
      
#       if the char is equal to the letter input
      if char == letter
#   put the char in the place of the dash
        @dashes[index] = char
      end
    end
    if @value.include?(letter)
      puts 
      puts "Good guess! #{letter} is in the word!"
      puts 
    else
      puts
      puts "Nope, #{letter} is not in the word."
      puts 
      @turns+=1
    end
  end
  def checkVictory
#       if the joined dashes (remove spaces) matches the actual word
    if @dashes.join('').gsub(/\s+/,'').downcase.chomp == @value.downcase.chomp
      puts "You win! The word was #{@value}!"
      return true
    else
      return false
    end
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    puts "Please name your game!"
    name=gets.chomp
    file=File.open('saves/saved_games.csv', 'ab')
    
#     looks like it writes the same thing as this method

# #   initialize w/ these parameters
  # def initialize(value=nil,turns=1,guessed=[],dashes=[])

    file.write("#{name},#{11-@turns},#{@guessed.join},#{@dashes.join.gsub(/\s+/,'')},#{@value}\n")
    file.close
  end



end


def start
  puts "\nPlease enter 'Load' to load a saved game, or 'New' to start a new game!"
  answer=gets.chomp.downcase
  if answer == 'new'
    Hangman.new()
  elsif answer == 'load'
    load_game
  else
    puts "\n Invalid entry."
    start
  end
end

def load_game
#     check in the directory
    if !(File.exist?("saves/saved_games.csv"))
      puts "There are no saved games.\n Beginning a new game."
      Hangman.new()
    end

    puts "\nSaved Games:\n"
    saves=CSV.open 'saves/saved_games.csv'
    
         # i think this loads the info the file
    saves.each do |row|
      puts "Name: #{row[0]}, Turns left: #{row[1]}, Letters guessed: #{row[2]}, Current Game: #{row[3]}"
    end
    puts "\nPlease choose a game to continue"
    choice=gets.chomp
    
         # rewind method call. This moves the file pointer back to the start of the file so we can read what have written:
    saves.rewind
    saves.each do |row|
      if choice == row[0]
        Hangman.new(row[4],10-row[1].to_i,row[2].split(''),row[3].split(''))
      else
        puts "choice: #{choice}"
      end
    end


end

start