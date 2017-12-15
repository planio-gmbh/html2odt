class Html2Odt::Image
  attr_reader :source

  def initialize(target_base)
    @target_base = target_base
    @valid = nil
  end

  # Assign file instead of source, if you were creating tempfiles and need them
  # to stay around until the ODT is generated.
  def source=(file_or_path)
    if file_or_path.respond_to? :path
      @source = file_or_path.path
      @file = file_or_path
    else
      @source = file_or_path.to_s
    end
  end

  def valid?
    return false if source.nil? or !File.readable?(source)

    if @valid.nil?
      File.open(source, "rb") do |io|
        Dimensions(io)

        # Interacting with Dimensions::Reader directly to
        #
        #   a) avoid reading the file multiple times
        #   b) get type info

        io.send :peek
        reader = io.instance_variable_get :@reader

        if reader.type
          @type = reader.type

          # for some files, peek doesn't seem to do the trick and width/height
          # stay nil. According to
          # https://github.com/sstephenson/dimensions#reading-dimensions-from-a-stream
          # the dimensions get initialized 'once enough of the file' has been
          # read, so we do that.
          #
          while reader.width.nil?
            break unless io.read(8192)
          end

          @width = reader.width
          @height = reader.height
          @angle = reader.angle

          @valid = not(@width.nil? or @height.nil?)
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
