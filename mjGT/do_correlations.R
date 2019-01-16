#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=T)

write("\n--- do_correlations.R ---\n", "/dev/stdout");

if (length(args) < 1) {
    err = "/dev/stderr";
    write("USAGE:\n\tdo_correlations.R -h", err);
    write("USAGE:\n\tdo_correlations.R dataframe\n", err);
    write("quitting with status 1", err);
    quit("no", 1);
} else if  (args[1] == "-h") {
    out = "/dev/stdout";
    write("USAGE:\n\tdo_correlations.R -h: this message", out);
    write("USAGE:\n\tdo_correlations.R dataframe", out);
    write("\t---------------------------------------------", out);
    write("\twhere `dataframe' has the following tab-delimited columns:", out);
    write("\tchrom  chromStart  chromEnd  ID  min_1  mean_1  max_1  N_1  min_2  mean_2  max_2  N_2 [min_2    mean_2   max_2    N_i ...]", out); 
    write("\tFor each sample (_1, _2, etc), the min,mean,max,and N refer to the corresponding quantitative value assessed over the region", out);
    write("\tspecified by: chrom, chromStart, chromEnd, ID", out);
    write("\t---------------------------------------------", out);
    write("\tA tool to compose such a dataframe from bigwig files:", out);
    write("\thttps://github.com/meekrob/java-genomics-toolkit", out);
    write("\tngs.SplitWigIntervalsToDataFrame", out);
    write("", out);
    quit("no", 0);
}


infile = args[1]
df = read.table(infile, header=T);
print(list(ncols=ncol(df), nrows=nrow(df)))

library(stringr);
h = colnames(df)
N = length(h)
hh = h[5:N]
x = df[,5:N]
# strip file extension garbage
hn = str_split_fixed(hh, "[.]",n=2)[,1]
colnames(x) <- hn
max_cols = str_detect(hh, "max")
#print(list(h=h,hh=hh,hn=hn,max_cols=max_cols))
maxes = x[,max_cols]
# remove any rows with missing data
real = apply(x, 1, function(x) { ! any(is.na(x)) })
maxes = maxes[ real, ]
options(width=290)

write("\nPearson correlation matrix", "")
cor(maxes)

write("\nSpearman correlation matrix", "")
cor(maxes, method="spearman")
