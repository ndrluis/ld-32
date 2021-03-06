require 'stringio'
require 'zlib'
require 'nokogiri'
require 'pry'

# load a tmx file (produced by Tiled map editor mapeditor.org )
# return a TileMap and TileSets that match tmx info
class TmxTileMap
  include Chingu::NamedResource

  TmxTileMap.autoload_dirs = [ File.join("media","maps"),"maps",ROOT,File.join("..","media","maps")]

  def self.autoload(name)
    @name = name
      (path = find_file(name)) ? load(path) : fail("tilemap '#{name}' not found")
  end

  def self.load file
    file = File.new file
    doc = Nokogiri::XML file

    #extract info from tmx file
    tmx_info = parse_tmx doc
    #create a map along tmx definitions
    map = create_map tmx_info[:global]
    #fill map with tile data
    fill_map map, tmx_info[:layers], tmx_info[:tilesets]
    map.name = @name
    map
  end

  #
  # take tmx map info and decode it
  def self.uncode_map_info data
    data= data.unpack('m')
    data = StringIO.new(data.join)
    data = Zlib::GzipReader.new(data)
  end

  #
  #take info (name,dimensions etc) and return a TileMap that meets this
  def self.create_map info
    TileMap.new(:size=>[info[:width],info[:height]],:tilesize=>[info[:tile_width],info[:tile_height]])
  end

  #
  # take map and fill it with tile layout info
  def self.fill_map map, info, tileset
    tilez = Array.new

    info.each do |h|
      layer = h
      raw_map_data = uncode_map_info layer[:data]
      string_map_data = ""
      raw_map_data.to_a.each{|rd| string_map_data << rd}
      #string_map_data is now a String of size n_tiles*4

      t = string_map_data.bytes.to_a #get byte data of each char

      tiles = Array.new(t.size/4)
      0.upto(t.size/4-1){|i| p=0; tiles[i] = t[i*4..i*4+3].inject{|s,n| p+=1; s+n+(p*255*n)} }
      tilez << tiles
    end

    #merge tile layers
    tilez.each{|t| t.each_with_index{|tx,i| tilez[0][i] = tx unless tx ==0}}

     #add tile ids
    map.tids= tilez.first.uniq

    #add the tile info to our map
    map.set_tiles tilez[0],tileset
  end

  #
  #create a tileset and add it to a map
  def self.add_tileset tileset_info
    map.add_tileset
  end

  #
  #take a tmx file and extract what we want
  def self.parse_tmx xml_data
    map = xml_data.xpath('map')

    #get global map info
    global = {}
    global[:width] = map.attribute('width').to_s.to_i
    global[:height] = map.attribute('height').to_s.to_i
    global[:tile_width] = map.attribute('tilewidth').to_s.to_i
    global[:tile_height] = map.attribute('tileheight').to_s.to_i


    #get info for each tileset
    tilesets = map.xpath('tileset').flat_map do |ts|
      name = ts.attribute('name').to_s

      ts.xpath('tile').map do |t|
        first_tid = t.attribute('id').to_s.to_i
        spacing = 0
        image = t.xpath('image').attribute('source').to_s

        {:name =>name, :image =>image, :firstid => first_tid, :spacing => spacing }
      end
    end

    #get info for each layer
    layers = map.xpath('layer').map do |l|
      name = l.attribute('name').to_s
      data = l.xpath('data')
      enc = data.attribute('encoding').to_s
      comp = data.attribute('compression').to_s
      data = data.text.strip!
      enc = true if enc == "base64"
      comp = true if enc == "gzip"

      {:name=>name,:data=>data,:enc=>enc,:comp=>comp}
    end
    {:tilesets=>tilesets,:layers=>layers,:global =>global}
  end
end
