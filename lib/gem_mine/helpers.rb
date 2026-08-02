# frozen_string_literal: true

module GemMine
  # Small, dependency-free helpers for fixture naming.
  module Helpers
    SPLIT_UNDERSCORE_OR_SPACE = /[_\s]+/

    module_function

    # Converts a conventional gem name to its matching Ruby constant name.
    def camelize(value)
      value.to_s.split(SPLIT_UNDERSCORE_OR_SPACE).map do |part|
        part.empty? ? part : "#{part[0].upcase}#{part[1..]}"
      end.join
    end
  end
end
