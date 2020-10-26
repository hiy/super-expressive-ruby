# frozen_string_literal: true

class SuperExpressiveRuby
  require 'active_support'
  require "active_support/core_ext/object/deep_dup"

  attr_accessor :state

  NamedGroupRegex = /^[a-z]+\w*$/i.freeze
  QuantifierTable = {
    oneOrMore: '+',
    oneOrMoreLazy: '+?',
    zeroOrMore: '*',
    zeroOrMoreLazy: '*?',
    optional: '?',
    exactly: proc { |times| "{#{times}}" },
    atLeast: proc { |times| "{#{times},}" },
    between: proc { |times| "{#{times[0]},#{times[1]}}" },
    betweenLazy: proc { |times| "{#{times[0]},#{times[1]}}?" }
  }.freeze

  class << self
    def evaluate(el)
      case el[:type]
      when 'noop'
        ''
      when 'anyChar'
        '.'
      when 'whitespaceChar'
        '\\s'
      when 'nonWhitespaceChar'
        '\\S'
      when 'digit'
        '\\d'
      when 'nonDigit'
        '\\D'
      when 'word'
        '\\w'
      when 'nonWord'
        '\\W'
      when 'wordBoundary'
        '\\b'
      when 'nonWordBoundary'
        '\\B'
      when 'startOfInput'
        '^'
      when 'endOfInput'
        '$'
      when 'newline'
        '\\n'
      when 'carriageReturn'
        '\\r'
      when 'tab'
        '\\t'
      when 'nullByte'
        '\\0'
      when 'string'
        el[:value]
      when 'char'
        el[:value]
      when 'range'
        "[#{el[:value][0]}-#{el[:value][1]}]"
      when 'anythingButRange'
        "[^#{el[:value][0]}-#{el[:value][1]}]"
      when 'anyOfChars'
        "[#{el[:value]}]"
      when 'anythingButChars'
        "[^#{el[:value]}]"
      when 'namedBackreference'
        "\\k<#{el[:name]}>"
      when 'backreference'
        "\\#{el[:index]}"
      when 'subexpression'
        el[:value].map { |value| evaluate(value) }.join('')
      when 'optional',
           'zeroOrMore',
           'zeroOrMoreLazy',
           'oneOrMore',
           'oneOrMoreLazy'
        inner = evaluate(el[:value])
        with_group =
          if el[:value][:quantifierRequiresGroup]
            "(?:#{inner})"
          else
            inner
          end
        symbol = QuantifierTable[el[:type].to_sym]
        "#{with_group}#{symbol}"
      when 'betweenLazy',
      'between',
      'atLeast',
      'exactly'
        inner = evaluate(el[:value])
        withGroup =
          if el[:value][:quantifierRequiresGroup]
            "(?:#{inner})"
          else
            inner
          end
        "#{withGroup}#{QuantifierTable[el[:type].to_sym].call(el[:times])}"
      when 'anythingButString'
        chars = el[:value].split('').map { |c| "[^#{c}]" }.join('')
        "(?:#{chars})"
      when 'assertAhead'
        evaluated = el[:value].map { |v| evaluate(v) }.join('')
        "(?=#{evaluated})"
      when 'assertNotAhead'
        evaluated = el[:value].map { |v| evaluate(v) }.join('')
        "(?!#{evaluated})"
      when 'anyOf'
        fused, rest = fuse_elements(el[:value])
        return "[#{fused}]" unless rest.length

        evaluatedRest = rest.map { |v| evaluate(v) }
        separator = evaluatedRest.length > 0 && fused.length > 0 ? '|' : ''
        "(?:#{evaluatedRest.join('|')}#{separator}#{fused ? "[#{fused}]" : ''})"
      when 'capture'
        evaluated = el[:value].map { |v| evaluate(v) }
        "(#{evaluated.join('')})"
      when 'namedCapture'
        evaluated = el[:value].map { |v| evaluate(v) }
        "(?<#{el[:name]}>#{evaluated.join('')})"
      when 'group'
        evaluated = el[:value].map { |v| evaluate(v) }
        "(?:#{evaluated.join('')})"
      else
        raise "Can't process unsupported element type: #{el[:type]}"
      end
    end

    def as_type(type, opts={})
      proc { |value| { type: type, value: value }.merge(opts) }
    end

    def deferred_type(type, opts={})
      type_fn = as_type(type, opts)
      type_fn.call(type_fn)
    end

    def assert(condition, message)
      raise StandardError, message unless condition
    end

    def partition(a)
      r = a.each_with_object([[], []]) do |cur, acc|
        if is_fusable(cur)
          acc[0].push(cur)
        else
          acc[1].push(cur)
        end
        acc
      end
      [r[0], r[1]]
    end

    def is_fusable(element)
      element[:type] == 'range' ||
        element[:type] == 'char' ||
        element[:type] == 'anyOfChars'
    end

    def fuse_elements(elements)
      fusables, rest = partition(elements)
      fused = fusables.map do |el|
        if %w[char anyOfChars].include?(el[:type])
          el[:value]
        else
          "#{el[:value][0]}-#{el[:value][1]}"
        end
      end.join('')
      [fused, rest]
    end

    def camelize(snake_case_str)
      snake_case_str.split('_').each_with_object([]).with_index do |(s, acc), idx|
        acc << if idx.zero?
                 s
               else
                 s.capitalize
               end
      end.join
    end
  end

  @@t = {
    root: as_type('root').call,
    noop: as_type('noop').call,
    startOfInput: as_type('startOfInput').call,
    endOfInput: as_type('endOfInput').call,
    anyChar: as_type('anyChar').call,
    whitespaceChar: as_type('whitespaceChar').call,
    nonWhitespaceChar: as_type('nonWhitespaceChar').call,
    digit: as_type('digit').call,
    nonDigit: as_type('nonDigit').call,
    word: as_type('word').call,
    nonWord: as_type('nonWord').call,
    wordBoundary: as_type('wordBoundary').call,
    nonWordBoundary: as_type('nonWordBoundary').call,
    newline: as_type('newline').call,
    carriageReturn: as_type('carriageReturn').call,
    tab: as_type('tab').call,
    nullByte: as_type('nullByte').call,
    anyOfChars: as_type('anyOfChars'),
    anythingButString: as_type('anythingButString'),
    anythingButChars: as_type('anythingButChars'),
    anythingButRange: as_type('anythingButRange'),
    char: as_type('char'),
    range: as_type('range'),
    string: as_type('string', { quantifierRequiresGroup: true }),
    namedBackreference: proc { |name| deferred_type('namedBackreference', { name: name }) },
    backreference: proc { |index| deferred_type('backreference', { index: index }) },
    capture: deferred_type('capture', { containsChildren: true }),
    subexpression: as_type('subexpression', { containsChildren: true, quantifierRequiresGroup: true }),
    namedCapture: proc { |name| deferred_type('namedCapture', { name: name, containsChildren: true }) },
    group: deferred_type('group', { containsChildren: true }),
    anyOf: deferred_type('anyOf', { containsChildren: true }),
    assertAhead: deferred_type('assertAhead', { containsChildren: true }),
    assertNotAhead: deferred_type('assertNotAhead', { containsChildren: true }),
    exactly: proc { |times| deferred_type('exactly', { times: times, containsChild: true }) },
    atLeast: proc { |times| deferred_type('atLeast', { times: times, containsChild: true }) },
    between: proc { |x, y| deferred_type('between', { times: [x, y], containsChild: true }) },
    betweenLazy: proc { |x, y| deferred_type('betweenLazy', { times: [x, y], containsChild: true }) },
    zeroOrMore: deferred_type('zeroOrMore', { containsChild: true }),
    zeroOrMoreLazy: deferred_type('zeroOrMoreLazy', { containsChild: true }),
    oneOrMore: deferred_type('oneOrMore', { containsChild: true }),
    oneOrMoreLazy: deferred_type('oneOrMoreLazy', { containsChild: true }),
    optional: deferred_type('optional', { containsChild: true })
  }.freeze

  def initialize
    self.state = {
      hasDefinedStart: false,
      hasDefinedEnd: false,
      flags: {
        g: false,
        y: false,
        m: false,
        i: false,
        u: false,
        s: false
      },
      stack: [create_stack_frame(t[:root])],
      namedGroups: [],
      totalCaptureGroups: 0
    }
  end

  def t
    @@t
  end

  def escape_special(s)
    Regexp.escape(s)
  end

  def create_stack_frame(type)
    { type: type, quantifier: nil, elements: [] }
  end

  def allow_multiple_matches
    # warn("Warning: Ruby does not have a allow multiple matches option. use String#gsub or String#scan")
    n = clone
    n.state[:flags][:g] = true
    n
  end

  def line_by_line
    # warn("Warning: Ruby does not have a line by line option. use \A or \z as an alternative")
    n = clone
    n.state[:flags][:m] = true
    n
  end

  def case_insensitive
    n = clone
    n.state[:flags][:i] = true
    n
  end

  def sticky
    # warn("Warning: Ruby does not have a sticky option")
    n = clone
    n.state[:flags][:y] = true
    n
  end

  def unicode
    n = clone
    n.state[:flags][:u] = true
    n
  end

  def single_line
    n = clone
    n.state[:flags][:s] = true
    n
  end

  def match_element(type_fn)
    n = clone
    n.get_current_element_array.push(n.apply_quantifier(type_fn))
    n
  end

  def any_char
    match_element(t[:anyChar])
  end

  def whitespace_char
    match_element(t[:whitespaceChar])
  end

  def non_whitespace_char
    match_element(t[:nonWhitespaceChar])
  end

  def digit
    match_element(t[:digit])
  end

  def non_digit
    match_element(t[:nonDigit])
  end

  def word
    match_element(t[:word])
  end

  def non_word
    match_element(t[:nonWord])
  end

  def word_boundary
    match_element(t[:wordBoundary])
  end

  def non_word_boundary
    match_element(t[:nonWordBoundary])
  end

  def newline
    match_element(t[:newline])
  end

  def carriage_return
    match_element(t[:carriageReturn])
  end

  def tab
    match_element(t[:tab])
  end

  def null_byte
    match_element(t[:nullByte])
  end

  def named_backreference(name)
    assert(state[:namedGroups].include?(name), "no capture group called '#{name}' exists (create one with .namedCapture())")
    match_element(t[:namedBackreference].call(name))
  end

  def backreference(index)
    assert(index.is_a?(Integer), 'index must be a number')
    assert(index > 0 && index <= state[:totalCaptureGroups],
           "invalid index #{index}. There are #{state[:totalCaptureGroups]} capture groups on this SuperExpression")
    match_element(t[:backreference].call(index))
  end

  def frame_creating_element(type_fn)
    n = clone
    new_frame = create_stack_frame(type_fn)
    n.state[:stack].push(new_frame)
    n
  end

  def any_of
    frame_creating_element(t[:anyOf])
  end

  def group
    frame_creating_element(t[:group])
  end

  def assert_ahead
    frame_creating_element(t[:assertAhead])
  end

  def assert_not_ahead
    frame_creating_element(t[:assertNotAhead])
  end

  def capture
    n = clone
    new_frame = create_stack_frame(t[:capture])
    n.state[:stack].push(new_frame)
    n.state[:totalCaptureGroups] += 1
    n
  end

  def track_named_group(name)
    assert(name.is_a?(String), "name must be a string (got #{name})")
    assert(name.length > 0, 'name must be at least one character')
    assert(!state[:namedGroups].include?(name), "cannot use #{name} again for a capture group")
    assert(name.scan(NamedGroupRegex).any?, "name '#{name}' is not valid (only letters, numbers, and underscores)")

    state[:namedGroups].push name
  end

  def named_capture(name)
    n = clone
    new_frame = create_stack_frame(t[:namedCapture].call(name))

    n.track_named_group(name)
    n.state[:stack].push(new_frame)
    n.state[:totalCaptureGroups] += 1
    n
  end

  def quantifier_element(type_fn_name)
    n = clone
    current_frame = n.get_current_frame
    if current_frame[:quantifier]
      raise StandardError, "cannot quantify regular expression with '#{type_fn_name}' because it's already being quantified with '#{current_frame[:quantifier][:type]}'"
    end

    current_frame[:quantifier] = t[type_fn_name.to_sym]
    n
  end

  def optional
    quantifier_element('optional')
  end

  def zero_or_more
    quantifier_element('zeroOrMore')
  end

  def zero_or_more_lazy
    quantifier_element('zeroOrMoreLazy')
  end

  def one_or_more
    quantifier_element('oneOrMore')
  end

  def one_or_more_lazy
    quantifier_element('oneOrMoreLazy')
  end

  def exactly(n)
    assert(n.is_a?(Integer) && n > 0, "n must be a positive integer (got #{n})")

    nxt = clone
    current_frame = nxt.get_current_frame
    if current_frame[:quantifier]
      raise StandardError, "cannot quantify regular expression with 'exactly' because it's already being quantified with '#{current_frame[:quantifier][:type]}'"
    end

    current_frame[:quantifier] = t[:exactly].call(n)
    nxt
  end

  def at_least(n)
    assert(n.is_a?(Integer) && n > 0, "n must be a positive integer (got #{n})")
    nxt = clone
    current_frame = nxt.get_current_frame
    if current_frame[:quantifier]
      raise StandardError, "cannot quantify regular expression with 'atLeast' because it's already being quantified with '#{currentFrame.quantifier.type}'"
    end

    current_frame[:quantifier] = t[:atLeast].call(n)
    nxt
  end

  def between(x, y)
    assert(x.is_a?(Integer) && x >= 0, "x must be an integer (got #{x})")
    assert(y.is_a?(Integer) && y > 0, "y must be an integer greater than 0 (got #{y})")
    assert(x < y, "x must be less than y (x = #{x}, y = #{y})")

    nxt = clone
    current_frame = nxt.get_current_frame
    if current_frame[:quantifier]
      raise StandardError, "cannot quantify regular expression with 'between' because it's already being quantified with '#{currentFrame.quantifier.type}'"
    end

    current_frame[:quantifier] = t[:between].call(x, y)
    nxt
  end

  def between_lazy(x, y)
    assert(x.is_a?(Integer) && x >= 0, "x must be an integer (got #{x})")
    assert(y.is_a?(Integer) && y > 0, "y must be an integer greater than 0 (got #{y})")
    assert(x < y, "x must be less than y (x = #{x}, y = #{y})")

    n = clone
    current_frame = n.get_current_frame
    if current_frame[:quantifier]
      raise StandardError, "cannot quantify regular expression with 'betweenLazy' because it's already being quantified with '#{current_frame[:quantifier][:type]}'"
    end

    current_frame[:quantifier] = t[:betweenLazy].call(x, y)
    n
  end

  def start_of_input
    assert(!state[:hasDefinedStart], 'This regex already has a defined start of input')
    assert(!state[:hasDefinedEnd], 'Cannot define the start of input after the end of input')

    n = clone
    n.state[:hasDefinedStart] = true
    n.get_current_element_array.push(t[:startOfInput])
    n
  end

  def end_of_input
    assert(!state[:hasDefinedEnd], 'This regex already has a defined end of input')

    n = clone
    n.state[:hasDefinedEnd] = true
    n.get_current_element_array.push(t[:endOfInput])
    n
  end

  def any_of_chars(s)
    n = clone
    element_value = t[:anyOfChars].call(escape_special(s))
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(element_value))
    n
  end

  def end
    assert(state[:stack].length > 1, 'Cannot call end while building the root expression.')

    n = clone
    old_frame = n.state[:stack].pop
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(old_frame[:type][:value].call(old_frame[:elements])))
    n
  end

  def anything_but_string(str)
    assert(str.is_a?(String), "str must be a string (got #{str})")
    assert(str.length > 0, 'str must have least one character')

    n = clone
    element_value - t[:anythingButString].call(escape_special(str))
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(element_value))
    n
  end

  def anything_but_chars(chars)
    assert(chars.is_a?(String), "chars must be a string (got #{chars})")
    assert(chars.length > 0, 'chars must have at least one character')

    n = clone
    element_value = t[:anythingButChars].call(escape_special(chars))
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(element_value))
    n
  end

  def anything_but_range(a, b)
    str_a = a.to_s
    str_b = b.to_s

    assert(str_a.length === 1, "a must be a single character or number (got #{str_a})")
    assert(str_b.length === 1, "b must be a single character or number (got #{str_b})")
    assert(str_a[0].ord < str_b[0].ord, "a must have a smaller character value than b (a = #{str_a[0].ord}, b = #{str_b[0].ord})")

    n = clone
    element_value = t[:anythingButRange].call([a, b])
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(element_value))
    n
  end

  def string(str)
    assert('' != str, 'str cannot be an empty string')
    n = clone

    element_value =
      if str.length > 1
        t[:string].call(escape_special(str))
      else
        t[:char].call(str)
      end

    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(element_value))

    n
  end

  def char(c)
    assert(c.is_a?(String), "c must be a string (got #{c})")
    assert(c.length == 1, "char() can only be called with a single character (got #{c})")

    n = clone
    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(t[:char].call(escape_special(c))))
    n
  end

  def range(a, b)
    str_a = a.to_s
    str_b = b.to_s

    assert(str_a.length == 1, "a must be a single character or number (got #{str_a})")
    assert(str_b.length == 1, "b must be a single character or number (got #{str_b})")
    assert(str_a[0].ord < str_b[0].ord, "a must have a smaller character value than b (a = #{str_a[0].ord}, b = #{str_b[0].ord})")

    n = clone
    element_value = t[:range].call([str_a, str_b])
    current_frame = n.get_current_frame

    current_frame[:elements].push(n.apply_quantifier(element_value))
    n
  end

  def merge_subexpression(el, options, parent, increment_capture_groups)
    next_el = el.clone
    next_el[:index] += parent.state[:totalCaptureGroups] if next_el[:type] == 'backreference'

    increment_capture_groups.call if next_el[:type] == 'capture'

    if next_el[:type] === 'namedCapture'
      group_name =
        if options[:namespace]
          "#{options[:namespace]}#{next_el[:name]}"
        else
          next_el[:name]
        end

      parent.track_named_group(group_name)
      next_el[:name] = group_name
    end

    if next_el[:type] == 'namedBackreference'
      next_el[:name] =
        if options[:namespace]
          "#{options[:namespace]}#{next_el[:name]}"
        else
          next_el[:name]
        end
    end

    if next_el[:containsChild]
      next_el[:value] = merge_subexpression(
        next_el[:value],
        options,
        parent,
        increment_capture_groups
      )
    elsif next_el[:containsChildren]
      next_el[:value] = next_el[:value].map do |e|
        merge_subexpression(
          e,
          options,
          parent,
          increment_capture_groups
        )
      end
    end

    if next_el[:type] == 'startOfInput'

      return @@t[:noop] if options[:ignoreStartAndEnd]

      assert(
        !parent.state[:hasDefinedStart],
        'The parent regex already has a defined start of input. ' +
        'You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option'
      )

      assert(
        !parent.state[:hasDefinedEnd],
        'The parent regex already has a defined end of input. ' +
          'You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option'
      )

      parent.state[:hasDefinedStart] = true
    end

    if next_el[:type] == 'endOfInput'
      return @@t[:noop] if options[:ignoreStartAndEnd]

      assert(
        !parent.state[:hasDefinedEnd],
        'The parent regex already has a defined start of input. ' +
        'You can ignore a subexpressions startOfInput/endOfInput markers with the ignoreStartAndEnd option'
      )

      parent.state[:hasDefinedEnd] = true
    end
    next_el
  end

  def apply_subexpression_defaults(expr)
    out = {}.merge(expr)

    out[:namespace] = out.has_key?(:namespace) ? out[:namespace] : ''
    out[:ignoreFlags] = out.has_key?(:ignoreFlags) ? out[:ignoreFlags] : true
    out[:ignoreStartAndEnd] = out.has_key?(:ignoreStartAndEnd) ? out[:ignoreStartAndEnd] : true
    assert(out[:namespace].is_a?(String), 'namespace must be a string')
    assert(out[:ignoreFlags].is_a?(TrueClass) || out[:ignoreFlags].is_a?(FalseClass), 'ignoreFlags must be a boolean')
    assert(out[:ignoreStartAndEnd].is_a?(TrueClass) || out[:ignoreStartAndEnd].is_a?(FalseClass), 'ignoreStartAndEnd must be a boolean')

    out
  end

  def subexpression(expr, opts = {})
    assert(expr.is_a?(SuperExpressiveRuby), 'expr must be a SuperExpressive instance')
    assert(
      expr.state[:stack].length === 1,
      'Cannot call subexpression with a not yet fully specified regex object.' +
      "\n(Try adding a .end() call to match the '#{expr.get_current_frame[:type][:type]}' on the subexpression)\n"
    )

    options = apply_subexpression_defaults(opts)

    expr_n = expr.clone
    expr_n.state = expr.state.deep_dup
    n = clone
    additional_capture_groups = 0

    expr_frame = expr_n.get_current_frame
    closure = proc { additional_capture_groups += 1 }

    expr_frame[:elements] = expr_frame[:elements].map do |e|
      merge_subexpression(e, options, n, closure)
    end

    n.state[:totalCaptureGroups] += additional_capture_groups

    unless options[:ignoreFlags]
      expr_n.state[:flags].to_a.each do |e|
        flag_name = e[0]
        enabled = e[1]
        n.state[:flags][flag_name] = enabled || n.state[:flags][flag_name]
      end
    end

    current_frame = n.get_current_frame
    current_frame[:elements].push(n.apply_quantifier(t[:subexpression].call(expr_frame[:elements])))
    n
  end

  def to_regex_string
    pattern, flags = get_regex_pattern_and_flags
    Regexp.new(pattern, flags).to_s
  end

  def to_regex
    pattern, flags = get_regex_pattern_and_flags
    Regexp.new(pattern, flags)
  end

  def get_regex_pattern_and_flags
    assert state[:stack].length === 1,
           "Cannot compute the value of a not yet fully specified regex object.
             \n(Try adding a .end() call to match the '#{get_current_frame[:type][:type]}')\n"
    pattern = get_current_element_array.map { |el| self.class.evaluate(el) }.join('')
    flag = nil
    state[:flags].map do |name, is_on|
      if is_on
        flag = 0 if !flag
        case name
        when :s
          flag = flag | Regexp::MULTILINE
        when :i
          flag = flag | Regexp::IGNORECASE
        when :x
          flag = flag | Regexp::EXTENDED
        end
      end
    end
    pat = (pattern == '' ? '(?:)' : pattern)
    [pat, flag]
  end

  def apply_quantifier(element)
    current_frame = get_current_frame
    if current_frame[:quantifier]
      wrapped = current_frame[:quantifier][:value].call(element)
      current_frame[:quantifier] = nil
      return wrapped
    end
    element
  end

  def get_current_frame
    state[:stack][state[:stack].length - 1]
  end

  def get_current_element_array
    get_current_frame[:elements]
  end

  def assert(condition, message)
    self.class.assert(condition, message)
    raise StandardError, message unless condition
  end

  # generate camel case methods
  public_instance_methods(false).each do |method_name|
    camelized_method_name = camelize(method_name.to_s)
    alias_method camelized_method_name, method_name
  end
end
