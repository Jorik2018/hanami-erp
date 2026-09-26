# frozen_string_literal: true

module HanamiErp
  module Actions
    module Books
      class Show < HanamiErp::Action
        params do
          required(:id).value(:integer)
        end
        def handle(request, response)
          response.render(view, id: request.params[:id])
        end
      end
    end
  end
end
