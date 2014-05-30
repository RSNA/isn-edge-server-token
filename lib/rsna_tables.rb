module RSNARailsExtensions
    class RSNATableColumn
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::TagHelper

      attr_reader :name, :options
      attr_accessor :footer_proc, :footer_options, :output_buffer

      def initialize(col_name, opts={}, &val_proc)
        @name = col_name
        @value_proc = val_proc
        @footer_proc = nil
        @footer_options = {}
        @options = opts
      end

      def evaluate(item)
        val = @value_proc.call(item)
        if val.class == String
          val.html_safe
        else
          val
        end
      end

      def footerize(collection=nil)
        return(content_tag(:td) { "" }) if self.footer_proc.nil?
        summary = self.footer_options.delete(:summary)
        foot_opts = {:class => "footer"}.merge!(self.footer_options)
        if summary
          content_tag(:td, foot_opts) { self.footer_proc.call(collection.inject(0.0) {|total,item| total += coerce_string(self.evaluate(item)); total }) }
        else
          content_tag(:td, foot_opts) { val = self.footer_proc.call(collection); val ? val.html_safe : val }
        end
      end

      def coerce_string(string)
        if string =~ /^\$/
          string.gsub(/(\$|,)/i, "").to_f
        else
          string.html_safe
        end
      end

    end

  class RSNATable
    class NoSuchColumnError < RuntimeError; end
    class FootingStyleMismatchError < RuntimeError; end

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::JavaScriptHelper

    attr_accessor :output_buffer

    def initialize(list, html_options = {})
      opts = html_options.dup
      @collection = list
      @columns = []
      @has_proc_footers = false
      @has_total_footers = (opts.delete(:total) == true)
      @table_options = {
        :border => 0,
        :cellspacing => 0,
        :cellpadding => 2
      }.merge!(opts)
    end

    def column(col_name, opts={}, &blk)
      @columns.push(RSNATableColumn.new(col_name, opts, &blk))
    end

    def footer(col_name, opts = {}, &blk)
      raise(FootingStyleMismatchError.new("You already specified that you were using automatic totaling!")) if @has_total_footers
      col = column_for(col_name)
      raise(NoSuchColumnError.new("No column for '#{col_name}'!")) unless col
      @has_proc_footers = true
      col.footer_proc = blk
      col.footer_options = opts
    end


    def to_s
      res = single_row_for_section("thead", :name)
      foots = "<tfoot>"
      foots << make_proc_footers if @has_proc_footers
      foots << make_total_footers if @has_total_footers
      foots << "</tfoot>"
      tbl_tag_opts = @table_options.dup
      content_tag(:table, tbl_tag_opts) { res + create_rows.html_safe + foots.html_safe }
    end

    protected

    def column_for(col_name)
      @columns.detect { |c| c.name == col_name }
    end

    def values_for(col)
      @collection.map do |ele|
        col.send(:evaluate, ele)
      end
    end

    def make_footers
      final_out = content_tag(:tr) do
        out = @columns.inject("") do |accum, col|
          accum + (yield col)
        end
        return out ? out.html_safe : ""
      end
      return final_out.html_safe
    end

    def make_proc_footers
      make_footers do |col|
        col.footerize(@collection)
      end
    end

    def is_numeric?(val)
      return(true) if val.to_s.gsub(/,/, "").strip =~ /^[-+]?[0-9]*\.?[0-9]+$/
      false
    end

    def is_float?(val)
      val.to_s =~ /\./
      false
    end

    def numeric_total_from(vals)
      cproc = Proc.new do |vs, convert_method|
        vs.inject(0) do |acc, v|
          acc + v.send(convert_method)
        end
      end
      if (vals.any? { |v| !is_float?(v) })
        number_with_delimiter(cproc.call(vals, :to_i))
      else
        number_with_delimiter(number_with_precision(cproc.call(vals, :to_f), 2))
      end
    end

    def create_automatic_footer_for(col)
      col_vals = values_for(col)
      return(content_tag(:td, { :class => 'string-footer' }) { "--" }) if col_vals.any? { |v| not is_numeric?(v) }
      content_tag(:td, { :class => 'numeric-footer' }) { numeric_total_from(col_vals) }
    end

    def make_total_footers
      make_footers do |col|
        create_automatic_footer_for(col)
      end
    end

    def td_around_col_with(tag,meth_sym, *args)
      @columns.inject("") do |accum, col|
        accum + content_tag(tag, col.options) { col.send(meth_sym.to_sym, *args).to_s.strip.html_safe }
      end
    end

    def single_row_for_section(section_name, method_sym, opts = {})
      content_tag(section_name.to_sym) do
        content_tag(:tr, opts) { td_around_col_with(:th, method_sym).html_safe }
      end
    end

    def create_rows
      even = true
      res = @collection.inject("") do |accum, item|
        cls_val = even ? "even" : "odd"
        val = accum + content_tag(:tr, :class => cls_val) { td_around_col_with(:td, :evaluate, item).html_safe }
        even = !even
        val
      end
      content_tag(:tbody) { res.html_safe }
    end
  end

  module Helpers
    def rsna_table_for(list, html_opts = {}, &blk)
      html_tbl = RSNATable.new(list, html_opts)
      capture(html_tbl, &blk)
      html_tbl.to_s.html_safe
    end
  end
end
