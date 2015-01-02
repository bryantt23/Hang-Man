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
        #get length of dictionary dynamically
        word_count = file.readlines.size
        #generate a random number between 0 and word_count (to choose random word)    
        word=rand(word_count).ceil
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
    while @turns < 11
      puts "\n***** Number of turns remaining: #{11-@turns} *****"
      puts
      puts @dashes.join

      puts "Guess a letter!"
      guess = gets.downcase.chomp
      if guess == ''
        puts "Invalid guess. Guess again."
        playGame
      elsif guess == "save"
        save_game
        exit
      end
      checkGuessed(guess)
      checkWord(guess)
      if checkVictory
        exit
      end
      
    end 
    puts "Game over! You lose! The word was: #{@value}"
  end 

  def checkGuessed(letter)
    if @guessed.include?(letter)
      puts "You've already guessed \"#{letter}\"! Guess again!"
      playGame
    else
      @guessed << letter
    end
  end

  def checkWord(letter)
    @value.split('').each_with_index do |char,index|
      if char == letter
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
    if !(File.exist?("saves/saved_games.csv"))
      puts "There are no saved games.\n Beginning a new game."
      Hangman.new()
    end

    puts "\nSaved Games:\n"
    saves=CSV.open 'saves/saved_games.csv'
    saves.each do |row|
      puts "Name: #{row[0]}, Turns left: #{row[1]}, Letters guessed: #{row[2]}, Current Game: #{row[3]}"
    end
    puts "\nPlease choose a game to continue"
    choice=gets.chomp
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