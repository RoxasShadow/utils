#! /usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'base64'

Nokogiri::HTML(open('http://pokemondb.net/pokedex/all')).xpath('//td[@class = "name"]/a/@href').each {|url|
	page = Nokogiri::HTML(open(url))

	puts [Hash.new { |hash, key| hash[key] = [] }.tap {|p|
		p['id']   = page.xpath('//tr/td/strong').first.text
    p['name'] = page.xpath('//div[@class = "navbar"]/h1').first.text

		page.xpath('//table[@class = "vitals"][@style = "width:100%"]/tr[2]/td/a').each {|t|
			p['types'] << t.content
		}

		page.xpath('//span[@class = "item"]/a/img/@alt').each {|e|
			p['evolutions'] << e.text
		}

		page.xpath('//table[@class = "data pokedex-moves-level"]/tbody/tr').each {|m|
			p['moves'] << {
				'name'  => m.at_xpath('descendant::td[@class = "name"]/a').text,
				'level' => m.at_xpath('descendant::td[@class = "numeric"]').text.to_i
			}
		}

		page.xpath('//table[@class = "data pokedex-moves-hm"]/tbody/tr/td[@class = "name"]/a').each {|m|
			p['hm_moves'] << m.text unless p['hm_moves'].include? m.text
		}

		page.xpath('//table[@class = "data pokedex-moves-tm"]/tbody/tr/td[@class = "name"]/a').each {|m|
			p['tm_moves'] << m.text unless p['tm_moves'].include? m.text
		}

		page.xpath('//table[@class = "data pokedex-moves-egg"]/tbody/tr/td[@class = "name"]/a').each {|m|
			p['egg_moves'] << m.text unless p['egg_moves'].include? m.text
		}

		page.xpath('//div[@class = "sprite-list"]/span/img/@src').each {|s|
			p['sprites'] << Base64.encode64(open(s.text).string).gsub("\n", '')
		}
	}].to_yaml[3 .. -1]
}
