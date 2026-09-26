# frozen_string_literal: true

require "spec_helper"

RSpec.describe HanamiErp::Actions::API::Books::Index do
  subject(:action) { described_class.new(list: list_service) }

  let(:list_service) { instance_double("Services::Books::List") }

  describe "#handle" do
    let(:request) do
      instance_double(
        Hanami::Action::Request,
        params: {
          from: "2",
          limit: "10"
        }
      )
    end

    let(:response) { Struct.new(:format, :body).new }

    let(:books) do
      [
        { id: 1, title: "Clean Code", author: "Robert C. Martin" },
        { id: 2, title: "DDD", author: "Eric Evans" }
      ]
    end

    before do
      allow(list_service)
        .to receive(:call)
        .with(page: 2, per_page: 10)
        .and_return(books)
    end

    it "consulta los libros usando paginacion" do
      action.handle(request, response)

      expect(list_service)
        .to have_received(:call)
        .with(page: 2, per_page: 10)
    end

    it "retorna una respuesta JSON" do
      action.handle(request, response)

      expect(response.format).to eq(:json)
      expect(response.body).to eq(
        [
          {
            id: 1,
            title: "Clean Code",
            author: "Robert C. Martin"
          },
          {
            id: 2,
            title: "DDD",
            author: "Eric Evans"
          }
        ].to_json
      )
    end
  end
end
