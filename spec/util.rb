class Object
  def to_query(key)
    "#{CGI.escape(key.to_s)}=#{CGI.escape(self.to_s)}"
  end
end

class Hash
  def to_query(namespace = nil)
    collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact * "&"
  end
end