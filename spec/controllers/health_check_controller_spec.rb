# Example:
describe HealthCheckController, type: :controller do
  it "index returns a success response" do
    get '/opl/health'
    expect(response.status).to eq 200
    pp response.body
  end
end
