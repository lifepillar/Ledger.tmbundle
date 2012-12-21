# -*- coding: utf-8 -*-

BALANCE_FORMAT = '<span class="amount">%(justify(scrub(display_total), 20, 20 + int(prepend_width), true, false))</span>' +
  '  %(!options.flat ? depth_spacer : "")' +
  '<span class="account">%-(partial_account(options.flat))</span>\n%/' +
  '<span class="amount total">%$2</span>\n%/' +
  '%(prepend_width ? " " * int(prepend_width) : "")' +
  '--------------------\n'

TABLE_BALANCE_FORMAT = '<tr><td class="amount">%(scrub(display_total))</td>' +
    '<td class="account">%(!options.flat ? depth_spacer : "")%(partial_account(options.flat))</td></tr>%/' +
    '<tr class="total"><td class="amount total">%$2</td><td></td></tr>%/'

BUDGET_FORMAT = '<span class="amount">%(justify(scrub(get_at(display_total, 0)), 20, -1, true, false))</span>' +
  ' <span class="amount">%(justify(-scrub(get_at(display_total, 1)), 20, ' +
  '           20 + 1 + 20, true, false))</span>' +
  ' <span class="amount">%(justify(scrub(get_at(display_total, 1) + ' +
  '                 get_at(display_total, 0)), 20, ' +
  '           20 + 1 + 20 + 1 + 20, true, false))</span>' +
  '%(get_at(display_total, 1) and (abs(quantity(scrub(get_at(display_total, 0))) / ' +
  '          quantity(scrub(get_at(display_total, 1)))) >= 1) ? ' +  
  ' " <span class=\"perc improper\">" : " <span class=\"perc\">")' +
  '%(justify((get_at(display_total, 1) ? ' +
  '          (100% * scrub(get_at(display_total, 0))) / ' +
  '             -scrub(get_at(display_total, 1)) : 0), ' +
  '           5, -1, true, false))</span>' +
  '  %(!options.flat ? depth_spacer : "")' +
  '<span class="account">%-(partial_account(options.flat))</span>\n' +
  '%/<span class="amount total">%$2</span> <span class="amount total">%$3</span>' +
  ' <span class="amount total">%$4</span> <span class="perc total">%$6</span>\n%/' +
  '%(prepend_width ? " " * int(prepend_width) : "")' +
  '---------------- ---------------- ---------------- -----\n'

TABLE_BUDGET_FORMAT = '<tr><td class="amount">%(scrub(get_at(display_total, 0)))</td>' +
    '<td class="amount">%(-scrub(get_at(display_total, 1)))</td>' +
    '<td class="amount">%(-(scrub(get_at(display_total, 1) + get_at(display_total, 0))))</td>' +
    '%(get_at(display_total, 1) and (abs(quantity(scrub(get_at(display_total, 0))) / ' +
    'quantity(scrub(get_at(display_total, 1)))) >= 1) ? ' +  
    '"<td class=\"perc improper\">" : "<td class=\"perc\">")' +
    '%(get_at(display_total, 1) ? ' +
    '          (100% * scrub(get_at(display_total, 0))) / ' +
    '             -scrub(get_at(display_total, 1)) : "na")</td>' +
    '<td class="account">%(!options.flat ? depth_spacer : "")%-(partial_account(options.flat))</td>' +
    '</tr>\n%/' +
    '<tr class="total"><td class="amount total">%$2</td><td class="amount total">%$3</td>' +
    '<td class="amount total">%$4</td> <td class="perc total">%$6</td><td class="total"></td></tr>\n%/'

CLEARED_FORMAT = '<span class="amount">%(justify(scrub(get_at(display_total, 0)), 20, 20 + int(prepend_width), ' +
  ' true, false))</span>  <span class="amount">%(justify(scrub(get_at(display_total, 1)), 20, ' +
  ' 42 + int(prepend_width), true, false))</span>' +
  '    %(latest_cleared ? "<span class=\"date\">" + format_date(latest_cleared) + "</span>" : "         ")' +
  '    %(!options.flat ? depth_spacer : "")' +
  '<span class="account">%-(partial_account(options.flat))</span>\n%/' +
  '<span class="amount total">%$2</span>  <span class="amount total">%$3</span>' +
  '    %$4\n%/' +
  '%(prepend_width ? " " * int(prepend_width) : "")' +
  '--------------------  --------------------    ---------\n'

TABLE_CLEARED_FORMAT = '<tr><td class="amount">%(scrub(get_at(display_total, 0)))</td>' +
    '<td class="amount">%(scrub(get_at(display_total, 1)))</td>' +
    '%(latest_cleared ? "<td class=\"date\">" + format_date(latest_cleared) + "</td>" : "<td></td>")' +
    '<td class="account">%(!options.flat ? depth_spacer : "")%-(partial_account(options.flat))</td></tr>\n%/' +
    '<tr class="total"><td class="amount total">%$2</td><td class="amount total">%$3</td>' +
    '<td>%$4</td></tr>\n%/'

