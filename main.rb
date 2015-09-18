require 'chingu'
require 'gosu'

include Gosu
include Chingu

require_rel 'game_states/*'
require_rel 'game_objects/*'
require_rel 'utils/*'

class Game < Window
  def initialize
    super(800, 600)

    self.caption = "A GAME WITHOUT NAME :("
    self.input = {:escape => :exit}

    push_game_state(Play)
  end
end

Game.new.show
