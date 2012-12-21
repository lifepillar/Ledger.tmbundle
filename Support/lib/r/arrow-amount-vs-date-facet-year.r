p <- ggplot(ledger_data, aes(date, amount)) +
            geom_segment(aes(xend = date, y = 0, yend = amount), arrow = arrow(length = unit(0.2,"cm"))) +
            scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels = date_format("%b")) +
            scale_y_continuous(name = commodity, labels = comma) +
            facet_wrap(~year) +
            theme(axis.title.x = element_blank()) # No title on the x-axis

suppressMessages(ggsave(file = "cash-flow-diagram.svg", plot = p,
                        width = 1+max(ledger_data$month_num)-min(ledger_data$month_num), height = 4))