DEBIT_CREDIT_FORMAT = '%(date > today ? "<span class=\"future date\">" : "<span class=\"date\">")' +
  '%(justify(format_date(date), int(date_width)))</span>' +
  '%(!cleared and actual ? "<span class=\"pending payee\">" : "<span class=\"payee\">")' +
  ' %(justify(truncated(payee, int(payee_width)), int(payee_width)))</span>' +
  ' <span class="account">%(justify(truncated(display_account, int(account_width),' +
  '                               int(abbrev_len)), int(account_width)))</span>' +
  ' <span class="amount">%(justify(scrub(abs(get_at(display_amount, 0))), int(amount_width), ' +
  '           3 + int(meta_width) + int(date_width) + int(payee_width)' +
  '           + int(account_width) + int(amount_width) + int(prepend_width),' +
  '           true, color))</span>' +
  ' <span class="amount">%(justify(scrub(abs(get_at(display_amount, 1))), int(amount_width), ' +
  '           4 + int(meta_width) + int(date_width) + int(payee_width)' +
  '             + int(account_width) + int(amount_width) + int(amount_width) + int(prepend_width),' +
  '           true, color))</span>' +
  '   <span class="amount total">%(justify(scrub(get_at(display_total, 0) + get_at(display_total, 1)), int(total_width), ' +
  '           5 + int(meta_width) + int(date_width) + int(payee_width)' +
  '            + int(account_width) + int(amount_width) + int(amount_width) + int(total_width)' +
  '             + int(prepend_width), true, color))</span>' +
  '\n%/' +
  '%(justify(" ", int(date_width)))' +
  '   %(justify(truncated(has_tag("Payee") ? "<span class=\"payee\">" + payee + "</span>" : " ", ' +
  '                     int(payee_width)), int(payee_width)))' +
  '%$5 %$6 %$7 %$8\n'
  
TABLE_DEBIT_CREDIT_FORMAT = '<tr><td><input name="status" value="" type="checkbox"></td>' +
  '%(date > today ? "<td class=\"future date\">" : "<td class=\"date\">")%(format_date(date))</td>' +
  '%(!cleared and actual ? "<td class=\"pending payee\">" : "<td class=\"payee\">")%(payee)</td>' +
  '<td class="account">%(display_account)</td>' +
  '<td class="amount">%(scrub(abs(get_at(display_amount, 0))))</td>' +
  '<td class="amount">%(scrub(abs(get_at(display_amount, 1))))</td>' +
  '<td class="amount total">%(scrub(get_at(display_total, 0) + get_at(display_total, 1)))</td>' +
  '</tr>\n%/' +
  '<tr><td></td><td></td>' +
  '%(has_tag("Payee") ? "<td class=\"payee\">" + payee + "</td>" : "<td></td>")' +
  '<td class="account">%$6</td><td class="amount">%$7</td><td class="amount">%$8</td><td class="amount total">%$9</td></tr>\n'


REGISTER_FORMAT = '%(date > today ? "<span class=\"future date\">" : "<span class=\"date\">")' +
  '%(justify(format_date(date), int(date_width)))</span>' +
  ' %(!cleared and actual ? "<span class=\"pending payee\">" : "<span class=\"payee\">")' +
  '%(justify(truncated(payee, int(payee_width)), int(payee_width)))</span>' +
  ' <span class="account">%(justify(truncated(display_account, int(account_width),' +
  '                               int(abbrev_len)), int(account_width)))</span>' +
  ' <span class="amount">%(justify(scrub(display_amount), int(amount_width),' +
  '           3 + int(meta_width) + int(date_width) + int(payee_width)' +
  '             + int(account_width) + int(amount_width) + int(prepend_width),' +
  '           true, false))</span>' +
  ' <span class="amount">%(justify(scrub(display_total), int(total_width),' +
  '            4 + int(meta_width) + int(date_width) + int(payee_width)' +
  '             + int(account_width) + int(amount_width) + int(total_width)' +
  '             + int(prepend_width), true, false))</span>' +
  '\n%/' +
  '%(justify(" ", int(date_width)))' +
  ' %(justify(truncated(has_tag("Payee") ? "<span class=\"payee\">" + payee + "</span>" : " ", ' +
  '                     int(payee_width)), int(payee_width)))' +
  ' <span class="account">%$4</span>' +
  '  <span class="amount">%$6</span>' +
  ' <span class="amount">%$7</span>\n'

TABLE_REGISTER_FORMAT = '%(!cleared and actual ? "<tr class=\"first-posting pending\">" : "<tr class=\"first-posting\">")' +
'<td><input name="status" value="" type="checkbox"></td>' +
'%(date > today ? "<td class=\"future date\">" : "<td class=\"date\">")%(format_date(date))</td>' +
  '<td class="payee">%(payee)</td>' +
  '<td class="account">%(display_account)</td>' +
  '<td class="amount">%(scrub(display_amount))</td>' +
  '<td class="amount">%(scrub(display_total))</td>' +
  '</tr>%/' +
  '<tr><td></td><td></td>' +
  '%(has_tag("Payee") ? "<td class=\"payee\">" + payee + "</td>" : "<td></td>")' +
  '<td class="account">%$5</td>' +
  '<td class="amount">%$6</td>' +
  '<td class="amount">%$7</td>' +
  '</tr>'

# In periodic reports, such as monthly expenses, Ledger uses the payee to store the end date of a period.
TABLE_PERIODIC_FORMAT = '<tr class="first-period">%(date > today ? "<td class=\"future date period\">" : "<td class=\"date period\">")%(format_date(date))' +
    ' %(payee)</td>' +
    '<td class="account">%(display_account)</td>' +
    '<td class="amount">%(scrub(display_amount))</td>' +
    '<td class="amount">%(scrub(display_total))</td>' +
    '</tr>\n%/' +
    '<tr>%(has_tag("Payee") ? "<td class=\"payee\">" + payee + "</td>" : "<td></td>")' +
    '<td class="account">%$5</td>' +
    '<td class="amount">%$6</td>' +
    '<td class="amount">%$7</td>' +
    '</tr>\n'

