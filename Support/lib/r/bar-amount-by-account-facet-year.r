p <- ggplot(ledger_data, aes(account, amount)) +
            geom_bar(stat="identity") +
            scale_y_continuous(name = commodity) +
            facet_wrap(~year) +
            theme(axis.title.x = element_blank()) # No title on the x-axis

suppressMessages(ggsave(file = "bar-amount-by-account-facet-year.svg", plot = p, width = 8, height = 4))
