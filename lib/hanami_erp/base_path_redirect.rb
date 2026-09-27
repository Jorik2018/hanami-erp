# lib/hanami_erp/base_path_redirect.rb
# frozen_string_literal: true

module HanamiErp
  module BasePathRedirect
    def redirect_to(location, *args, **kwargs)
      super(
        with_base_path(location),
        *args,
        **kwargs
      )
    end

    private

    def with_base_path(location)
      return location unless location.is_a?(String)

      # No modificar URLs externas, anchors ni protocolos especiales.
      return location if location.match?(%r{\A[a-z][a-z0-9+\-.]*:}i)
      return location if location.start_with?("//", "#")

      base_path = ENV.fetch("BASE_PATH", "").strip

      return location if base_path.empty? || base_path == "/"

      base_path = "/#{base_path}" unless base_path.start_with?("/")
      base_path = base_path.delete_suffix("/")

      # Evita prefijar dos veces una URL ya prefijada.
      return location if location == base_path
      return location if location.start_with?("#{base_path}/")

      path = location.start_with?("/") ? location : "/#{location}"

      "#{base_path}#{path}"
    end
  end
end
