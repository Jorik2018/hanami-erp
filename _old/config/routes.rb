# frozen_string_literal: true

module HanamiErp
  class Routes < Hanami::Routes
    root to: "home.show"
    #root { "Hello from Hanami" }
    get "/home/:id", to: "home.show"
    get "/books", to: "books.index"
    get "/books/:id", to: "books.show", as: :show_book
    get "/books/new", to: "books.new"
    post "/books", to: "books.create", as: :create_book
    get "/api/books", to: "api.books.index"
    get "/api/books/:id", to: "api.books.show"
    get "/api/books/:id", to: "api.books.show"
    post "/api/books", to: "api.books.create"
  end
end
