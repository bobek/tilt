# frozen_string_literal: true
require_relative 'template'
require 'pandoc-ruby'


# some options are not recognized by pandoc
OPTIONS_TO_DROP = [:outvar, :context, :fenced_code_blocks, :keep_separator]

# Pandoc markdown implementation. See: http://pandoc.org/
Tilt::PandocTemplate = Tilt::StaticTemplate.subclass do
  # turn options hash into an array
  # Map tilt options to pandoc options
  # Replace hash keys with value true with symbol for key
  # Remove hash keys with value false
  # Remove prohibited keys
  # Leave other hash keys untouched
  pandoc_options = []
  from = "markdown"
  smart_extension = "-smart"
  @options.each do |k,v|
    continue if OPTIONS_TO_DROP.include?(k)

    case k
    when :smartypants
      smart_extension = "+smart" if v
    when :escape_html
      from = "markdown-raw_html" if v
    when :commonmark
      from = "commonmark" if v
    when :markdown_strict
      from = "markdown_strict" if v
    else
      case v
      when true
        pandoc_options << k
      when false
        # do nothing
      else
        pandoc_options << { k => v }
      end
    end
  end
  pandoc_options << { :f => from + smart_extension }

  PandocRuby.new(@data, *pandoc_options).to_html.strip
end
