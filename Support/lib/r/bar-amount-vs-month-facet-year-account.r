# Bar chart of amount vs month, using faceting (more suitable than a stacked bar chart
# when there are many categories).
p <- qplot(month, amount, data = ledger_data, geom = "bar", stat = "identity") +
           facet_wrap(year ~ account)

ggsave(file = "bar-amount-vs-month-facet-year-account.svg", plot = p, width = 10, height = 6)      
