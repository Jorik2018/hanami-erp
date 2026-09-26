# frozen_string_literal: true

module HanamiErp
  module Repos
    class BookRepo < HanamiErp::DB::Repo
      def all_by_title(page:, per_page:)
        books
          .select(:title, :author)
          .order(books[:title].asc)
          .page(page)
          .per_page(per_page)
          .to_a
      end
      def get(id)
        books.by_pk(id).one!
      end
      def create(attributes)
        books.changeset(:create, attributes).commit
      end
      def update(id, attributes)
        books.by_pk(id).changeset(:update, attributes).commit
      end
      def delete(id)
        books.by_pk(id).changeset(:delete).commit
      end

    end
  end
end
