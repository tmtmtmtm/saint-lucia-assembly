#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('.//table[@class="mce-item-table"]//tr[.//img]').each do |tr|
    data = { 
      name: tr.css('strong').text.sub('Hon. ','').tidy,
      image: tr.css('img/@src').text,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite([:name, :image], data)
  end
end

scrape_list('http://www.govt.lc/house-of-assembly')
