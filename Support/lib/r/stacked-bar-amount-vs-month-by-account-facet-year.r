# Plot a stacked bar-chart.
# This is not very easy to read if the number of accounts exceeds three or four.
p <- qplot(month, amount, data = ledger_data, fill = account, geom = "bar", stat = "identity", facets = ~year)

ggsave(file = "stacked-bar-amount-vs-month-by-account-facet-year.svg", plot = p, width = 10, height = 6)
