class Player
    attr_accessor :name, :marker
  
    def initialize(name, marker)
      @name = name
      @marker = marker
    end
end
  
  class BoardCase
    attr_accessor :position, :marker
  
    def initialize(position)
      @position = position
      @marker = " "
    end
  end
  
  class Board
    attr_accessor :cases, :move_count
  
    def initialize
      @cases = {}
      ("A".."C").each do |row|
        (1..3).each do |col|
          @cases["#{row}#{col}"] = BoardCase.new("#{row}#{col}")
        end
      end
      @move_count = 0
    end
  
    def display
      Show.display(self)
    end
  
    def update_case(position, marker)
      if @cases[position].marker == " "
        @cases[position].marker = marker
        @move_count += 1
        true
      else
        false
      end
    end
  
    def full?
      @move_count == 9
    end
  
    def winning_combination?(marker)
      winning_combinations.any? do |combination|
        combination.all? { |position| @cases[position].marker == marker }
      end
    end
  
    private
  
    def winning_combinations
      rows = [["A1", "A2", "A3"], ["B1", "B2", "B3"], ["C1", "C2", "C3"]]
      cols = [["A1", "B1", "C1"], ["A2", "B2", "C2"], ["A3", "B3", "C3"]]
      diags = [["A1", "B2", "C3"], ["A3", "B2", "C1"]]
      rows + cols + diags
    end
  end
  
  class Game
    attr_accessor :board, :players, :current_player, :status
  
    def initialize
      @board = Board.new
      @players = []
      @status = "en cours"
    end
  
    def start
      setup_players
      play_game
    end
  
    private
  
    def setup_players
      puts "Entrez le prénom du Joueur 1 :"
      player1 = Player.new(gets.chomp, "X")
      puts "Entrez le prénom du Joueur 2 :"
      player2 = Player.new(gets.chomp, "O")
      @players = [player1, player2]
      @current_player = player1
    end
  
    def play_game
      loop do
        @board.display
        player_move
        if @board.winning_combination?(@current_player.marker)
          @board.display
          puts "#{@current_player.name} a gagné !"
          break
        elsif @board.full?
          @board.display
          puts "Match nul !"
          break
        else
          switch_player
        end
      end
      propose_rematch
    end
  
    def player_move
      loop do
        puts "#{@current_player.name}, choisissez une case (ex: A1, B3) :"
        move = gets.chomp.upcase
        if @board.update_case(move, @current_player.marker)
          break
        else
          puts "Mouvement invalide. Essayez encore."
        end
      end
    end
  
    def switch_player
      @current_player = (@current_player == @players[0]) ? @players[1] : @players[0]
    end
  
    def propose_rematch
      puts "Voulez-vous jouer une autre partie ? (o/n)"
      answer = gets.chomp.downcase
      if answer == 'o'
        @board = Board.new
        play_game
      else
        puts "Merci d'avoir joué !"
      end
    end
  end
  
  class Show
    def self.display(board)
      puts "  1 2 3"
      ["A", "B", "C"].each do |row|
        print row
        (1..3).each do |col|
          position = "#{row}#{col}"
          marker = board.cases[position].marker
          print " #{marker}"
        end
        puts
      end
    end
  end
  
  class Application
    def self.run
      loop do
        game = Game.new
        game.start
        break unless play_again?
      end
    end
  
    def self.play_again?
      puts "Voulez-vous jouer une autre partie ? (o/n)"
      gets.chomp.downcase == 'o'
    end
  end
  
  Application.run
  