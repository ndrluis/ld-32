class Play < GameState
  trait :viewport

  def initialize
    super
    destroy_instances

    self.input = {:p => Pause, :e => :edit}
    self.viewport.lag = 0
    self.viewport.game_area = [0, 0, 5000, 600]

    grass_tiles = GrassTiles.new

    load_game_objects

    @map    = GameObjectMap.new(:game_objects => grass_tiles.all,
                                :grid => [128, 128],
                                :debug => true)

    @player = Player.create(:x => 128, :y => -100)
  end

  def edit
    push_game_state GameStates::Edit.new(:grid => [128, 128], :except => [Player], :debug => false)
  end

  def destroy_instances
    Player.destroy_all
  end

  def draw
    super
  end

  def update
    super

    self.viewport.center_around(@player)
  end

  def first_terrain_collision(object)
    @map.from_game_object(object) if object.collidable
  end
end
