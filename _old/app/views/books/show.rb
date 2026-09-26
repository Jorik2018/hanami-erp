# frozen_string_literal: true

module HanamiErp
  module Views
    module Books
      class Show < HanamiErp::View
        include Deps["persistence.rom"]
        expose :book do |id:|
          rom.relations[:books].by_pk(id).one!
        end
      end
    end
  end
end
