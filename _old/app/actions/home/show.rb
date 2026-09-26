# frozen_string_literal: true

module HanamiErp
  module Actions
    module Home
      class Show < HanamiErp::Action
        # def handle(request, response)
        # end
        def handle(*, response)
          response.body = "Welcome to Bookshelf"
        end
      end
    end
  end
end
