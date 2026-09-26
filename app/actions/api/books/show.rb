# frozen_string_literal: true

module HanamiErp
  module Actions
    module API
      module Books
        class Show < HanamiErp::Action
include Deps["repos.book_repo"]

        params do
          required(:id).value(:integer)
        end

        def handle(request, response)
          book = book_repo.get(request.params[:id])

          response.format = :json

          if book
            response.body = book.to_h.to_json
          else
            response.status = 404
            response.body = {error: "not_found"}.to_json
          end
        end
        end
      end
    end
  end
end
