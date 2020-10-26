# SuperExpressiveRuby

This gem is a port of https://github.com/francisrstokes/super-expressive

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'super-expressive-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install super-expressive-ruby

## Usage

### Example

<pre>
require 'super-expressive-ruby'

myRegex = SuperExpressive.create
  .startOfInput
  .optional.string('0x')
  .capture
    .exactly(4).anyOf
      .range('A', 'F')
      .range('a', 'f')
      .range('0', '9')
    .end
  .end
  .endOfInput
  .toRegex;

// Produces the following regular expression:
/^(?:0x)?((?:[A-Fa-f0-9]){4})$/
</pre>


### Snake cases are supported as well.

<pre>
require 'super-expressive-ruby'

my_regex = SuperExpressive.create
  .start_of_input
  .optional.string('0x')
  .capture
    .exactly(4).any_of
      .range('A', 'F')
      .range('a', 'f')
      .range('0', '9')
    .end
  .end
  .end_of_input
  .to_regex;

// Produces the following regular expression:
/^(?:0x)?((?:[A-Fa-f0-9]){4})$/
</pre>

### API Compatibility

Unsupported methods can be called but ignored.

- [ ] .allowMultipleMatches (use String#gsub or String#scan' as an alternative)
- [ ] .lineByLine (use \A or \z as an alternative)
- [x] .caseInsensitive
- [ ] .sticky (Ruby does not have JavaScript regular expression y option)
- [ ] .unicode
- [x] .singleLine
- [x] .anyChar
- [x] .whitespaceChar
- [x] .nonWhitespaceChar
- [x] .digit
- [x] .nonDigit
- [x] .word
- [x] .nonWord
- [x] .wordBoundary
- [x] .nonWordBoundary
- [x] .newline
- [x] .carriageReturn
- [x] .tab
- [x] .nullByte
- [x] .anyOf
- [x] .capture
- [x] .namedCapture(name)
- [x] .namedBackreference(name)
- [x] .backreference(index)
- [x] .group
- [x] .end()
- [x] .assertAhead
- [x] .assertNotAhead
- [x] .optional
- [x] .zeroOrMore
- [x] .zeroOrMoreLazy
- [x] .oneOrMore
- [x] .oneOrMoreLazy
- [x] .exactly(n)
- [x] .atLeast(n)
- [x] .between(x, y)
- [x] .betweenLazy(x, y)
- [x] .startOfInput
- [x] .endOfInput
- [x] .anyOfChars(chars)
- [x] .anythingButChars(chars)
- [x] .anythingButString(str)
- [x] .anythingButRange(a, b)
- [x] .string(s)
- [x] .char(c)
- [x] .range(a, b)
- [x] .subexpression(expr, opts?)
- [x] .toRegexString()
- [x] .toRegex()



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hiy/super-expressive-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hiy/super-expressive-ruby/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SuperExpressiveRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hiy/super-expressive-ruby/blob/master/CODE_OF_CONDUCT.md).
