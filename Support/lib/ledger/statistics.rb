# -*- coding: utf-8 -*-
require 'tmpdir'
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/defaults.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/html5.rb"

module Ledger

  # Class for generating statistics and graphs.
  class Statistics

    attr :working_dir

    def initialize report, options = {}
      @working_dir = options[:dir] || Dir.mktmpdir('Ledger-R_')
      @autocleanup = options[:autocleanup] ? options[:autocleanup] : true
      @ggplot_theme = options[:ggplot_theme] || GGPLOT2_THEME
      @report = Ledger::Report.new(report.type, report.args_hash)
      @script = ''
      # date; year; month; month_num; wday; wday_num; week; mday; amount; total; payee; account
      @data_format = '%(format_date(date,\"%Y-%m-%d;%Y;%b;%m;%a;%u;%W;%d\"));%(quantity(scrub(display_amount)));%(quantity(scrub(display_total)));%(payee);%(display_account)\n'
      @data_header = 'names(ledger_data) <- c("date","year","month","month_num","wday","wday_num","week","mday","amount","total","payee","account")' + "\n" +
        'ledger_data$date <- as.Date(ledger_data$date, "%Y-%m-%d")'
      @html_report = nil
      check_for_r
    end

    def input script_name
      @script << File.open(ENV['TM_BUNDLE_SUPPORT']+"/lib/r/#{script_name}.r", 'r').read
      @script << "\n"      
    end

    def append snippet
      @script << snippet << "\n"
    end

    # Returns the report as an html snippet.
    def html_report attrs = {}
      return @html_report unless @html_report.nil?
      output = self.exec_r
      plots = []
      self.files('svg').each { |p| plots << Ledger::Html5::Svg.new(p) }
      @html_report = Ledger::Html5::Snippet.new('div', nil, attrs)
      unless plots.empty?
        figures = Ledger::Html5::Snippet.new('section', nil, :class => 'graphs')
        plots.each do |p|
          figures << Ledger::Html5::Snippet.new('figure', p, :class => p.id)
        end
        @html_report << figures
      end
      unless output.empty?
        @html_report << Ledger::Html5::Snippet.new('section', "<pre class=\"r\">\n"+output+"</pre>\n", :class => 'r')
      end
      cmd = @report.command
      cmd.gsub!(/</, '&lt;')
      cmd.gsub!(/>/, '&gt;')
      @html_report << Ledger::Html5::Snippet.new('pre', cmd, :class => 'ledger-command')
      self.cleanup if @autocleanup
      return @html_report
    end

    def to_s
      self.html_report.to_s      
    end

    # Prints the report as a stand-alone html document.
    def pretty_print title = '', options = {}
      opts = {:css => THEME }.merge!(options)
      html = Ledger::Html5::Page.new(title, :css => opts[:css])
      opts.delete(:css)
      html << self.html_report(opts)
      print html.to_s
    end

    def cleanup
      %x|rm -fr #{@working_dir}|
    end

    # Executes the R script and returns the raw output.
    def exec_r
      out = ''
      Dir.mkdir(@working_dir) unless File.exist?(@working_dir)
      Dir.chdir(@working_dir) do
        IO.popen("r --vanilla --slave --no-readline --encoding=UTF-8", mode='r+') do |io|
          io.write script_preamble
          io.write @script
          io.close_write # let the process know you've given it all the data
          out = io.read
        end
      end
      out.gsub!(/</, '&lt;')
      out.gsub!(/>/, '&gt;')
      return out
    end

    # Returns a list of paths to generated files.
    def files type
      Dir[@working_dir+"/*.#{type}"]
    end

    protected

    def script_preamble
      set_default_commodity
      @report.format = @data_format     
      <<EOR
library(ggplot2)
library(scales)
library(grid)
theme_set(#{@ggplot_theme}(base_size = 16))
commodity <- "#{@report.currency}"
ledger_command <- "#{@report.command(:escape => false)}"
ledger_data <- read.csv(pipe(ledger_command), header=F, sep=";")
#{@data_header}
EOR
    end

    def data_header
      <<EOH
names(ledger_data) <- c("date","year","month","month_num","wday","wday_num","week","mday","amount","total","payee","account")
ledger_data$date <- as.Date(ledger_data$date, '%Y-%m-%d')
EOH
    end

    private

    # In most cases, it is not possible to get suitable data from ledger when using
    # multiple commodities, because ledger's quantity() cannot be applied to amounts
    # in multiple commodities. Here, we make sure that a default currency has been set,
    # or otherwise we arbitrarily choose one.
    def set_default_commodity
      if @report.currency.nil? or @report.currency.empty? or 'All' == @report.currency
        @report.currency = @report.commodities.first
      end
    end

    def check_for_r
      if `which r 2>/dev/null`.empty?
        print '<h2>R not found</h2>'
        print <<EOHTML
<p>Please install R (http://www.r-project.org) and make sure that it is available to TextMate
by setting the PATH variable in TextMate &gt; Preferences &gt; Variables. R can be installed
with Homebrew (http://mxcl.github.com/homebrew/) or MacPorts (http://www.macports.org).
After installing R, install the ggplot2 package (http://ggplot2.org).
</p>
EOHTML

      end
    end
  end # class Statistics
end # module Ledger
