# Scatterplot faceted by payee, colored by account
p <- qplot(date, amount, data = ledger_data, geom = "point", colour = account, alpha = I(1/2)) + facet_wrap(~payee)

ggsave(file = "scatter-amount-vs-date-by-account-faceted-by-payee.svg", plot = p, width = 10, height = 10)
