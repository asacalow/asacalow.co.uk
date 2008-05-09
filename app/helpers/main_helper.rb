module Merb
  module MainHelper
    def textilise(string)
      string = CGI.unescapeHTML string
      r = RedCloth.new(string)
      return r.to_html
    end
  end
end