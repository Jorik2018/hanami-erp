# frozen_string_literal: true

module HanamiErp
  module Actions
    module API
      module Books
        class Create < HanamiErp::Action
          include Deps["persistence.rom"]

          params do
            required(:book).hash do
              required(:title).filled(:string)
              required(:author).filled(:string)
            end
          end

          def handle(request, response)
            if request.params.valid?
              book = rom.relations[:books].changeset(:create, request.params[:book]).commit

              response.status = 201
              response.body = book.to_json
            else
              response.status = 422
              response.format = :json
              response.body = request.params.errors.to_json
            end
          end
        end
      end
    end
  end
end
