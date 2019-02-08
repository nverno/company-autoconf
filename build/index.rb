require 'httparty'
require 'nokogiri'
require 'openssl'
require 'json'

module Autoconf
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  VERSION = /[0-9.]+/.match(`bash autoconf --version`)[0]
  URI_autoconf = "http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-#{VERSION}/html_node/Autoconf-Macro-Index.html#Autoconf-Macro-Index"
  URI_automake = "https://www.gnu.org/software/automake/manual/html_node/Macro-Index.html#Macro-Index"

  # retrieve links to index pages
  def self.parse_index
    page = Nokogiri::HTML(HTTParty.get(URI_autoconf))
    @@index = page.at_xpath("//*[contains(concat(' ', @class, ' '), ' menu ')]")
                .css('a').collect { |x| URI_autoconf + x['href'] }
    nil
  end

  # parse automake macros index page, overlaps with autoconf macros
  def self.parse_automake uris
    uris.each do |uri|
      Nokogiri::HTML(HTTParty.get(uri))
        .at_xpath("//table[contains(@class, 'index-fn')]")
        .xpath("tr").each do |x|
        link = x.css("a")
        if !link.empty? && !link[1].nil?
          @@h[link[0].content] = [link[0]["href"], link[1].content, @@index]
        end
      end
    end
    @@index += 1
  end

  # autoconf indices
  def self.parse_autoconf uris
    uris.each do | uri |
      Nokogiri::HTML(HTTParty.get(uri))
        .at_xpath("//*[contains(concat(' ', @class), ' index-')]")
        .xpath("li").each do |x|
        link = x.xpath("a").first
        @@h[link.content] = [link["href"], x.xpath("a")[1].content, @@index]
      end
    end
    @@index += 1
  end

  # parse pages and write to json
  # root_num is int corresponding to base url
  # format: {macro_name} = [url, annotation, root_num]
  def self.parse file, autoconf, automake
    uris = [autoconf, automake].flatten
    @@h = {}
    i = -1
    @@h["roots"] = uris
    @@index = 0
    parse_autoconf autoconf
    parse_automake automake
    File.open(file, "w") { |f| f.write(@@h.to_json) }
  end

  def self.parse_default file
    parse file, [URI_autoconf], [URI_automake]
  end

end

puts Autoconf.parse_default ARGV[0]
