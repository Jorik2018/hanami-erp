# lib/hanami_erp/base_path.rb
# frozen_string_literal: true

module HanamiErp
  module BasePath
    def with_base_path(path)
      base_path = ENV.fetch("BASE_PATH", "").strip

      return path if base_path.empty? || base_path == "/"

      base_path = "/#{base_path}" unless base_path.start_with?("/")
      base_path = base_path.delete_suffix("/")

      "#{base_path}#{path}"
    end
  end
end
