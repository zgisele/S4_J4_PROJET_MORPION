class BoardCase
  #TO DO : la classe a 2 attr_accessor, sa valeur en string (X, O, ou vide), ainsi que son identifiant de case
  attr_accessor :value, :id

  def initialize(id)
    #TO DO : doit régler sa valeur, ainsi que son numéro de case
    @id = id
    @value = " "
  end
end

class Board
  #TO DO : la classe a 1 attr_accessor : un array/hash qui contient les BoardCases.
  #Optionnellement on peut aussi lui rajouter un autre sous le nom @count_turn pour compter le nombre de coups joué
  attr_accessor :cases, :count_turn

  def initialize
    #TO DO :
    #Quand la classe s'initialize, elle doit créer 9 instances BoardCases
    #Ces instances sont rangées dans un array/hash qui est l'attr_accessor de la classe

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
    #TO DO : une méthode qui :
    #1) demande au bon joueur ce qu'il souhaite faire
    #2) change la BoardCase jouée en fonction de la valeur du joueur (X ou O)
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
    #TO DO : une méthode qui vérifie le plateau et indique s'il y a un vainqueur ou match nul
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
  #TO DO : la classe a 2 attr_reader, son nom et sa valeur (X ou O).
  attr_reader :name, :value

  def initialize(name, value)
    #TO DO : doit régler son nom et sa valeur
    @name = name
    @value = value
  end
end

class Game
  #TO DO : la classe a plusieurs attr_accessor: le current_player (égal à un objet Player), le status (en cours, nul ou un objet Player s'il gagne), le Board et un array contenant les 2 joueurs.
  attr_accessor :current_player, :status, :board, :players

  def initialize
     #TO DO : créé 2 joueurs, créé un board, met le status à "on going", défini un current_player
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
    #decoration
    puts"#{player1.name}   \e[31m#{player1.value}\e[0m   ***VS***  #{player2.name}\e[32m #{player2.value}\e[0m"

    [player1, player2]
    
  end

  def turn
    #TO DO : méthode faisant appelle aux méthodes des autres classes (notamment à l'instance de Board). Elle affiche le plateau, demande au joueur ce qu'il joue, vérifie si un joueur a gagné, passe au joueur suivant si la partie n'est pas finie.
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
    # TO DO : relance une partie en initialisant un nouveau board mais en gardant les mêmes joueurs.
    @board = Board.new
    @status = "on going"
    turn
  end

  def game_end
     # TO DO : permet l'affichage de fin de partie quand un vainqueur est détecté ou si il y a match nul
    Show.new.show_board(@board)
    if @status == "nul"
      puts"\e[31m" 
      puts" La partie est un match nul ! "
      puts"\e[0m" 
    else
      puts"\e[32m" 
      puts "#{@status.name} a gagné !"
      puts"\e[0m" 
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
    #TO DO : affiche sur le terminal l'objet de classe Board en entrée. S'active avec un Show.new.show_board(instance_de_Board)
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
    when "X"
      
      "\e[31m#{value}\e[0m"  # Red
    when "O"
      
      "\e[32m#{value}\e[0m"  # green
    else
      value  # Default color for empty spaces
    end
  end
  def welcome_message
    puts "\e[32m"  # Green color start
    puts "**************************************"
    puts "*                                    *"
    puts "*      Bienvenue au jeu de Morpion   *"
    puts "*                                    *"
    puts "**************************************"
    puts "\e[0m"  # Reset color
  end
end

class Application
  def perform
    # TO DO : méthode qui initialise le jeu puis contient des boucles while pour faire tourner le jeu tant que la partie n'est pas terminée.
    Show.new.welcome_message
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

#Application.new.perform
