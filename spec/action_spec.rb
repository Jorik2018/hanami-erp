# frozen_string_literal: true

require "spec_helper"

RSpec.describe HanamiErp::Action do
  subject(:action) { described_class.new }

  let(:exception) { StandardError.new }

  let(:response) do
    Class.new do
      attr_accessor :status, :body
      attr_reader :headers

      def initialize
        @headers = {}
      end
    end.new
  end

  describe "#handle_not_found" do
    context "cuando el cliente solicita JSON" do
      let(:request) do
        instance_double(
          Hanami::Action::Request,
          get_header: "application/json"
        )
      end

      it "retorna un error JSON con estado 404" do
        action.send(:handle_not_found, request, response, exception)

        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"])
          .to eq("application/json; charset=utf-8")

        expect(JSON.parse(response.body)).to eq(
          "error" => "not_found",
          "message" => "Resource not found"
        )
      end
    end

    context "cuando el cliente solicita HTML" do
      let(:request) do
        instance_double(
          Hanami::Action::Request,
          get_header: "text/html"
        )
      end

      it "retorna una pagina HTML con estado 404" do
        action.send(:handle_not_found, request, response, exception)

        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"])
          .to eq("text/html; charset=utf-8")

        expect(response.body).to eq("<h1>404 - Not found</h1>")
      end
    end

    context "cuando no se envia el header Accept" do
      let(:request) do
        instance_double(
          Hanami::Action::Request,
          get_header: nil
        )
      end

      it "retorna HTML por defecto" do
        action.send(:handle_not_found, request, response, exception)

        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"])
          .to eq("text/html; charset=utf-8")

        expect(response.body).to eq("<h1>404 - Not found</h1>")
      end
    end
  end
end
