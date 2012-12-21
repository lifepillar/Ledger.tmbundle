p <- qplot(factor(week), factor(wday, levels = unique(wday[order(wday_num)]), ordered = T),
           data=ledger_data, fill = amount, geom = "tile") +
           scale_fill_gradientn(name = commodity, colours = c("#D61818","#FFAE63","#FFFFBD","#B5E384")) +
           scale_x_discrete(name = "Week", breaks=seq(min(ledger_data$week), max(ledger_data$week), by=5)) +
           facet_wrap(~year) +
           theme(axis.title.y = element_blank()) # No title on the y-axis

suppressMessages(ggsave(file="tile-amount-vs-week-wday-facet-year.svg", plot=p,
                        width=1+max(ledger_data$month_num)-min(ledger_data$month_num), height=3))
