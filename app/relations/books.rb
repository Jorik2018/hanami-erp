# frozen_string_literal: true

module HanamiErp
  module Relations
    class Books < HanamiErp::DB::Relation
      schema :books, infer: true
      use :pagination
      per_page 2
    end
  end
end
