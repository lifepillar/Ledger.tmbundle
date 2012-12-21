bw <- ceiling(max(ledger_data$amount) - min(ledger_data$amount)) / (sqrt(length(ledger_data$amount))+1)
p <- qplot(amount, data = ledger_data, geom = "histogram", binwidth = bw, position="identity",
                       facets = . ~ year, xlab = commodity, ylab = "Number of days")

suppressMessages(ggsave(file="histogram-amount-facet-year.svg", plot = p, width = 12, height = 4))

