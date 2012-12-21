# -*- coding: utf-8 -*-
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/defaults.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/html5.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/statistics.rb"

module Ledger

  class BalanceStatistics < Statistics

    def initialize report, options = {}
      super
      @report.type = 'cleared'
      @data_format = '%(quantity(scrub(get_at(display_total, 0))));' +
        '%(quantity(scrub(get_at(display_total, 1))));' +
        '%(account);' +
        '%(partial_account)\n%/'
      @data_header = 'names(ledger_data) <- c("balance","uncleared_balance","account","partial_account")'
    end

  end # class BalanceStatistics

end # module Ledger
