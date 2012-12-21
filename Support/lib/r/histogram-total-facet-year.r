# Freedman–Diaconis rule for the bin width:
#bw <- 2 * IQR(ledger_data$total) / ((length(ledger_data$total) + 1)^(1/3))
# Scott's normal reference rule:
#bw <- 3.5 * sd(ledger_data$total) / ((length(ledger_data$total) + 1)^(1/3))
# Sturges' formula:
#bw <- ceiling(max(ledger_data$total) - min(ledger_data$total) / ceiling(1 + log2(length(ledger_data$total))))
# Square-root choice:
bw <- ceiling(max(ledger_data$total) - min(ledger_data$total)) / (sqrt(length(ledger_data$total))+1)

p <- qplot(total, data = ledger_data, geom = "histogram", binwidth = bw, position="identity",
                       facets = . ~ year, xlab = commodity, ylab = "Number of days")

suppressMessages(ggsave(file = "histogram-total-facet-year.svg", plot = p, width = 12, height = 4))

