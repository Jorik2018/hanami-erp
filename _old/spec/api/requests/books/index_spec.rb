RSpec.describe "GET /api/books", type: :request do
    let(:books) { app["persistence.rom"].relations[:books] }

    before do
      books.insert(title: "Practical Object-Oriented Design in Ruby", author: "Sandi Metz")
      books.insert(title: "Test Driven Development", author: "Kent Beck")
    end

    it "returns a list of books" do
      get "/api/books"
  
      expect(last_response).to be_successful
      expect(last_response.content_type).to eq("application/json; charset=utf-8")
  
      response_body = JSON.parse(last_response.body)
  
      expect(response_body).to eq([
        {"author"=>"Sandi Metz", "title"=>"Practical Object-Oriented Design in Ruby"},
        {"author"=>"Kent Beck", "title"=>"Test Driven Development"}
      ])
    end
end