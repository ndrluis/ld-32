class Player < GameObject
  trait :bounding_box, scale: 0.5
  traits :collision_detection, :velocity, :timer, collision: :arcade
  attr_accessor :jumping, :shooting, :state, :direction

  def setup
    @animations = {}
    @state = :stand
    @direction = :right
    @jumping = false
    @receiving_damage = false
    @ready = true

    self.max_velocity = 10
    self.acceleration_y = 0.5
    self.rotation_center = :bottom_center

    @last_x, @last_y = @x, @y
  end

  def initialize(options = {})
    super
    self.input = [:holding_left, :holding_right]

    @animations[:stand] = Animation.new(:file => "standfull.png", :size => [128, 156])
    @animations[:stand].frame_names = { :left => 0..0, :right => 1..1}

    @animations[:run] = Animation.new(:file => "running.png", :size => [122, 156], :delay => 140)
    @animations[:run].frame_names = { :left => 0..1, :right => 2..3}
  end

  def holding_left
    @x -= 4
    @state = :run
    @direction = :left
  end

  def holding_right
    @x += 4
    @state = :run
    @direction = :right
  end

  def update
    @state = :stand if @x == @last_x
    @x = @last_x if @x < 0 and outside_window?

    @image = @animations[@state][@direction].next

    if block = game_state.first_terrain_collision(self)
      if self.velocity_y < 0
        self.y = block.bb.bottom + self.height
      else
        self.y = block.bb.top - 1
      end

      self.velocity_y = 0
      self.velocity_x = 0
      @state = :stand
    end

    @last_x, @last_y = @x, @y
  end
end
