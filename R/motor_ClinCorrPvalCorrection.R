labels <- c('LeftM1_ba', 'RightCB_ba', 'RightM1_ba', 'SMA_ba',
            'LeftM1_prog', 'RightCB_prog', 'RightM1_prog', 'SMA_prog',
            'pSMA_ba', 'PFC_ba',
            'pSMA_prog', 'PFC_prog',
            'LeftPut_ba', 'RightPut_ba',
            'LeftPut_prog', 'RightPut_prog')
pvals <- c(0.032, 0.361, 0.005, 0.258,
           0.133, 0.042, 0.017, 0.011,
           0.019, 0.651, 
           0.139, 0.117,
           0.746, 0.369, 
           0.006, 0.185)
Sig.id <- (pvals < 0.05)
pvals.adj <- p.adjust(pvals, method = 'fdr')
Sig.id.adj <- (pvals.adj < 0.05)

labels[Sig.id]
pvals[Sig.id]

labels[Sig.id.adj]
pvals.adj[Sig.id.adj]




p.adjust(pvals, method = 'bonferroni')
