class Pause < GameState
  def initialize
    super

    self.input = {:p => :un_pause}
    @title = Text.create(:text => "PAUSED", :x => 1, :y => 1, :size => 25, :zorder => 9999999)
  end

  def un_pause
    pop_game_state
  end

  def draw
    super
    previous_game_state.draw
  end
end
