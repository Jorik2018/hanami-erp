# frozen_string_literal: true

module HanamiErp
  module Actions
    module API
      module Books
        class Index < HanamiErp::Action
          # def handle(request, response)
          #   books = [
          #     {title: "Test Driven Development"},
          #     {title: "Practical Object-Oriented Design in Ruby"}
          #   ]
          #   response.format = :json
          #   response.body = books.to_json
          # end
          include Deps["persistence.rom"]
          params do
            optional(:page).value(:integer, gt?: 0)
            optional(:per_page).value(:integer, gt?: 0, lteq?: 100)
          end

          def handle(request, response)
            halt 422, {errors: request.params.errors}.to_json unless request.params.valid?
            books = rom.relations[:books]
              .select(:title, :author)
              .order(:title)
              .page(request.params[:page] || 1)
              .per_page(request.params[:per_page] || 5)
              .to_a

            response.format = :json
            response.body = books.to_json
          end
        end
      end
    end
  end
end
