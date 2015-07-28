module Lasp
  module_function

  def parse(program)
    build_ast(tokenize(sanitize(program)))
  end

  def build_ast(tokens)
    return if tokens.empty?
    token = tokens.shift

    if token == "("
      form = []
      while tokens.first != ")"
        form << build_ast(tokens)
      end
      tokens.shift
      form
    else
      atom(token)
    end
  end

  def tokenize(string)
    string
      .gsub("(", " ( ")
      .gsub(")", " ) ")
      .scan(/(?:[^\s"]|"[^"]*")+/)
  end

  def atom(token)
    case token
    when "true"        then true
    when "false"       then false
    when "nil"         then nil
    when /\A\d+\z/     then Integer(token)
    when /\A\d+.\d+\z/ then Float(token)
    when /"(.*)"/      then String($1.gsub('\\', "")) # Use the match to remove the quotes, then take out the \ to allow escaping
    else token.to_sym
    end
  end

  def sanitize(string)
    string.gsub(/;.*$/, "")
  end
end
