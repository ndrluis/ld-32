class Grass < GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["#{self.filename}.png"]
    self.rotation_center = :top_left
  end

  def self.solid
    all.select { |block| block.alpha == 255 }
  end

  def self.inside_viewport
    all.select { |block| block.game_state.viewport.inside?(block) }
  end
end

class GrassTiles
  include Chingu::NamedResource

  def initialize
    @builded_classes = build_classes
  end

  def all
    @builded_classes.flat_map(&:all)
  end

  private

  def build_classes
    class_names.map do |class_name|
      Class.new(Grass).tap do |klass|
        Object.const_set class_name, klass
      end
    end
  end

  def class_names
    Dir.glob(File.join(ROOT, 'media', 'grass_*.png')).map do |f|
      File.basename(f, '.png').split("_").each {|s| s.capitalize! }.join("")
    end
  end
end
