# frozen_string_literal: true

require "hanami"

module HanamiErp
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: "bookshelf.session",
      secret: settings.session_secret,
      expire_after: 60*60*24*365
    }
    config.middleware.use :body_parser, :json

    base_path = ENV["BASE_PATH"]&.strip
    config.base_url = base_path ? "#{base_path}" : ""
    config.assets.base_url = "#{base_path}"

  end
end
