require 'HTTParty'
require 'Nokogiri'
require 'json'

module Autoconf
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  VERSION = /[0-9.]+/.match(`bash autoconf --version`)[0]
  DOM = "http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-#{VERSION}/html_node/Indices.html#Indices"

  def self.parse_index
    page = Nokogiri::HTML(HTTParty.get(DOM))
    @@index = page.at_xpath("//*[contains(concat(' ', @class, ' '), ' menu ')]")
                .css('a').collect { |x| DOM + x['href'] }
    nil
  end

  def self.parse_page uri
    Nokogiri::HTML(HTTParty.get(uri))
      .at_xpath("//*[contains(concat(' ', @class), ' index-')]")
      .xpath("li").each_with_object({}) do |x, h|
      link = x.xpath("a").first
      h[link.content] = [link["href"], x.xpath("a")[1].content]
    end
  end

  def self.page file, uri
    h = parse_page(uri)
    h["root"] = uri
    File.open(file, "w") { |f| f.write(h.to_json) }
  end
end

puts Autoconf.page ARGV[0], ARGV[1]

# page = Nokogiri::HTML(HTTParty.get("http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.69/html_node/Autoconf-Macro-Index.html#Autoconf-Macro-Index")); 0

# inds = page.at_xpath("//*[contains(concat(' ', @class), ' index-')]");0

# page.at_xpath("//*[contains(concat(' ', @class), ' index-')]")
#   .xpath("li").each_with_object({}) do |x, h|
#   link = x.xpath("a").first
#   h[link.content] = [link["href"], x.xpath("a")[1].content]
# end
