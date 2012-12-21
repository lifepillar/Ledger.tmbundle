# See http://learnr.wordpress.com/2009/04/23/ggplot2-budget-vs-actual-performance/
p <- ggplot(ledger_data, aes(partial_account)) +
            geom_bar(aes(y = actual), width = .75, fill = "grey55") +
            geom_errorbar(aes(ymin = budgeted, ymax = budgeted), size = 1 ) +
            facet_wrap(~ partial_account, ncol = 4, scales = "free") +
            geom_text(aes(y=1, label = paste(round(ledger_data$remaining), " (", round(ledger_data$used), "%)", sep=""),
                      vjust = -0.6, size = 4)) +
            xlab("") +
            ylab(commodity)

suppressMessages(ggsave(file="bar-budget.svg", plot = p, width = 12, height = 4 * (length(ledger_data$account) / 4)))

