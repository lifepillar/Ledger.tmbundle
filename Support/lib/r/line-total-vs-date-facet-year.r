p <- ggplot(ledger_data, aes(date, total)) +
            geom_line() +
            geom_smooth(method="loess") +
            scale_x_date(breaks = "1 month", minor_breaks = "1 week", labels = date_format("%b")) +
            scale_y_continuous(name = commodity) +
            facet_wrap(~year) +
            theme(axis.title.x = element_blank()) # No title on the x-axis

suppressMessages(ggsave(file="line-total-vs-date-facet-year.svg", plot=p, width=12, height=3))
