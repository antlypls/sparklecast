# Sparklecast

[![Code Climate](http://img.shields.io/codeclimate/github/antlypls/sparklecast.svg?style=flat)](https://codeclimate.com/github/antlypls/sparklecast)
[![Build Status](http://img.shields.io/travis/antlypls/sparklecast.svg?style=flat)](https://travis-ci.org/antlypls/sparklecast)

Sparklecast helps you to create and modify
[Sparkle's](https://github.com/sparkle-project/Sparkle) appcast files.

## Installation

Add this line to your application's Gemfile:

    gem 'sparklecast'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sparklecast

## Usage

```{ruby}
appcast = Sparklecast::Appcast.new(
  'Sparkle Test App Changelog',
  'http://sparkle-project.org/files/sparkletestcast.xml',
  'Most recent changes with links to updates.',
  'en'
)

appcast.generate # returns an appcast rss feed
```

## Contributing

1. Fork it ( https://github.com/antlypls/sparklecast/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
