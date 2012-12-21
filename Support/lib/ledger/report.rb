# -*- coding: utf-8 -*-
require 'shellwords'
require ENV['TM_SUPPORT_PATH'] + '/lib/osx/plist'
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/defaults.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/html5.rb"

module Ledger
  class Report
    attr :ledger
    attr :warnings
    attr_accessor :type
    attr_accessor :accounts
    attr_accessor :ignored_accounts
    attr_accessor :payee
    attr_accessor :since
    attr_accessor :until
    attr_accessor :display_since
    attr_accessor :display_until
    attr_accessor :effective_dates
    attr_accessor :currency
    attr_accessor :collapse
    attr_accessor :virtual
    attr_accessor :pivot
    attr_accessor :format
    attr_accessor :other
    attr_accessor :chart

    # type = balance, cleared, register, equity, …
    def initialize type, options = {}
      opts = { :accounts => [], :ignored_accounts => [], :other => [] }.merge!(options)
      @type = type
      @ledger = 'ledger' # Path to the ledger's executable
      @accounts = Array.new(opts[:accounts]) || []
      @ignored_accounts = Array.new(opts[:ignored_accounts]) || []
      @payee = opts[:payee] || ''
      @since = opts[:since] || ''
      @until = opts[:until] || ''
      @display_since = opts[:display_since] || ''
      @display_until = opts[:display_until] || ''
      @effective_dates = opts.has_key?(:effective_dates) ? opts[:effective_dates] : false
      @currency = opts[:currency]
      @collapse = opts.has_key?(:collapse) ? opts[:collapse] : false
      @virtual = opts.has_key?(:virtual) ? opts[:virtual] : false
      @pivot = opts[:pivot] || ''
      @format = opts[:format] || ''
      @other = Array.new(opts[:other]) || []
      @warnings = []
      @chart = opts.has_key?(:chart) ? opts[:chart] : false
    end

    def add_option opt
      @other << opt.strip
    end

    # Returns the list of commodities used in this report.
    #
    # See the note in #accounts.
    def commodities
      a = self.arguments
      a.delete_if { |e| e =~ /--(daily|weekly|biweekly|monthly|quarterly|yearly|collapse)/ }
      %x|#{self.ledger} commodities #{a.shelljoin}|.split(/\n/)
    end

    # Returns the list of the accounts used in this report.
    #
    # Note: '--monthly <non-existent account>' and similar (--daily, --weekly, etc…)
    # may cause ledger to segfault.
    def all_accounts
      a = self.arguments
      a.delete_if { |e| e =~ /--(daily|weekly|biweekly|monthly|quarterly|yearly)/ }
      %x|#{self.ledger} accounts #{a.shelljoin}|.split(/\n/)
    end

    # Returns the list of payees used in this report.
    #
    # See the note in #accounts.
    def all_payees
      a = self.arguments
      a.delete_if { |e| e =~ /--(daily|weekly|biweekly|monthly|quarterly|yearly)/ }
      %x|#{self.ledger} payees #{a.shelljoin}|.split(/\n/)
    end

    # Returns true if the user presses the OK button,
    # returns false if the user cancels or closes the window.
    def dialog nib_name = 'ReportDialog'
      comm = %x|#{self.ledger} commodities #{['--file', ENV['TM_FILEPATH']].shelljoin}|.split(/\n/)
      comm << 'All' if 'All' == self.currency
      self.currency = comm.first if self.currency.nil? or self.currency.empty?
      params = {
        'account' => self.accounts.join(','),
        'ignored' => self.ignored_accounts.join(','),
        'payee' => self.payee,
        'since' => self.since,
        'until' => self.until,
        'displaySince' => self.display_since,
        'displayUntil' => self.display_until,
        'effective' => self.effective_dates,
        'currencyList' => comm,
        'currency' => self.currency,
        'collapse' => self.collapse,
        'virtual' => self.virtual,
        'pivot' => self.pivot,
        'chart' => self.chart
      }
      nib = ENV['TM_BUNDLE_SUPPORT']+"/nib/#{nib_name}"
      return_value = %x{#{TM_DIALOG} -cmp #{e_sh params.to_plist} '#{nib}'}
      return_hash = OSX::PropertyList::load(return_value)
      result = return_hash['result']
      return false if result.nil?
      self.accounts = result['returnArgument'] ? result['returnArgument'].split(',') : []
      self.accounts.each { |a| a.strip! }
      self.ignored_accounts = result['ignored'] ? result['ignored'].split(',') : []
      self.payee = result['payee'] || ''
      self.since = result['since'] || ''
      self.until = result['until'] || ''
      self.display_since = result['displaySince'] || ''
      self.display_until = result['displayUntil'] || ''
      self.effective_dates = result['effective']
      self.currency = result['currency'] || ''
      self.currency = '' if self.currency =~ /all|none|no value/i
      self.collapse = result['collapse']
      self.virtual = result['virtual']
      self.pivot = result['pivot'] || ''
      self.chart = result['chart']
      return true
    end

    # Returns the command for this report.
    def command options = {}
      opts = { :escape => true }.merge!(options)
      if opts[:escape]
        return "#{self.ledger} #{self.type} #{self.arguments.shelljoin}"
      else
        return "#{self.ledger} #{self.type} #{self.arguments.map { |a| "'" + a + "'" }.join(' ')}"
      end
    end

    # Runs the report and returns the result as a string.
    # If :html is set to true, returns the result as an html snippet.
    def run options = {}
      opts = { :wrapper => 'pre' }.merge!(options)
      @warnings = []
      output = %x|#{self.ledger} #{self.type} #{self.arguments.shelljoin}|
      # Clean up
      output.gsub!(/<(Total|Unspecified payee|Revalued|Adjustment|None)>/) { |m| '&lt;' + $1 + '&gt;' }
      output = output.gsub(/class="[^"]*?amount.*?".*?<\//m) do |match|
        match.gsub(/(-\d+([,\.]\d+)*)/) do |amount|
          '<span class="neg">' + $1 + '</span>'
        end
      end
      if opts[:html]
        attrs = {}
        attrs[:id] = opts[:id] if opts[:id]
        attrs[:class] = opts[:class] if opts[:class]
        container = Ledger::Html5::Snippet.new('div', nil, attrs)
        section = Ledger::Html5::Snippet.new('section', nil)
        section << '<h2>' + opts[:title] + '</h2>' if opts[:title]
        content = Ledger::Html5::Snippet.new(opts[:wrapper], nil)
        if opts[:header] and 'table' == opts[:wrapper]
          header = "<thead>\n<tr>\n"
          opts[:header].each do |h|
            header << "<th scope=\"col\" class=\"header-#{h.downcase.gsub(/\s/,'-')}\">#{h}</th>\n"
          end
          header << "</tr>\n</thead>\n"
          content << header
        end
        content << output
        section << content
        container << section
        footer = Ledger::Html5::Snippet.new('footer', nil)
        unless @warnings.empty?
          warnings = Ledger::Html5::Snippet.new('ul', nil, :class => 'warnings')
          @warnings.each { |w| warnings << Ledger::Html5::Snippet.new('li', w) }
          footer << warnings
        end
        cmd = self.command(:escape => true)
        cmd.gsub!(/</, '&lt;')
        cmd.gsub!(/>/, '&gt;')
        footer << Ledger::Html5::Snippet.new('pre', cmd, :class => 'ledger-command')
        container << footer
        return container
      else
        return output
      end
    end

    # Prints the report.
    def pretty_print title = '', options = {}
      opts = { :html => true, :css => THEME }.merge!(options)
      output = self.run(opts)
      if opts[:html]
        html = Ledger::Html5::Page.new(title, :css => opts[:css])
        html << output
        print html.to_s
      else
        print output
      end
    end

    # Returns the arguments for the ledger executable as an array.
    def arguments
      args = ["--file=#{ENV['TM_FILEPATH']}"]
      args += self.accounts unless self.accounts.empty?
      unless self.ignored_accounts.empty?
        args << 'and' unless self.accounts.empty?
        args << 'not' << '('
        args += self.ignored_accounts
        args << ')'
      end
      args << 'payee' << '/'+self.payee.gsub(/,/,'|')+'/' unless self.payee.empty?
      pe = period_expr(self.since, self.until)
      args << '--limit' << pe unless pe.empty?
      if self.type =~ /bal/ or self.type =~ /cleared/ or self.type =~ /budget/
        # See http://article.gmane.org/gmane.comp.finance.ledger.general/3864/match=bug+value+expressions
        unless self.display_since.empty? and self.display_until.empty?
          @warnings << 'Display period is ignored for this report.'
        end
      else
        pe = period_expr(self.display_since, self.display_until)
        args << '--display' << pe unless pe.empty?
      end
      args << '-X' << currency unless self.currency.nil? or self.currency.empty?
      args << '--collapse' if self.collapse
      args << '--real' unless self.virtual
      args << '--effective' if self.effective_dates
      args << '--pivot' << self.pivot unless self.pivot.empty?
      args << '-F' << self.format unless self.format.empty?
      args += self.other unless self.other.empty?
      return args
    end

    def args_hash
      {
        :accounts => self.accounts,
        :ignored_accounts => self.ignored_accounts,
        :payee => self.payee,
        :since => self.since,
        :until => self.until,
        :display_since => self.display_since,
        :display_until => self.display_until,
        :effective_dates => self.effective_dates,
        :currency => self.currency,
        :collapse => self.collapse,
        :virtual => self.virtual,
        :pivot => self.pivot,
        :format => self.format,
        :other => self.other,
        :chart => self.chart
      }
    end

    # Returns a string representing a period expression in Ledger's syntax.
    def period_expr from, to
      return '' if from.empty? and to.empty?
      expr = ''
      expr << "d>=[#{from}]" unless from.empty?
      unless to.empty?
        expr << ' and ' unless from.empty?
        expr << "d<=[#{to}]"
      end
      return expr
    end

  end # class Report
end # module Ledger
