module Merb
  module MainHelper
    def linkify(string)
      regex = Regexp.new '(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
      string.gsub( regex, '<a href="\1">\1</a>' )
    end
  end
end