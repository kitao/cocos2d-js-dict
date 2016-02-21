require 'open-uri'
require 'nokogiri'

BASE_URL = 'http://www.cocos2d-x.org/docs/api-ref/js/v3x/'.freeze
FILENAME = 'cocos2d-js.dict'.freeze

URL_XPATH      = '//li/a/@href'.freeze
CLASS_XPATH    = '//caption[text()="Class Summary"]'.freeze
PROPERTY_XPATH = '//caption[text()="Field Summary"]'.freeze
METHOD_XPATH   = '//h2[text()="Method Summary"]'.freeze
COMMON_XPATH   = '..//td[@class="nameDescription"]'.freeze
NAME_XPATH     = './/div[@class="fixedFont"]/b/a/text()'.freeze

def parse_url
  puts "parse #{BASE_URL}"
  doc = Nokogiri::HTML(open(File.join(BASE_URL, 'index.html')))
  doc.xpath(URL_XPATH).map { |url| File.join(BASE_URL, url) }
end

def parse_page(url)
  puts "parse #{url}"
  doc = Nokogiri::HTML(open(url))
  [CLASS_XPATH, PROPERTY_XPATH, METHOD_XPATH].map do |xpath|
    parse_name(doc, File.join(xpath, COMMON_XPATH))
  end.flatten
end

def parse_name(doc, xpath)
  doc.xpath(xpath).map do |node|
    node.xpath(NAME_XPATH).to_s.strip.split('.').last
  end
end

def save_keywords(keywords)
  puts "write #{FILENAME}"
  path = File.join(File.dirname(__FILE__), FILENAME)
  open(path, 'w') { |f| f.puts keywords }
end

def make_keywords
  urls = parse_url
  keywords = urls.map { |url| parse_page(url) }.flatten.reject do |keyword|
    !keyword || keyword.include?(' ')
  end.uniq.sort
  save_keywords(keywords)
end

make_keywords
