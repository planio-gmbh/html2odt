module Html2Odt::DimensionsPatches
  # Default implemenation of IO#peek from GEM_PATH/dimensions-1.3.0/lib/dimensions/io.rb:
  #
  #   def peek
  #     unless no_peeking?
  #       read(pos + 1024) while @reader.width.nil? && pos < 6144
  #       rewind
  #     end
  #   end
  #
  # It had two problems:
  #
  # a) if the file is shorter than 6144 bytes, it would keep reading infinitely
  # b) if the width can only be detected after the 6144 limit, it would not work
  #    as expected
  #
  # Now we keep reading the file, until we can determine a width or until
  # there's nothing left to read.
  #
  def peek
    return if no_peeking?

    while read(pos + 1024) && @reader.width.nil?
    end

    rewind
  end
end
