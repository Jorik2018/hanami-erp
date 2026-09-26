# frozen_string_literal: true

module HanamiErp
  module Actions
    module Books
      class Update < HanamiErp::Action
        include Deps["repos.book_repo"]

        params do
          required(:id).filled(:integer)
          required(:book).hash do
            required(:title).filled(:string)
            required(:author).filled(:string)
          end
        end

        def handle(request, response)
          if request.params.valid?
            book = book_repo.update(request.params[:id], request.params[:book])

            response.flash[:notice] = "Book updated"
            response.redirect_to routes.path(:book, id: book[:id])
          else
            response.flash.now[:alert] = "Could not update book"
            # Implicitly re-renders the "new" view
          end
        end
      end
    end
  end
end
