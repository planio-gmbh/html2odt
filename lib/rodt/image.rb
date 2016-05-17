class Rodt::Image
  attr_reader :source

  def initialize(source, target_base)
    @source = source
    @target_base = target_base
  end

  def valid?
    if @valid.nil?
      File.open(source, "rb") do |io|
        dim = Dimensions(io)

        dim.send :peek

        reader = dim.instance_variable_get :@reader

        if reader.type
          @type = reader.type
          @width = reader.width
          @height = reader.height
          @angle = reader.angle

          @valid = true
        else
          @valid = false
        end
      end
    end

    @valid
  end

  def type
    valid? ? @type : nil
  end

  def extension
    return unless valid?

    if type == :jpeg
      "jpg"
    else
      type
    end
  end

  def mime_type
    return unless valid?

    "image/#{type}"
  end

  def width
    return unless valid?

    @width
  end

  def height
    return unless valid?

    @height
  end

  def angle
    return unless valid?

    @angle
  end

  def target
    return unless valid?

    "Pictures/#{@target_base}.#{extension}"
  end
end
