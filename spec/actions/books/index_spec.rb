# spec/actions/books/index_spec.rb

RSpec.describe HanamiErp::Actions::Books::Index do
  subject(:action) do
    HanamiErp::Actions::Books::Index.new
  end

  it "returns a successful response with empty params" do
    response = action.call({})
    expect(response).to be_successful
  end
end
