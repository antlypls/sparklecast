require 'spec_helper'
require 'ostruct'

# valid XML
# <?xml version="1.0" encoding="utf-8"?>
# <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
#   <channel>
#     <title>Sparkle Test App Changelog</title>
#     <link>http://sparkle-project.org/files/sparkletestcast.xml</link>
#     <description>Most recent changes with links to updates.</description>
#     <language>en</language>
#   </channel>
# </rss>

# valid XML with one item
# <?xml version="1.0" encoding="utf-8"?>
# <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
#   <channel>
#     <title>Sparkle Test App Changelog</title>
#     <link>http://sparkle-project.org/files/sparkletestcast.xml</link>
#     <description>Most recent changes with links to updates.</description>
#     <language>en</language>
#     <item>
#       <title>Version 2.0</title>
#       <description><![CDATA[HTML]]></description>
#       <pubDate>Sat, 26 Jul 2014 15:20:11 +0000</pubDate>
#       <enclosure url="http://sparkle-project.org/files/Sparkle%20Test%20App.zip" length="107758" type="application/octet-stream" sparkle:version="2.0" sparkle:dsaSignature="MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=="/>
#     </item>
#   </channel>
# </rss>

# valid XML with rwo items item
# <?xml version="1.0" encoding="utf-8"?>
# <rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
#   <channel>
#     <title>Sparkle Test App Changelog</title>
#     <link>http://sparkle-project.org/files/sparkletestcast.xml</link>
#     <description>Most recent changes with links to updates.</description>
#     <language>en</language>
#     <item>
#       <title>Version 2.0</title>
#       <description><![CDATA[HTML]]></description>
#       <pubDate>Sat, 26 Jul 2014 15:20:11 +0000</pubDate>
#       <enclosure url="http://sparkle-project.org/files/Sparkle%20Test%20App.zip" length="107758" type="application/octet-stream" sparkle:version="2.0" sparkle:dsaSignature="MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=="/>
#     </item>
#     <item>
#       <title>Version 3.0</title>
#       <description><![CDATA[HTML 2]]></description>
#       <pubDate>Sat, 26 Jul 2014 15:20:11 +0000</pubDate>
#       <enclosure url="http://sparkle-project.org/files/Sparkle%20Test%20App.zip" length="107758" type="application/octet-stream" sparkle:version="2.0" sparkle:dsaSignature="MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=="/>
#     </item>
#   </channel>
# </rss>

# item node xml
# <?xml version="1.0" encoding="utf-8"?>
# <item>
#   <title>Version 2.0</title>
#   <description><![CDATA[HTML]]></description>
#   <pubDate>Sat, 26 Jul 2014 15:20:11 +0000</pubDate>
#   <enclosure url="http://sparkle-project.org/files/Sparkle%20Test%20App.zip" length="107758" type="application/octet-stream" sparkle:version="2.0" sparkle:dsaSignature="MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=="/>
# </item>

def create_item(item_data)
  item = Sparklecast::Appcast::Item.new

  item.title = item_data.title
  item.description = item_data.description
  item.pub_date = item_data.pub_date
  item.url = item_data.url
  item.sparkle_version = item_data.sparkle_version
  item.length = item_data.length
  item.type = item_data.type
  item.dsa_signature = item_data.dsa_signature

  item
end

def check_item(node, xpath, item_data)
  expect(node).to have_xpath("#{xpath}/title").with_text(item_data.title)
  # check CDATA
  expect(node)
    .to have_xpath("#{xpath}/description")
      .with_text(item_data.description)
  expect(node)
    .to have_xpath("#{xpath}/pubDate")
      .with_text(item_data.pub_date.rfc2822)

  expect(node)
    .to have_xpath("#{xpath}/enclosure")
      .with_attr({
        'url' => item_data.url,
        'length' => item_data.length,
        'type' => item_data.type
        # 'sparkle:version' => '2.0',
        # 'sparkle:dsaSignature' => item_data.dsa_signature
      })
end

