# frozen_string_literal: true

RSpec.describe SuperExpressiveRuby do
  def test_regex_equality_only(regex, super_expression)
    regex_str = regex.to_s
    super_expression_str = super_expression.to_regex_string
    expect(super_expression_str).to eq(regex_str)
  end

  def test_error_condition(errorMsg, super_expression_fn)
    expect(super_expression_fn).to raise_error.with_message(errorMsg)
  end

  def test_regex_equality(regex, super_expression)
    regex_str = regex.to_s
    super_expression_str = super_expression.to_regex_string
    expect(super_expression_str).to eq(regex_str)

    double_conversion = super_expression.to_regex.to_s
    expect(double_conversion).to eq(regex_str)
  end

  it 'has a version number' do
    expect(SuperExpressive::Ruby::VERSION).not_to be nil
  end

  # JavaScript
  # g	Global search.	RegExp.prototype.global
  # i	Case-insensitive search.	RegExp.prototype.ignoreCase
  # m	Multi-line search.	RegExp.prototype.multiline
  # s	Allows . to match newline characters.	RegExp.prototype.dotAll
  # u	"unicode"; treat a pattern as a sequence of unicode code points.	RegExp.prototype.unicode
  # y	Perform a "sticky" search that matches starting at the current position in the target string. See sticky.	RegExp.prototype.sticky

  # Ruby
  # Regexp#to_s https://ruby-doc.org/core-2.7.2/Regexp.html
  # Returns a string containing the regular expression and its options (using the (?opts:source) notation.
  # This string can be fed back in to Regexp::new to a regular expression with the same semantics as the original.
  # (However, Regexp#== may not return true when comparing the two, as the source of the regular expression itself may differ, as the example shows).
  # Regexp#inspect produces a generally more readable version of rxp.
  #
  # https://ruby-doc.org/core-2.7.2/Regexp.html#class-Regexp-label-Options
  # /pat/i - Ignore case
  # /pat/m - Treat a newline as a character matched by .
  # /pat/x - Ignore whitespace and comments in the pattern
  # /pat/o - Perform #{} interpolation only once
  it 'Empty regex' do
    test_regex_equality(/(?-mix:)/, SuperExpressive.create)
  end

  it 'Flag: g (Ruby does not have a g option.) use String#gsub or String#scan' do
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.allowMultipleMatches)
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.allow_multiple_matches)
  end

  # start of the line: ^
  # end of the line: $
  # start of the string: \A
  # end of the string: \z
  it 'Flag: m (Ruby does not have a line by line option.)' do
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.lineByLine)
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.line_by_line)
  end

  # /pat/i - Ignore case
  it 'Flag: i' do
    test_regex_equality(/(?i-mx:)/i, SuperExpressive.create.caseInsensitive)
    test_regex_equality(/(?i-mx:)/i, SuperExpressive.create.case_insensitive)
  end

  it 'Flag: y (Ruby does not have a y option.)' do
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.sticky)
  end

  it 'Flag: u (Ruby does not have a u option.)' do
    test_regex_equality(/(?-mix:)/, SuperExpressive.create.unicode)
  end

  # /pat/m - Treat a newline as a character matched by .
  it 'Flag: s (Ruby does not have a s option. but m option has the same meaning as the JavaScript s option.)' do
    test_regex_equality(/(?m-ix:)/, SuperExpressive.create.singleLine)
    test_regex_equality(/(?m-ix:)/, SuperExpressive.create.single_line)
  end

  it 'anyChar' do
    test_regex_equality(/(?-mix:.)/, SuperExpressive.create.anyChar)
    test_regex_equality(/(?-mix:.)/, SuperExpressive.create.any_char)
  end

  it 'whitespaceChar' do
    test_regex_equality(/(?-mix:\s)/, SuperExpressive.create.whitespaceChar)
    test_regex_equality(/(?-mix:\s)/, SuperExpressive.create.whitespace_char)
  end

  it 'nonWhitespaceChar' do
    test_regex_equality(/(?-mix:\S)/, SuperExpressive.create.nonWhitespaceChar)
    test_regex_equality(/(?-mix:\S)/, SuperExpressive.create.non_whitespace_char)
  end

  it 'digit' do
    test_regex_equality(/(?-mix:\d)/, SuperExpressive.create.digit)
  end

  it 'nonDigit' do
    test_regex_equality(/(?-mix:\D)/, SuperExpressive.create.nonDigit)
    test_regex_equality(/(?-mix:\D)/, SuperExpressive.create.non_digit)
  end

  it 'word' do
    test_regex_equality(/(?-mix:\w)/, SuperExpressive.create.word)
  end

  it 'nonWord' do
    test_regex_equality(/(?-mix:\W)/, SuperExpressive.create.nonWord)
    test_regex_equality(/(?-mix:\W)/, SuperExpressive.create.non_word)
  end

  it 'wordBoundary' do
    test_regex_equality(/(?-mix:\b)/, SuperExpressive.create.wordBoundary)
    test_regex_equality(/(?-mix:\b)/, SuperExpressive.create.word_boundary)
  end

  it 'nonWordBoundary' do
    test_regex_equality(/(?-mix:\B)/, SuperExpressive.create.nonWordBoundary)
    test_regex_equality(/(?-mix:\B)/, SuperExpressive.create.non_word_boundary)
  end

  it 'newline' do
    test_regex_equality(/(?-mix:\n)/, SuperExpressive.create.newline)
  end

  it 'carriageReturn' do
    test_regex_equality(/(?-mix:\r)/, SuperExpressive.create.carriageReturn)
    test_regex_equality(/(?-mix:\r)/, SuperExpressive.create.carriage_return)
  end

  it 'tab' do
    test_regex_equality(/(?-mix:\t)/, SuperExpressive.create.tab)
  end

  it 'nullByte' do
    test_regex_equality(/(?-mix:\0)/, SuperExpressive.create.nullByte)
    test_regex_equality(/(?-mix:\0)/, SuperExpressive.create.null_byte)
  end

  it 'anyOf: basic' do
    test_regex_equality(/(?-mix:hello|\d|\w|[\.\#])/,
                        SuperExpressive.create
                                       .anyOf
                                       .string('hello')
                                       .digit
                                       .word
                                       .char('.')
                                       .char('#')
                                       .end)

    test_regex_equality(/(?-mix:hello|\d|\w|[\.\#])/,
                        SuperExpressive.create
                                       .any_of
                                       .string('hello')
                                       .digit
                                       .word
                                       .char('.')
                                       .char('#')
                                       .end)
  end

  it 'anyOf: range fusion' do
    test_regex_equality(/[a-zA-Z0-9\.\#]/,
                        SuperExpressive.create
                          .anyOf
                          .range('a', 'z')
                          .range('A', 'Z')
                          .range('0', '9')
                          .char('.')
                          .char('#')
                          .end)

    test_regex_equality(/[a-zA-Z0-9\.\#]/,
                        SuperExpressive.create
                          .any_of
                          .range('a', 'z')
                          .range('A', 'Z')
                          .range('0', '9')
                          .char('.')
                          .char('#')
                          .end)
                          
  end

  it 'anyOf: range fusion with other choices' do
    test_regex_equality(/(?:XXX|[a-zA-Z0-9\.\#])/,
                        SuperExpressive.create
                      .anyOf
                      .range('a', 'z')
                      .range('A', 'Z')
                      .range('0', '9')
                      .char('.')
                      .char('#')
                      .string('XXX')
                      .end)

    test_regex_equality(/(?:XXX|[a-zA-Z0-9\.\#])/,
                        SuperExpressive.create
                      .any_of
                      .range('a', 'z')
                      .range('A', 'Z')
                      .range('0', '9')
                      .char('.')
                      .char('#')
                      .string('XXX')
                      .end)
  end

  it 'capture' do
    test_regex_equality(/(hello\ \w!)/,
                        SuperExpressive.create
                        .capture
                        .string('hello ')
                        .word
                        .char('!')
                        .end)
  end

  it 'namedCapture' do
    test_regex_equality(/(?<this_is_the_name>hello\ \w!)/,
                        SuperExpressive.create
                        .namedCapture('this_is_the_name')
                        .string('hello ')
                        .word
                        .char('!')
                        .end)

    test_regex_equality(/(?<this_is_the_name>hello\ \w!)/,
                        SuperExpressive.create
                        .named_capture('this_is_the_name')
                        .string('hello ')
                        .word
                        .char('!')
                        .end)
  end

  it 'namedCapture error on bad name' do
    test_error_condition(
      "name 'hello world' is not valid (only letters, numbers, and underscores)",
      proc {
        SuperExpressive.create
        .namedCapture('hello world')
        .string('hello ')
        .word
        .char('!')
        .end
      }
    )

    test_error_condition(
      "name 'hello world' is not valid (only letters, numbers, and underscores)",
      proc {
        SuperExpressive.create
        .named_capture('hello world')
        .string('hello ')
        .word
        .char('!')
        .end
      }
    )
  end

  it 'namedCapture error same name more than once' do
    test_error_condition(
      'cannot use hello again for a capture group',
      proc {
        SuperExpressive.create
            .namedCapture('hello')
            .string('hello ')
            .word
            .char('!')
            .end
            .namedCapture('hello')
            .string('hello ')
            .word
            .char('!')
            .end
      }
    )

    test_error_condition(
      'cannot use hello again for a capture group',
      proc {
        SuperExpressive.create
            .named_capture('hello')
            .string('hello ')
            .word
            .char('!')
            .end
            .named_capture('hello')
            .string('hello ')
            .word
            .char('!')
            .end
      }
    )
  end

  it 'namedBackreference' do
    test_regex_equality(
      /(?<this_is_the_name>hello\ \w!)\k<this_is_the_name>/,
      SuperExpressive.create
      .namedCapture('this_is_the_name')
      .string('hello ')
      .word
      .char('!')
      .end
      .namedBackreference('this_is_the_name')
    )

    test_regex_equality(
      /(?<this_is_the_name>hello\ \w!)\k<this_is_the_name>/,
      SuperExpressive.create
      .named_capture('this_is_the_name')
      .string('hello ')
      .word
      .char('!')
      .end
      .named_backreference('this_is_the_name')
    )
  end

  it 'namedBackreference no capture group exists' do
    test_error_condition(
      "no capture group called 'not_here' exists (create one with .namedCapture())",
      proc { SuperExpressive.create.namedBackreference('not_here') }
    )

    test_error_condition(
      "no capture group called 'not_here' exists (create one with .namedCapture())",
      proc { SuperExpressive.create.named_backreference('not_here') }
    )
  end

  it 'backreference' do
    test_regex_equality(/(hello\ \w!)\1/,
                        SuperExpressive.create
                          .capture
                          .string('hello ')
                          .word
                          .char('!')
                          .end
                          .backreference(1))
  end

  it 'backreference no capture group exists' do
    test_error_condition('invalid index 1. There are 0 capture groups on this SuperExpression',
                         proc { SuperExpressive.create.backreference(1) })
  end

  it 'group' do
    test_regex_equality(/(?:hello\ \w!)/,
                        SuperExpressive.create
                      .group
                      .string('hello ')
                      .word
                      .char('!')
                      .end)
  end

  it 'end: error when called with no stack' do
    test_error_condition(
      'Cannot call end while building the root expression.',
      proc { SuperExpressive.create.end }
    )
  end

  it 'assertAhead' do
    test_regex_equality(/(?=[a-f])[a-z]/,
                        SuperExpressive.create
                    .assertAhead
                    .range('a', 'f')
                    .end
                    .range('a', 'z'))

    test_regex_equality(/(?=[a-f])[a-z]/,
                        SuperExpressive.create
                    .assert_ahead
                    .range('a', 'f')
                    .end
                    .range('a', 'z'))
  end

  it 'assertNotAhead' do
    test_regex_equality(/(?![a-f])[0-9]/,
                        SuperExpressive.create
                          .assertNotAhead
                          .range('a', 'f')
                          .end
                          .range('0', '9'))

    test_regex_equality(/(?![a-f])[0-9]/,
                        SuperExpressive.create
                          .assert_not_ahead
                          .range('a', 'f')
                          .end
                          .range('0', '9'))
  end

  it 'optional' do
    test_regex_equality(/\w?/,
                        SuperExpressive.create.optional.word)
  end

  it 'zeroOrMore' do
    test_regex_equality(/\w*/,
                        SuperExpressive.create.zeroOrMore.word)

    test_regex_equality(/\w*/,
                        SuperExpressive.create.zero_or_more.word)
  end

  it 'zeroOrMoreLazy' do
    test_regex_equality(/\w*?/,
                        SuperExpressive.create.zeroOrMoreLazy.word)
                      
    test_regex_equality(/\w*?/,
                        SuperExpressive.create.zero_or_more_lazy.word)
  end

  it 'oneOrMore' do
    test_regex_equality(/\w+/,
                        SuperExpressive.create.oneOrMore.word)
                      
    test_regex_equality(/\w+/,
                        SuperExpressive.create.one_or_more.word)
  end

  it 'oneOrMoreLazy' do
    test_regex_equality(/\w+?/,
                        SuperExpressive.create.oneOrMoreLazy.word)

    test_regex_equality(/\w+?/,
                        SuperExpressive.create.one_or_more_lazy.word)
  end

  it 'exactly' do
    test_regex_equality(/\w{4}/, SuperExpressive.create.exactly(4).word)
  end

  it 'atLeast' do
    test_regex_equality(/\w{4,}/,
                        SuperExpressive.create.atLeast(4).word)

    test_regex_equality(/\w{4,}/,
                        SuperExpressive.create.at_least(4).word)
  end

  it 'between' do
    test_regex_equality(/\w{4,7}/,
                        SuperExpressive.create.between(4, 7).word)
  end

  it 'betweenLazy' do
    test_regex_equality(/\w{4,7}?/,
                        SuperExpressive.create.betweenLazy(4, 7).word)

    test_regex_equality(/\w{4,7}?/,
                        SuperExpressive.create.between_lazy(4, 7).word)
  end

  it 'startOfInput' do
    test_regex_equality(/^/,
                        SuperExpressive.create.startOfInput)

    test_regex_equality(/^/,
                        SuperExpressive.create.start_of_input)
  end

  it 'endOfInput' do
    test_regex_equality(/$/, SuperExpressive.create.endOfInput)
    test_regex_equality(/$/, SuperExpressive.create.end_of_input)
  end

  it 'anyOfChars' do
    test_regex_equality(/[aeiou\.\-]/, SuperExpressive.create.anyOfChars('aeiou.-'))
    test_regex_equality(/[aeiou\.\-]/, SuperExpressive.create.any_of_chars('aeiou.-'))
  end

  it 'anythingButChars' do
    test_regex_equality(/[^aeiou\.\-]/,
                        SuperExpressive.create.anythingButChars('aeiou.-'))
    test_regex_equality(/[^aeiou\.\-]/,
                        SuperExpressive.create.anything_but_chars('aeiou.-'))
  end

  it 'anythingButRange' do
    test_regex_equality(/[^0-9]/,
                        SuperExpressive.create.anythingButRange('0', '9'))
    test_regex_equality(/[^0-9]/,
                        SuperExpressive.create.anything_but_range('0', '9'))
  end

  it 'string' do
    test_regex_equality(/hello/, SuperExpressive.create.string('hello'))
  end

  it 'char' do
    test_regex_equality(/h/, SuperExpressive.create.string('h'))
  end

  it 'char: more than one' do
    test_error_condition('char() can only be called with a single character (got hello)',
                         proc { SuperExpressive.create.char('hello') })
  end

  it 'range' do
    test_regex_equality(/[a-z]/, SuperExpressive.create.range('a', 'z'))
  end

  it 'subexpression(expr): expr must be a SuperExpressive instance' do
    test_error_condition('expr must be a SuperExpressive instance',
                         proc { SuperExpressive.create.subexpression('nope') })
  end

  simple_sub_expression = SuperExpressive.create
                                         .string('hello')
                                         .anyChar
                                         .string('world')

  it 'simple' do
    test_regex_equality(/^\d{3,}hello.world[0-9]$/,
                        SuperExpressive.create
                  .startOfInput
                  .atLeast(3).digit
                  .subexpression(simple_sub_expression)
                  .range('0', '9')
                  .endOfInput)

    test_regex_equality(/^\d{3,}hello.world[0-9]$/,
                        SuperExpressive.create
                  .start_of_input
                  .at_least(3).digit
                  .subexpression(simple_sub_expression)
                  .range('0', '9')
                  .end_of_input)
  end

  it 'simple: quantified' do
    test_regex_equality(/^\d{3,}(?:hello.world)+[0-9]$/,
                        SuperExpressive.create
                        .startOfInput
                        .atLeast(3).digit
                        .oneOrMore.subexpression(simple_sub_expression)
                        .range('0', '9')
                        .endOfInput)

    test_regex_equality(/^\d{3,}(?:hello.world)+[0-9]$/,
                        SuperExpressive.create
                        .start_of_input
                        .at_least(3).digit
                        .one_or_more.subexpression(simple_sub_expression)
                        .range('0', '9')
                        .end_of_input)
  end

  flags_sub_expression = SuperExpressive.create
                                        .allowMultipleMatches
                                        .unicode
                                        .lineByLine
                                        .caseInsensitive
                                        .string('hello')
                                        .anyChar
                                        .string('world')

  it 'ignoring flags = false' do
    # Original  /^\d{3,}hello.world[0-9]$/gymiu,
    test_regex_equality(/^\d{3,}hello.world[0-9]$/ui,
                        SuperExpressive.create
                    .sticky
                    .startOfInput
                    .atLeast(3).digit
                    .subexpression(flags_sub_expression, { ignoreFlags: false })
                    .range('0', '9')
                    .endOfInput)

    test_regex_equality(/^\d{3,}hello.world[0-9]$/ui,
                        SuperExpressive.create
                    .sticky
                    .start_of_input
                    .at_least(3).digit
                    .subexpression(flags_sub_expression, { ignoreFlags: false })
                    .range('0', '9')
                    .end_of_input)
  end

  it 'ignoring flags = true' do
    # Original /^\d{3,}hello.world[0-9]$/y
    test_regex_equality(/^\d{3,}hello.world[0-9]$/,
                        SuperExpressive.create
                    .sticky
                    .startOfInput
                    .atLeast(3).digit
                    .subexpression(flags_sub_expression)
                    .range('0', '9')
                    .endOfInput)

    test_regex_equality(/^\d{3,}hello.world[0-9]$/,
                        SuperExpressive.create
                    .sticky
                    .start_of_input
                    .at_least(3).digit
                    .subexpression(flags_sub_expression)
                    .range('0', '9')
                    .end_of_input)
  end

  start_end_sub_expression = SuperExpressive.create
                                            .startOfInput
                                            .string('hello')
                                            .anyChar
                                            .string('world')
                                            .endOfInput

  it 'ignoring start/end = true' do
    test_regex_equality(/\d{3,}hello.world[0-9]/,
                        SuperExpressive.create
                .atLeast(3).digit
                .subexpression(start_end_sub_expression)
                .range('0', '9'))

    test_regex_equality(/\d{3,}hello.world[0-9]/,
                        SuperExpressive.create
                .at_least(3).digit
                .subexpression(start_end_sub_expression)
                .range('0', '9'))
  end

  it 'start defined in subexpression and main expression' do
    test_error_condition('The parent regex already has a defined start of input. You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option',
                         proc {
                           SuperExpressive.create
                                          .startOfInput
                                          .atLeast(3).digit
                                          .subexpression(start_end_sub_expression, { ignoreStartAndEnd: false })
                                          .range('0', '9')
                         })

      test_error_condition('The parent regex already has a defined start of input. You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option',
                         proc {
                           SuperExpressive.create
                                          .start_of_input
                                          .at_least(3).digit
                                          .subexpression(start_end_sub_expression, { ignoreStartAndEnd: false })
                                          .range('0', '9')
                         })
  end

  it 'end defined in subexpression and main expression' do
    test_error_condition('The parent regex already has a defined end of input. You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option',
                         proc {
                           SuperExpressive.create
                                 .endOfInput
                                 .subexpression(start_end_sub_expression, { ignoreStartAndEnd: false })
                         })

    test_error_condition('The parent regex already has a defined end of input. You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option',
                         proc {
                           SuperExpressive.create
                                 .end_of_input
                                 .subexpression(start_end_sub_expression, { ignoreStartAndEnd: false })
                         })
  end

  named_capture_sub_expression = SuperExpressive.create
                                                .namedCapture('module')
                                                .exactly(2).anyChar
                                                .end
                                                .namedBackreference('module')

  it 'no namespacing' do
    test_regex_equality(/\d{3,}(?<module>.{2})\k<module>[0-9]/,
                        SuperExpressive.create
                  .atLeast(3).digit
                  .subexpression(named_capture_sub_expression)
                  .range('0', '9'))

    test_regex_equality(/\d{3,}(?<module>.{2})\k<module>[0-9]/,
                        SuperExpressive.create
                  .at_least(3).digit
                  .subexpression(named_capture_sub_expression)
                  .range('0', '9'))
  end

  it 'namespacing' do
    test_regex_equality(/\d{3,}(?<yolomodule>.{2})\k<yolomodule>[0-9]/,
                        SuperExpressive.create
                    .atLeast(3).digit
                    .subexpression(named_capture_sub_expression, { namespace: 'yolo' })
                    .range('0', '9'))

      test_regex_equality(/\d{3,}(?<yolomodule>.{2})\k<yolomodule>[0-9]/,
                        SuperExpressive.create
                    .at_least(3).digit
                    .subexpression(named_capture_sub_expression, { namespace: 'yolo' })
                    .range('0', '9'))
  end

  it 'group name collision (no namespacing)' do
    test_error_condition('cannot use module again for a capture group',
                         proc {
                           SuperExpressive.create
                                                  .namedCapture('module')
                                                  .atLeast(3).digit
                                                  .end
                                                  .subexpression(named_capture_sub_expression)
                                                  .range('0', '9')
                         })

    test_error_condition('cannot use module again for a capture group',
                         proc {
                           SuperExpressive.create
                                                  .named_capture('module')
                                                  .at_least(3).digit
                                                  .end
                                                  .subexpression(named_capture_sub_expression)
                                                  .range('0', '9')
                         })
  end

  it 'group name collision (after namespacing)' do
    test_error_condition('cannot use yolomodule again for a capture group',
                         proc {
                           SuperExpressive.create
                                                    .namedCapture('yolomodule')
                                                    .atLeast(3).digit
                                                    .end
                                                    .subexpression(named_capture_sub_expression, { namespace: 'yolo' })
                                                    .range('0', '9')
                         })

      test_error_condition('cannot use yolomodule again for a capture group',
                         proc {
                           SuperExpressive.create
                                                    .named_capture('yolomodule')
                                                    .at_least(3).digit
                                                    .end
                                                    .subexpression(named_capture_sub_expression, { namespace: 'yolo' })
                                                    .range('0', '9')
                         })
  end

  indexed_backreference_subexpression = SuperExpressive.create
                                                       .capture
                                                       .exactly(2).anyChar
                                                       .end
                                                       .backreference(1)

  it 'indexed backreferencing' do
    test_regex_equality(/(\d{3,})(.{2})\2\1[0-9]/,
                        SuperExpressive.create
                          .capture
                          .atLeast(3).digit
                          .end
                          .subexpression(indexed_backreference_subexpression)
                          .backreference(1)
                          .range('0', '9'))

      test_regex_equality(/(\d{3,})(.{2})\2\1[0-9]/,
                        SuperExpressive.create
                          .capture
                          .at_least(3).digit
                          .end
                          .subexpression(indexed_backreference_subexpression)
                          .backreference(1)
                          .range('0', '9'))
  end

  nested_subexpression = SuperExpressive.create.exactly(2).anyChar
  first_layer_subexpression = SuperExpressive.create
                                             .string('outer begin')
                                             .namedCapture('innerSubExpression')
                                             .optional.subexpression(nested_subexpression)
                                             .end
                                             .string('outer end')

  it 'deeply nested subexpressions' do
    test_regex_equality(/(\d{3,})outer\ begin(?<innerSubExpression>(?:.{2})?)outer\ end[0-9]/,
                        SuperExpressive.create
                          .capture
                          .atLeast(3).digit
                          .end
                          .subexpression(first_layer_subexpression)
                          .range('0', '9'))

    test_regex_equality(/(\d{3,})outer\ begin(?<innerSubExpression>(?:.{2})?)outer\ end[0-9]/,
                        SuperExpressive.create
                          .capture
                          .at_least(3).digit
                          .end
                          .subexpression(first_layer_subexpression)
                          .range('0', '9'))

    # numbered backref/call is not allowed. (use name)
    # .backreference(1)
  end
end
