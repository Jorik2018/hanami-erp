# frozen_string_literal: true

require "spec_helper"

RSpec.describe HanamiErp::Actions::API::Books::Show do
  subject(:action) { described_class.new(book_repo: book_repo) }

  Response = Struct.new(:format, :body, :status)

  let(:book_repo) { instance_double("Repos::BookRepo") }
  let(:response) { Response.new(nil, nil, 200) }

  describe "#handle" do
    context "cuando el libro existe" do
      let(:request) do
        instance_double(
          Hanami::Action::Request,
          params: { id: 15 }
        )
      end

      let(:book) do
        instance_double(
          "Book",
          to_h: {
            id: 15,
            title: "Clean Code",
            author: "Robert C. Martin"
          }
        )
      end

      before do
        allow(book_repo)
          .to receive(:get)
          .with(15)
          .and_return(book)
      end

      it "busca el libro por id" do
        action.handle(request, response)

        expect(book_repo).to have_received(:get).with(15)
      end

      it "retorna el libro en formato JSON" do
        action.handle(request, response)

        expect(response.format).to eq(:json)
        expect(response.status).to eq(200)

        expect(JSON.parse(response.body)).to eq(
          {
            "id" => 15,
            "title" => "Clean Code",
            "author" => "Robert C. Martin"
          }
        )
      end
    end

    context "cuando el libro no existe" do
      let(:request) do
        instance_double(
          Hanami::Action::Request,
          params: { id: 999 }
        )
      end

      before do
        allow(book_repo)
          .to receive(:get)
          .with(999)
          .and_return(nil)
      end

      it "retorna 404" do
        action.handle(request, response)

        expect(response.format).to eq(:json)
        expect(response.status).to eq(404)

        expect(JSON.parse(response.body)).to eq(
          "error" => "not_found"
        )
      end
    end
  end
end
