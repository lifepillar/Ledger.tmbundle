p <- ggplot(data = ledger_data, aes(x = date, y = amount, colour = account)) + geom_line()

ggsave(file = "line-amount-vs-date-by-account.svg", plot = p7, width = 10, height = 4)
