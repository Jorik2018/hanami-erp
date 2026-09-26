# frozen_string_literal: true

require "hanami/boot"

require_relative "config/app"

# Lee la variable de entorno, limpia espacios y asegura que empiece con "/" si existe
base_path = ENV["BASE_PATH"]&.strip
base_path = "/#{base_path}" if base_path && !base_path.start_with?("/")
print(base_path)
if base_path && base_path != "/"
  map base_path do
    run Hanami.app
  end
else
  run Hanami.app
end
