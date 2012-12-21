# Scatterplot faceted by payee, colored by account
p <- qplot(date, amount, data = ledger_data, geom = "point", colour = payee, alpha = I(1/2)) + facet_wrap(~account)

ggsave(file = "scatter-amount-vs-date-by-payee-facet-account.svg", plot = p, width = 10, height = 10)
