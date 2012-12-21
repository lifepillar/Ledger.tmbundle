# -*- coding: utf-8 -*-
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/defaults.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/html5.rb"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/ledger/statistics.rb"

module Ledger

  class BudgetStatistics < Statistics

    def initialize report, options = {}
      super
      @report.type = 'budget'
      @data_format = '%(quantity(scrub(get_at(display_total, 0))));' +                            # actual
        '%(quantity(-scrub(get_at(display_total, 1))));' +                                        # budgeted
        '%(quantity(-scrub(get_at(display_total, 1) + get_at(display_total, 0))));' +              # remaining
        '%(quantity(get_at(display_total, 1) ? ' +
          '(100% * scrub(get_at(display_total, 0))) / -scrub(get_at(display_total, 1)) : \"na\"));' +  # used (%)
        '%(account);%(partial_account)\n%/'
      @data_header = 'names(ledger_data) <- c("actual","budgeted","remaining","used","account","partial_account")'
    end

  end # class BudgetStatistics

end # module Ledger
