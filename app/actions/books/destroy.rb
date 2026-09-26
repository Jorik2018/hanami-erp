# frozen_string_literal: true

module HanamiErp
  module Actions
    module Books
      class Destroy < HanamiErp::Action
        include Deps["repos.book_repo"]

        params do
          required(:id).filled(:integer)
        end

        def handle(request, response)
          result = book_repo.delete(request.params[:id])

          response.flash[:notice] = "Book deleted"
          response.redirect_to routes.path(:books)
        end
      end
    end
  end
end
