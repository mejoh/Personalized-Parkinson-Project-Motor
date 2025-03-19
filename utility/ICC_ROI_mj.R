library(tidyverse)
library(irr)
library(RNifti)

# Directories
con = 'con_0010'
projectdir = '/project/3024006.02/Analyses/motor_task/Group'
roidir = paste0(projectdir,'/ROI')
savedir = paste(projectdir, con, 'ICC', sep = '/')
firstlvldir1 = paste(projectdir, con, 'COMPLETE_ses-Visit1', sep = '/')
firstlvldir2 = paste(projectdir, con, 'COMPLETE_ses-Visit2', sep = '/')
Sub = str_sub(list.files(firstlvldir1), start = 1, end = 31)

# Mask
mask = paste(projectdir, con, 'ICC/ROI/x_HCgtPD_Mean_Mask.nii', sep = '/');
savename = ('HCgtPD_Mean');
mask = readNifti(mask)
mask.dims = dim(mask)
len <- mask.dims[1] * mask.dims[2] * mask.dims[3]
mask.vector <- as.vector(mask)
mask.vertices <- which(mask.vector > 0)

# Gather data
df <- tibble(con_a = list(),
             con_b = list(),
             con_a_m = numeric(),
             con_b_m = numeric())
for(s in 1:length(Sub)){
    
    print(Sub[s])
    
    # Vectorize input images
    con_a <- list.files(path = firstlvldir1, pattern = Sub[s], full.names = T) %>%
        readNifti() %>%
        as.vector()
    con_b <- list.files(path = firstlvldir2, pattern = Sub[s], full.names = T) %>%
        readNifti() %>%
        as.vector()
    
    # Summarize voxels in mask
    con_a_m <- con_a[mask.vertices] %>% mean()
    con_b_m <- con_b[mask.vertices] %>% mean()
    
    dat <- tibble(
        con_a = list(con_a),
        con_b = list(con_b),
        con_a_m = con_a_m,
        con_b_m = con_b_m
    )
    df <- bind_rows(df, dat)
    
}

# Derive stats
df.stat <- tibble(ICC = mask.vector*0,
                  ICC.p = mask.vector*0,
                  RHO = mask.vector*0,
                  RHO.p = mask.vector*0)
extract_idx <- function(vec,idx){
    x <- vec[idx]
    x
}
for(k in mask.vertices){
    
    print(k)
    
    # Define data
    tmp <- cbind(sapply(df$con_a, extract_idx, k),
                 sapply(df$con_b, extract_idx, k))
    
    # Intra-class correlation
    ICC <- icc(tmp, 'twoway', 'consistency', 'single')
    
    # Spearman correlation
    CORR <- cor.test(tmp[,1], tmp[,2], method = 'spearman')
    
    # Save output
    df.stat$ICC[k] <- ICC$value
    df.stat$ICC.p[k] <- ICC$p.value
    df.stat$RHO[k] <- CORR$estimate
    df.stat$RHO.p[k] <- CORR$p.value

}

# Write to file
names <- c('rICC','rICC_p','rRHO','rRHO_p')
for(n in 1:ncol(df.stat)){
    y <- vector(mode = 'numeric', length = len)
    y <- df.stat[,n] %>% unlist()
    outputfilename <- paste0(savedir, '/', names[n], '_', savename, '.nii.gz')
    writeNifti(array(y, mask.dims), outputfilename, template = mask, datatype = 'float')
}
