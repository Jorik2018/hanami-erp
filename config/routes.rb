# frozen_string_literal: true

module HanamiErp
  class Routes < Hanami::Routes
    # Add your routes here. See https://hanakai.org/learn/hanami/routing/ for details.
    root to: "home.index"
    resources :books
    resources :api_books, path: "api/books", to: "api.books", only: [:show,:create]
    get "/api/books/:from/:limit", to: "api.books.index"
  end
end
