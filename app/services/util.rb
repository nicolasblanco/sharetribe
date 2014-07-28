module Util
  module HashUtils
    module_function

    def compact(h)
      h.delete_if { |k, v| v.nil? }
    end

    def camelize_keys(h, deep=true)
      h.inject({}) { |memo, (k, v)|
        memo[k.to_s.camelize(:lower).to_sym] = deep && v.is_a?(Hash) ? camelize_keys(v) : v
        memo
      }
    end

    # Give hash `h` and `regexp` which will be matched against key
    def select_by_key_regexp(h, regexp)
      h.select { |key, value| key.to_s.match(regexp) }
    end

    # Usage:
    # deep_map({foo: {bar: 2}, baz: 3}) { |k, v| v * v } -> {foo: {bar: 4}, baz: 3}
    #
    def deep_map(h, &block)
      h.inject({}) do |memo, (k, v)|
        memo[k] = if v.is_a?(Hash)
          deep_map(v, &block)
        else
          block.call(k, v)
        end

        memo
      end
    end

    #
    # deep_contains({a: 1}, {a: 1, b: 2}) => true
    # deep_contains({a: 2}, {a: 1, b: 2}) => false
    # deep_contains({a: 1, b: 1}, {a: 1, b: 2}) => false
    # deep_contains({a: 1, b: 2}, {a: 1, b: 2}) => true
    #
    def deep_contains(needle, haystack)
      needle.all? do |key, val|
        haystack_val = haystack[key]

        if val.is_a?(Hash) && haystack_val.is_a?(Hash)
          deep_contains(val, haystack_val)
        else
          val == haystack_val
        end
      end
    end
  end

  module CamelizeHash
    def to_hash
      Util::HashUtils.camelize_keys(instance_hash(self))
    end

    module_function

    def instance_hash(instance)
      instance.instance_variables.inject({}) do |hash, var|
        hash[var.to_s.delete("@")] = instance.instance_variable_get(var)
        hash
      end
    end
  end

  module ArrayUtils
    module_function

    def next_and_prev(arr, curr)
      if arr.length <= 1
        [nil, nil]
      elsif arr.length == 2
        first, last = arr
        curr == first ? [last, last] : [first, first]
      else
        prev, mid, nexxt = each_cons_repeat(arr, 3).find { |(prev, mid, nexxt)| mid == curr  }
        [prev, nexxt]
      end
    end

    # Same as `each_cons` but repeats from the start
    #
    # Example:
    # [1, 2, 3, 4].each_cons(3) => [1, 2, 3], [2, 3, 4]
    #
    # [1, 2, 3, 4].each_cons_repeat(3) => [1, 2, 3], [2, 3, 4], [3, 4, 1], [4, 1, 2]
    def each_cons_repeat(arr, cons)
      (arr + arr.take(cons - 1)).each_cons(cons)
    end

    # Give array `xs` and number of `columns` to split. Get back array of columns
    #
    # each_slice_columns([1, 2, 3, 4, 5, 6, 7], 3) -> [[1, 2, 3], [4, 5], [6, 7]]
    def each_slice_columns(xs, columns, &block)
      div = xs.length / columns.to_f
      first_length = div.ceil
      rest_length = div.round

      first = xs.take(first_length)
      rest = rest_length > 0 ? xs.drop(first_length).each_slice(rest_length).to_a : []

      result = [first].concat(rest)

      if block
        result.each &block
      else
        result.each
      end
    end

    def trim(xs)
      xs.drop_while { |x| x.blank? }.reverse.drop_while { |x| x.blank? }.reverse
    end
  end

  module MoneyUtil
    module_function

    # Give string that represents money and get back the amount in cents
    #
    # Notice! The parsing strategy should follow the frontend validation strategy
    def parse_money_to_cents(money_str)
      # Current front-end validation: /^\d+((\.|\,)\d{0,2})?$/
      normalized = money_str.sub(",", ".");
      cents = normalized.to_f * 100
      cents.to_i
    end
  end

  module StringUtils
    module_function

    def first_words(str, word_count=15)
      str.split(" ").take(word_count).join(" ")
    end

    # this is a text -> this text (letter_count: 2)
    def strip_small_words(str, min_letter_count=2)
      str.split(" ").select { |word| strip_punctuation(word).length > min_letter_count }.join(" ")
    end

    def strip_punctuation(str)
      str.gsub(/[^[[:word:]]\s]/, '')
    end

    def keywords(str, word_count=10, min_letter_count=2)
      strip_punctuation(first_words(strip_small_words(str, min_letter_count), word_count)).downcase.split(" ").join(", ")
    end
  end

  module MailUtils

    # Refactoring needed. This is an ugly method that sets
    def set_up_urls(recipient, community, ref="email")
      @community = community
      @current_community = community
      @url_params = {}
      @url_params[:host] = community.full_domain
      @url_params[:ref] = ref
      if recipient
        @recipient = recipient
        @url_params[:auth] = @recipient.new_email_auth_token
        @url_params[:locale] = @recipient.locale
        set_locale @recipient.locale
      end
    end

    def premailer(message)
      if message.body.parts.present?
        message.text_part.body = Premailer.new(message.text_part.body.to_s, with_html_string: true).to_plain_text
        message.html_part.body = Premailer.new(message.html_part.body.to_s, with_html_string: true).to_inline_css
      else
        message.body = Premailer.new(message.body.to_s, with_html_string: true).to_inline_css
      end
    end

    module_function

    def community_specific_sender(community)
      if community && community.custom_email_from_address
        community.custom_email_from_address
      else
        APP_CONFIG.sharetribe_mail_from_address
      end
    end
  end
end
