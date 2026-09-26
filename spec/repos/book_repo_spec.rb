# frozen_string_literal: true

require "spec_helper"

RSpec.describe HanamiErp::Repos::BookRepo do
  subject(:repo) { HanamiErp::App["repos.book_repo"] }

  let(:created_books) { [] }

  let(:create_book) do
    lambda do |attributes|
      book = repo.create(attributes)
      created_books << book
      book
    end
  end

  after do
    # Limpia los datos creados durante cada ejemplo.
    # Si ya fue eliminado, el delete no debería afectar registros.
    created_books.each do |book|
      repo.delete(book.id)
    rescue ROM::TupleCountMismatchError
      nil
    end
  end

  describe "#create" do
    it "crea un libro" do
      book = create_book.call(
        title: "Clean Code",
        author: "Robert C. Martin"
      )

      expect(book.id).not_to be_nil
      expect(book.title).to eq("Clean Code")
      expect(book.author).to eq("Robert C. Martin")
    end
  end

  describe "#get" do
    it "retorna el libro cuando existe" do
      created = create_book.call(
        title: "Domain-Driven Design",
        author: "Eric Evans"
      )

      book = repo.get(created.id)

      expect(book.id).to eq(created.id)
      expect(book.title).to eq("Domain-Driven Design")
      expect(book.author).to eq("Eric Evans")
    end

    it "lanza una excepcion cuando el libro no existe" do
      expect do
        repo.get(-99_999)
      end.to raise_error(ROM::TupleCountMismatchError)
    end
  end

  describe "#all_by_title" do
    before do
      create_book.call(title: "Zebra Book", author: "Author Z")
      create_book.call(title: "Clean Architecture", author: "Robert C. Martin")
      create_book.call(title: "Domain-Driven Design", author: "Eric Evans")
    end

    it "retorna los libros ordenados por titulo" do
      books = repo.all_by_title(page: 1, per_page: 10)

      expect(books.map(&:title)).to eq(
        [
          "Clean Architecture",
          "Domain-Driven Design",
          "Zebra Book"
        ]
      )
    end

    it "retorna solo title y author" do
      books = repo.all_by_title(page: 1, per_page: 10)

      expect(books.first.to_h).to include(
        title: "Clean Architecture",
        author: "Robert C. Martin"
      )
    end

    it "pagina los resultados" do
      books = repo.all_by_title(page: 1, per_page: 2)

      expect(books.map(&:title)).to eq(
        [
          "Clean Architecture",
          "Domain-Driven Design"
        ]
      )
    end
  end

  describe "#update" do
    it "actualiza un libro existente" do
      created = create_book.call(
        title: "Old title",
        author: "Old author"
      )

      updated = repo.update(
        created.id,
        title: "New title",
        author: "New author"
      )

      expect(updated.id).to eq(created.id)
      expect(updated.title).to eq("New title")
      expect(updated.author).to eq("New author")

      persisted_book = repo.get(created.id)

      expect(persisted_book.title).to eq("New title")
      expect(persisted_book.author).to eq("New author")
    end
  end

  describe "#delete" do
    it "elimina un libro existente" do
      created = create_book.call(
        title: "Book to delete",
        author: "Author"
      )

      repo.delete(created.id)

      expect do
        repo.get(created.id)
      end.to raise_error(ROM::TupleCountMismatchError)
    end
  end
end
