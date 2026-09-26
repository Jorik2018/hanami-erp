# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module HanamiErp
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    handle_exception "ROM::TupleCountMismatchError" => :handle_not_found

    private

    def handle_not_found(request, response, exception)
      accept = request.get_header("HTTP_ACCEPT").to_s

      response.status = 404

      if accept.include?("application/json")
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        response.body = JSON.generate(
          error: "not_found",
          message: "Resource not found"
        )
       else
        response.headers["Content-Type"] = "text/html; charset=utf-8"
        response.body = "<h1>404 - Not found</h1>"
      end
    end
  end
end
