# spec/requests/root_spec.rb

RSpec.describe "Root", type: :request do
  it "is successful" do
    get "/"

    # Find me in `config/routes.rb`
    expect(last_response).to be_successful
    expect(last_response.body).to eq("Welcome from Hanami")
  end
end
