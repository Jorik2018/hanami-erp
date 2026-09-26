# frozen_string_literal: true

module HanamiErp
  module Actions
    module API
      module Books
        class Index < HanamiErp::Action
          include Deps["services.books.list"]
          def handle(request, response)
            from = request.params[:from].to_i
            limit = request.params[:limit].to_i

            books = list.call(
              page: from,
              per_page: limit
            )

            response.format = :json
            response.body = books.map(&:to_h).to_json
          end
        end
      end
    end
  end
end
