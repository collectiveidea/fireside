class Content
  attr_reader :string, :hash, :content_type

  def initialize(value, content_type)
    @content_type = content_type

    @string = case value
              when String then value
              when Hash then dump(value)
              else nil
              end

    @hash = load(@string)
  end

  def ==(other)
    hash == Content.new(other, content_type).hash
  end

  def to_s
    string
  end

  def to_hash
    hash
  end

  def inspect
    hash.inspect
  end

  private

  def load(string)
    case content_type
    when "json" then JSON.load(string)
    when "xml" then Hash.from_xml(string)
    end
  end

  def dump(hash)
    case content_type
    when "json" then JSON.dump(hash)
    when "xml"
      root = hash.keys.first
      hash[root].to_xml(root: root, skip_instruct: true)
    end
  end
end
