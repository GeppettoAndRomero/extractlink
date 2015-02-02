# ExtractLink

ExtractLink for Ruby 1.9+

## Installation

Edit Gemfile.

    $ vi Gemfile

Add a following line to Gemfile.

```ruby
gem 'extractlink', github: 'GeppettoAndRomero/extractlink'
```

Install the gem.

    $ bundle install

## Usage

```ruby
require 'bundler/setup'
require 'extractlink'

html = ...
href_array,iframe_array,link_array = ExtractLink.analyse(html)

```

## License

The BSD License

The original code was written by [Nakatani Shuyo](http://labs.cybozu.co.jp/blog/nakatani/2007/09/web_1.html).

