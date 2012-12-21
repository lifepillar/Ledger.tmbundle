p <- suppressMessages(ggplot(ledger_data, aes(partial_account, balance)) +
            geom_bar(stat="identity") +
            scale_y_continuous(name = commodity) +
            xlab("") + ylab(commodity))

suppressMessages(ggsave(file = "bar-balance-vs-account.svg", plot = p, width = 14, height = 4))
