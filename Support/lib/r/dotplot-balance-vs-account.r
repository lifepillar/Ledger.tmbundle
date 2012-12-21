p <- suppressMessages(ggplot(ledger_data, aes(account, balance)) +
            geom_point(aes(balance, account)) + geom_segment(aes(x = 0, xend = balance, y = account, yend = account)) +
            xlab(commodity) + ylab(""))

suppressMessages(ggsave(file = "dotplot-balance-vs-account.svg", plot = p, width = 14, height = .5 * length(ledger_data$account)))
