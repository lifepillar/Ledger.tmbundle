p <- ggplot(ledger_data, aes(partial_account, balance)) +
            geom_bar(stat="identity") +
            scale_y_continuous(name = commodity) +
            theme(axis.title.x = element_blank()) # No title on the x-axis

suppressMessages(ggsave(file = "bar-balance-vs-account.svg", plot = p, width = 8, height = 4))
