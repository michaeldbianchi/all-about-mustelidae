class FactsController < ApplicationController
  def index
    render json: {ping: "pong"}
  end

  def show
    @topic = params[:topic]
    return render json: { status: :bad_request, topic: nil}, status: :bad_request if topic.nil?

    resp = wiki_client.get("/wiki/#{@topic}")
    html = Nokogiri::HTML.parse(resp.body)
    header = html.css('h1').first.text
    details = html.css("div > p").map(&:text).map { |text| scrub(text) }.flatten.reject { |text| empty?(text) }

    render json: { status: :success, topic: @topic.capitalize, fact: details.sample}
  rescue StandardError => e
    render json: { status: :error, topic: @topic.capitalize, error: "#{e.class} - #{e.message}"}, status: :internal_server_error
  end

  private

  def wiki_client
    connection = Faraday.new 'https://en.wikipedia.org' do |conn|
      conn.use FaradayMiddleware::FollowRedirects, limit: 5
      conn.adapter Faraday.default_adapter
    end
  end

  def scrub(string)
    pre_scrubbed = string
      .gsub(/\[(.*?)\]/, "")
    segments = PragmaticSegmenter::Segmenter.new(text: pre_scrubbed).segment
    segments.map do |text|
      text
        .gsub(/(\W?)(it)(\s)/i) { |_| $~[2] == "it" ? "#{$~[1]}the #{@topic.downcase}#{$~[3]}" : "#{$~[1]}The #{@topic.downcase}#{$~[3]}" }
        .gsub(/(\W?)(they)(\s)/i) { |_| $~[2] == "they" ? "#{$~[1]}#{@topic.downcase}s#{$~[3]}" : "#{$~[1]}#{@topic.capitalize}s#{$~[3]}" }
        .strip
      end
  end
  
  def empty?(string)
    !string.match?(/\w/)
  end

  def contains_topic?(string)
    string.match?(/#{@topic}/i)
  end
end


# ```
# h = $('h1').text();
# a = $('div > p').map((i, p) => {
#     if (p.textContent) {
#         return p.textContent.split('.')
#     }
# }).get().filter(s => s === s.replace(/\s+/g, ' ')).map(s => {
#     return s.replace(/\[(.*?)\]/g, '')
#         .replace('It', 'The ' + h.toLowerCase)
#         .replace('They', h + 's').trim();
# });
# ```
