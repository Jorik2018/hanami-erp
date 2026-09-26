# app/services/books/list.rb
# frozen_string_literal: true

module HanamiErp
  module Services
    module Books
      class List
        include Deps["repos.book_repo"]

        def call(page:, per_page:)
          book_repo.all_by_title(
            page: page,
            per_page: per_page
          )
        end
      end
    end
  end
end