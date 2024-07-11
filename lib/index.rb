class BoardCase
  attr_accessor :value, :id

  def initialize(id)
    @id = id
    @value = " "
  end
end

class Board
  attr_accessor :cases, :count_turn

  def initialize
    @cases = {}
    ("A".."C").each do |row|
      (1..3).each do |col|
        id = "#{row}#{col}"
        @cases[id] = BoardCase.new(id)
      end
    end
    @count_turn = 0
  end

  def play_turn(player)
    loop do
      puts "#{player.name}, choisissez une case (ex: A1, B3) :"
      move = gets.chomp.upcase
      if @cases[move] && @cases[move].value == " "
        @cases[move].value = player.value
        @count_turn += 1
        break
      else
        puts "Mouvement invalide. Essayez encore."
      end
    end
  end

  def victory?
    winning_combinations.each do |combination|
      values = combination.map { |id| @cases[id].value }
      if values.all? { |value| value == "X" }
        return "X"
      elsif values.all? { |value| value == "O" }
        return "O"
      end
    end
    return "match nul" if @count_turn == 9
    false
  end

  private

  def winning_combinations
    rows = [["A1", "A2", "A3"], ["B1", "B2", "B3"], ["C1", "C2", "C3"]]
    cols = [["A1", "B1", "C1"], ["A2", "B2", "C2"], ["A3", "B3", "C3"]]
    diags = [["A1", "B2", "C3"], ["A3", "B2", "C1"]]
    rows + cols + diags
  end
end

class Player
  attr_reader :name, :value

  def initialize(name, value)
    @name = name
    @value = value
  end
end

class Game
  attr_accessor :current_player, :status, :board, :players

  def initialize
    @board = Board.new
    @players = create_players
    @status = "on going"
    @current_player = @players[0]
  end

  def create_players
    puts "Entrez le prénom du Joueur 1 :"
    player1 = Player.new(gets.chomp, "X")
    puts "Entrez le prénom du Joueur 2 :"
    player2 = Player.new(gets.chomp, "O")
    [player1, player2]
  end

  def turn
    loop do
      Show.new.show_board(@board)
      @board.play_turn(@current_player)
      if result = @board.victory?
        @status = result == "match nul" ? "nul" : @current_player
        break
      end
      switch_player
    end
    game_end
  end

  def switch_player
    @current_player = @current_player == @players[0] ? @players[1] : @players[0]
  end

  def new_round
    @board = Board.new
    @status = "on going"
    turn
  end

  def game_end
    Show.new.show_board(@board)
    if @status == "nul"
      puts "La partie est un match nul !"
    else
      puts "#{@status.name} a gagné !"
    end
    puts "Voulez-vous jouer une autre partie ? (o/n)"
    answer = gets.chomp.downcase
    if answer == 'o'
      new_round
    else
      puts "Merci d'avoir joué !"
    end
  end
end

class Show
  def show_board(board)
    puts "  1 2 3"
    ["A", "B", "C"].each do |row|
      print row
      (1..3).each do |col|
        position = "#{row}#{col}"
        marker = board.cases[position].value
        print " #{colorize(marker)}"
      end
      puts
    end
  end
  def colorize(value)
    case value
    when "X", "⚽"
      "\e[31m#{value}\e[0m"  # Red
    when "O", "❌"
      "\e[34m#{value}\e[0m"  # Blue
    else
      value  # Default color for empty spaces
    end
  end
end

class Application
  def perform
    loop do
      game = Game.new
      game.turn
      break unless play_again?
    end
  end

  def play_again?
    puts "veillez confirmer votre reponse (o/n)"
    gets.chomp.downcase == 'o'
  end
end

Application.new.perform
