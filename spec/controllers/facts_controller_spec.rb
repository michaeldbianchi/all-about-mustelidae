# Example:
describe FactsController, type: :controller do
  it "index returns a success response" do
    get '/facts'
    expect(response.status).to eq 200
    pp response.body
  end
end