def check_appcast(xml, title, link, description, language)
  expect(xml).to have_xpath('//rss/channel/title').with_text(title)
  expect(xml).to have_xpath('//rss/channel/link').with_text(link)
  expect(xml).to have_xpath('//rss/channel/description').with_text(description)
  expect(xml).to have_xpath('//rss/channel/language').with_text(language)
end

describe Sparklecast::Appcast do
  let(:title) { 'Sparkle Test App Changelog' }
  let(:link) { 'http://sparkle-project.org/files/sparkletestcast.xml' }
  let(:description) { 'Most recent changes with links to updates.' }
  let(:language) { 'en' }

  subject(:cast) do
    described_class.new(
      title, link, description, language
    )
  end

  describe '#generate' do
    it 'generates correct appcast cast xml' do
      out = cast.generate

      root = Nokogiri::XML(out).xpath('//rss').first

      expect(root.namespaces).to match({
        'xmlns:sparkle' => 'http://www.andymatuschak.org/xml-namespaces/sparkle',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/'
      })
      expect(root.attr('version')).to eq('2.0')

      check_appcast(out, title, link, description, language)
    end
  end

  describe '.add_item' do
    subject(:cast) { described_class }

    let(:item_data) do
      OpenStruct.new(
        title: 'Version 2.0',
        description: 'HTML',
        pub_date: DateTime.new(2014, 07, 26, 15, 20, 11),
        url: 'http://sparkle-project.org/files/Sparkle%20Test%20App.zip',
        sparkle_version: '2.0',
        length: 107758,
        type: 'application/octet-stream',
        dsa_signature: 'MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=='
      )
    end

    let(:new_item_data) do
      OpenStruct.new(
        title: 'Version 3.0',
        description: 'HTML 2',
        pub_date: DateTime.new(2014, 07, 26, 15, 20, 11),
        url: 'http://sparkle-project.org/files/Sparkle%20Test%20App.zip',
        sparkle_version: '3.0',
        length: 107758,
        type: 'application/octet-stream',
        dsa_signature: 'ZCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=='
      )
    end

    it 'creates a new item in xml if there is no existing items' do
      original_xml = File.read(File.expand_path('../fixtures/empty_appcast.xml', __FILE__))
      item = create_item(item_data)
      result = cast.add_item(original_xml, item)

      check_appcast(result, title, link, description, language)

      check_item(result, '//rss/channel/item[1]', item_data)
    end

    it 'appends a new item into xml' do
      original_xml = File.read(File.expand_path('../fixtures/appcast_with_item.xml', __FILE__))

      item = create_item(new_item_data)
      result = cast.add_item(original_xml, item)

      check_appcast(result, title, link, description, language)

      check_item(result, '//rss/channel/item[1]', item_data)
      check_item(result, '//rss/channel/item[2]', new_item_data)
    end
  end
end

describe Sparklecast::Appcast::Item do
  let(:item_data) do
    OpenStruct.new(
      title: 'Version 2.0',
      description: 'HTML',
      pub_date: DateTime.new(2014, 07, 26, 15, 20, 11),
      url: 'http://sparkle-project.org/files/Sparkle%20Test%20App.zip',
      sparkle_version: '2.0',
      length: 107758,
      type: 'application/octet-stream',
      dsa_signature: 'MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=='
    )
  end

  subject(:item) { create_item(item_data) }

  describe '#to_node' do
    it 'creates item node' do
      item.title = 'Version 2.0'
      item.description = 'HTML'
      item.pub_date = DateTime.new(2014, 07, 26, 15, 20, 11)
      item.url = 'http://sparkle-project.org/files/Sparkle%20Test%20App.zip'
      item.sparkle_version = '2.0'
      item.length = 107758
      item.type = 'application/octet-stream'
      item.dsa_signature = 'MCwCFCdoW13VBGJWIfIklKxQVyetgxE7AhQTVuY9uQT0KOV1UEk21epBsGZMPg=='

      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        item.to_node(xml)
      end

      xml = builder.to_xml

      check_item(xml, '/item', item_data)
    end
  end
end
