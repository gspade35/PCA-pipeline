README
================

## Setup

## Introduction

PCA is a dimensionality reduction technique widely used in machine
learning and data visualization. It operates by calculating the
eigenvectors and eigenvalues of the covariance or correlation matrix.
These eigenvectors, also known as principal components, define the
directions in the new feature space that maximize variance. The
eigenvalues, on the other hand, quantify the magnitude of this variance
along each direction. In essence, the eigenvalues explain the variance
of the data along the new feature axes, which are the principal
components.

The eigenvectors of the covariance matrix correspond to the columns in
the projection matrix and are arranged in descending order of their
corresponding eigenvalues. These eigenvalues represent the amount of
variance explained by each eigenvector. The data matrix is then
multiplied by this projection matrix to project the data onto the
feature space defined by the principal components. These principal
components are linear combinations of the variables in the data matrix
and form an orthogonal basis (in statistics, “orthogonal” implies
“uncorrelated”) for this new feature space. The outcome represents the
coordinates of the original data points in this new feature space for
each principal component.

The first principal component is the direction in the data with the most
significant variance. The second principal component, orthogonal to the
first, has the second largest variance. This pattern continues for as
many principal components as there are dimensions in the original data.

So PCA can be utilized for noise reduction (by dropping columns in the
score matrix that explain a small amount of variance), feature
extraction (by referencing which features )

## Data Preparation

``` r
# Create sample dataframe
set.seed(123) # for reproducibility
sample_df <- data.frame(
  USUBJID = rep(sprintf("%03d", 1:100), each = 2), # 100 subjects, each repeated twice
  AGE = rep(rnorm(100, 50, 10), each = 2), # age from a normal distribution, each repeated twice
  SEX = rep(sample(c("M", "F"), 100, replace = TRUE), each = 2), # sex randomly assigned, each repeated twice
  TRT01P = rep(sample(c("Drug A", "Drug B"), 100, replace = TRUE), each = 2), # treatment randomly assigned, each repeated twice
  LBTESTCD = rep(c("AA","Ba"), 100), # two LBTESTCD values for each subject
  AVAL = rnorm(200, 5, 1) # two AVAL measures for each subject
)
sample_df
```

    ##     USUBJID      AGE SEX TRT01P LBTESTCD     AVAL
    ## 1       001 44.39524   F Drug B       AA 7.198810
    ## 2       001 44.39524   F Drug B       Ba 6.312413
    ## 3       002 47.69823   F Drug B       AA 4.734855
    ## 4       002 47.69823   F Drug B       Ba 5.543194
    ## 5       003 65.58708   F Drug A       AA 4.585660
    ## 6       003 65.58708   F Drug A       Ba 4.523753
    ## 7       004 50.70508   M Drug B       AA 4.211397
    ## 8       004 50.70508   M Drug B       Ba 4.405383
    ## 9       005 51.29288   F Drug A       AA 6.650907
    ## 10      005 51.29288   F Drug A       Ba 4.945972
    ## 11      006 67.15065   F Drug A       AA 5.119245
    ## 12      006 67.15065   F Drug A       Ba 5.243687
    ## 13      007 54.60916   F Drug B       AA 6.232476
    ## 14      007 54.60916   F Drug B       Ba 4.483936
    ## 15      008 37.34939   M Drug A       AA 4.007493
    ## 16      008 37.34939   M Drug A       Ba 6.675697
    ## 17      009 43.13147   F Drug A       AA 4.558837
    ## 18      009 43.13147   F Drug A       Ba 4.276934
    ## 19      010 45.54338   F Drug A       AA 3.763727
    ## 20      010 45.54338   F Drug A       Ba 3.715284
    ## 21      011 62.24082   F Drug B       AA 4.426027
    ## 22      011 62.24082   F Drug B       Ba 5.617986
    ## 23      012 53.59814   M Drug A       AA 6.109848
    ## 24      012 53.59814   M Drug A       Ba 5.707588
    ## 25      013 54.00771   M Drug B       AA 4.636343
    ## 26      013 54.00771   M Drug B       Ba 5.059750
    ## 27      014 51.10683   F Drug A       AA 4.295404
    ## 28      014 51.10683   F Drug A       Ba 4.282782
    ## 29      015 44.44159   F Drug B       AA 5.884650
    ## 30      015 44.44159   F Drug B       Ba 3.984407
    ## 31      016 67.86913   F Drug B       AA 6.955294
    ## 32      016 67.86913   F Drug B       Ba 4.909680
    ## 33      017 54.97850   F Drug B       AA 5.214539
    ## 34      017 54.97850   F Drug B       Ba 4.261472
    ## 35      018 30.33383   M Drug B       AA 4.425611
    ## 36      018 30.33383   M Drug B       Ba 3.682984
    ## 37      019 57.01356   F Drug A       AA 4.817075
    ## 38      019 57.01356   F Drug A       Ba 5.418982
    ## 39      020 45.27209   M Drug A       AA 5.324304
    ## 40      020 45.27209   M Drug A       Ba 4.218464
    ## 41      021 39.32176   F Drug A       AA 4.211378
    ## 42      021 39.32176   F Drug A       Ba 4.497801
    ## 43      022 47.82025   M Drug B       AA 6.496061
    ## 44      022 47.82025   M Drug B       Ba 3.862696
    ## 45      023 39.73996   M Drug A       AA 4.820948
    ## 46      023 39.73996   M Drug A       Ba 6.902362
    ## 47      024 42.71109   M Drug A       AA 4.899025
    ## 48      024 42.71109   M Drug A       Ba 3.640159
    ## 49      025 43.74961   F Drug B       AA 4.335231
    ## 50      025 43.74961   F Drug B       Ba 5.485460
    ## 51      026 33.13307   F Drug A       AA 4.624397
    ## 52      026 33.13307   F Drug A       Ba 4.438124
    ## 53      027 58.37787   M Drug A       AA 4.656083
    ## 54      027 58.37787   M Drug A       Ba 5.090497
    ## 55      028 51.53373   M Drug B       AA 6.598509
    ## 56      028 51.53373   M Drug B       Ba 4.911435
    ## 57      029 38.61863   F Drug A       AA 6.080799
    ## 58      029 38.61863   F Drug A       Ba 5.630754
    ## 59      030 62.53815   M Drug B       AA 4.886360
    ## 60      030 62.53815   M Drug B       Ba 3.467098
    ## 61      031 54.26464   M Drug B       AA 4.478883
    ## 62      031 54.26464   M Drug B       Ba 4.510130
    ## 63      032 47.04929   F Drug B       AA 5.047154
    ## 64      032 47.04929   F Drug B       Ba 6.300199
    ## 65      033 58.95126   F Drug A       AA 7.293079
    ## 66      033 58.95126   F Drug A       Ba 6.547581
    ## 67      034 58.78133   M Drug A       AA 4.866849
    ## 68      034 58.78133   M Drug A       Ba 3.243473
    ## 69      035 58.21581   F Drug A       AA 4.611220
    ## 70      035 58.21581   F Drug A       Ba 5.089207
    ## 71      036 56.88640   F Drug A       AA 5.845013
    ## 72      036 56.88640   F Drug A       Ba 5.962528
    ## 73      037 55.53918   F Drug B       AA 5.684309
    ## 74      037 55.53918   F Drug B       Ba 3.604726
    ## 75      038 49.38088   F Drug A       AA 5.849643
    ## 76      038 49.38088   F Drug A       Ba 4.553443
    ## 77      039 46.94037   F Drug A       AA 5.174803
    ## 78      039 46.94037   F Drug A       Ba 5.074551
    ## 79      040 46.19529   M Drug A       AA 5.428167
    ## 80      040 46.19529   M Drug A       Ba 5.024675
    ## 81      041 43.05293   M Drug A       AA 3.332525
    ## 82      041 43.05293   M Drug A       Ba 5.736496
    ## 83      042 47.92083   F Drug B       AA 5.386027
    ## 84      042 47.92083   F Drug B       Ba 4.734348
    ## 85      043 37.34604   M Drug B       AA 5.118145
    ## 86      043 37.34604   M Drug B       Ba 5.134039
    ## 87      044 71.68956   F Drug A       AA 5.221019
    ## 88      044 71.68956   F Drug A       Ba 6.640846
    ## 89      045 62.07962   M Drug B       AA 4.780950
    ## 90      045 62.07962   M Drug B       Ba 5.168065
    ## 91      046 38.76891   M Drug A       AA 6.168384
    ## 92      046 38.76891   M Drug A       Ba 6.054181
    ## 93      047 45.97115   M Drug A       AA 6.145263
    ## 94      047 45.97115   M Drug A       Ba 4.422532
    ## 95      048 45.33345   F Drug A       AA 7.002483
    ## 96      048 45.33345   F Drug A       Ba 5.066701
    ## 97      049 57.79965   F Drug B       AA 6.866852
    ## 98      049 57.79965   F Drug B       Ba 3.649097
    ## 99      050 49.16631   F Drug A       AA 5.020984
    ## 100     050 49.16631   F Drug A       Ba 6.249915
    ## 101     051 52.53319   M Drug A       AA 4.284758
    ## 102     051 52.53319   M Drug A       Ba 4.247311
    ## 103     052 49.71453   F Drug A       AA 4.061461
    ## 104     052 49.71453   F Drug A       Ba 3.947487
    ## 105     053 49.57130   F Drug B       AA 4.562840
    ## 106     053 49.57130   F Drug B       Ba 5.331179
    ## 107     054 63.68602   M Drug A       AA 2.985790
    ## 108     054 63.68602   M Drug A       Ba 5.211980
    ## 109     055 47.74229   M Drug A       AA 6.236675
    ## 110     055 47.74229   M Drug A       Ba 7.037574
    ## 111     056 65.16471   M Drug B       AA 6.301176
    ## 112     056 65.16471   M Drug B       Ba 5.756775
    ## 113     057 34.51247   M Drug A       AA 3.273270
    ## 114     057 34.51247   M Drug A       Ba 4.398493
    ## 115     058 55.84614   M Drug A       AA 4.647954
    ## 116     058 55.84614   M Drug A       Ba 5.703524
    ## 117     059 51.23854   F Drug A       AA 4.894329
    ## 118     059 51.23854   F Drug A       Ba 3.741351
    ## 119     060 52.15942   M Drug B       AA 6.684436
    ## 120     060 52.15942   M Drug B       Ba 5.911391
    ## 121     061 53.79639   F Drug B       AA 5.237430
    ## 122     061 53.79639   F Drug B       Ba 6.218109
    ## 123     062 44.97677   F Drug A       AA 3.661226
    ## 124     062 44.97677   F Drug A       Ba 5.660820
    ## 125     063 46.66793   F Drug A       AA 4.477088
    ## 126     063 46.66793   F Drug A       Ba 5.683746
    ## 127     064 39.81425   M Drug A       AA 4.939178
    ## 128     064 39.81425   M Drug A       Ba 5.632961
    ## 129     065 39.28209   F Drug B       AA 6.335518
    ## 130     065 39.28209   F Drug B       Ba 5.007290
    ## 131     066 53.03529   M Drug A       AA 6.017559
    ## 132     066 53.03529   M Drug A       Ba 3.811566
    ## 133     067 54.48210   F Drug B       AA 4.278396
    ## 134     067 54.48210   F Drug B       Ba 6.519218
    ## 135     068 50.53004   M Drug A       AA 5.377388
    ## 136     068 50.53004   M Drug A       Ba 2.947777
    ## 137     069 59.22267   M Drug B       AA 3.635963
    ## 138     069 59.22267   M Drug B       Ba 4.799219
    ## 139     070 70.50085   M Drug A       AA 5.865779
    ## 140     070 70.50085   M Drug A       Ba 4.898117
    ## 141     071 45.08969   M Drug A       AA 5.624187
    ## 142     071 45.08969   M Drug A       Ba 5.959005
    ## 143     072 26.90831   M Drug A       AA 6.671055
    ## 144     072 26.90831   M Drug A       Ba 5.056017
    ## 145     073 60.05739   M Drug B       AA 4.948018
    ## 146     073 60.05739   M Drug B       Ba 3.246763
    ## 147     074 42.90799   F Drug B       AA 5.099328
    ## 148     074 42.90799   F Drug B       Ba 4.428150
    ## 149     075 43.11991   M Drug A       AA 4.025990
    ## 150     075 43.11991   M Drug A       Ba 4.820094
    ## 151     076 60.25571   F Drug A       AA 6.014943
    ## 152     076 60.25571   F Drug A       Ba 3.007252
    ## 153     077 47.15227   M Drug B       AA 4.572721
    ## 154     077 47.15227   M Drug B       Ba 5.116637
    ## 155     078 37.79282   M Drug A       AA 4.106792
    ## 156     078 37.79282   M Drug A       Ba 5.333903
    ## 157     079 51.81303   M Drug A       AA 5.411430
    ## 158     079 51.81303   M Drug A       Ba 4.966964
    ## 159     080 48.61109   M Drug B       AA 2.534102
    ## 160     080 48.61109   M Drug B       Ba 7.571458
    ## 161     081 50.05764   F Drug A       AA 4.794701
    ## 162     081 50.05764   F Drug A       Ba 5.651193
    ## 163     082 53.85280   F Drug B       AA 5.273766
    ## 164     082 53.85280   F Drug B       Ba 6.024673
    ## 165     083 46.29340   M Drug B       AA 5.817659
    ## 166     083 46.29340   M Drug B       Ba 4.790207
    ## 167     084 56.44377   M Drug B       AA 5.378168
    ## 168     084 56.44377   M Drug B       Ba 4.054591
    ## 169     085 47.79513   M Drug B       AA 5.856923
    ## 170     085 47.79513   M Drug B       Ba 4.538962
    ## 171     086 53.31782   F Drug B       AA 7.416773
    ## 172     086 53.31782   F Drug B       Ba 3.348951
    ## 173     087 60.96839   F Drug B       AA 4.536013
    ## 174     087 60.96839   F Drug B       Ba 5.825380
    ## 175     088 54.35181   F Drug B       AA 5.510133
    ## 176     088 54.35181   F Drug B       Ba 4.410519
    ## 177     089 46.74068   M Drug B       AA 4.003219
    ## 178     089 46.74068   M Drug B       Ba 5.144476
    ## 179     090 61.48808   F Drug A       AA 4.985693
    ## 180     090 61.48808   F Drug A       Ba 3.209719
    ## 181     091 59.93504   M Drug B       AA 5.034551
    ## 182     091 59.93504   M Drug B       Ba 5.190230
    ## 183     092 55.48397   M Drug A       AA 5.174726
    ## 184     092 55.48397   M Drug A       Ba 3.944983
    ## 185     093 52.38732   M Drug A       AA 5.476133
    ## 186     093 52.38732   M Drug A       Ba 6.378570
    ## 187     094 43.72094   M Drug A       AA 5.456236
    ## 188     094 43.72094   M Drug A       Ba 3.864412
    ## 189     095 63.60652   M Drug A       AA 4.564355
    ## 190     095 63.60652   M Drug A       Ba 5.346104
    ## 191     096 43.99740   F Drug A       AA 4.352954
    ## 192     096 43.99740   F Drug A       Ba 2.842354
    ## 193     097 71.87333   F Drug A       AA 5.884251
    ## 194     097 71.87333   F Drug A       Ba 4.170522
    ## 195     098 65.32611   F Drug A       AA 4.426440
    ## 196     098 65.32611   F Drug A       Ba 6.503901
    ## 197     099 47.64300   M Drug B       AA 4.225855
    ## 198     099 47.64300   M Drug B       Ba 5.845732
    ## 199     100 39.73579   M Drug B       AA 3.739317
    ## 200     100 39.73579   M Drug B       Ba 4.645458

``` r
plot1 <- pca_pipeline(sample_df,id="USUBJID",group="TRT01P",scale=T)
```

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(names_col)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(names_col))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(values_col)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(values_col))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(id)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(id))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

    ## Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.
    ## ℹ Please use `all_of()` or `any_of()` instead.
    ##   # Was:
    ##   data %>% select(group)
    ## 
    ##   # Now:
    ##   data %>% select(all_of(group))
    ## 
    ## See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>.
    ## This warning is displayed once every 8 hours.
    ## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
    ## generated.

``` r
plot1
```

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

``` r
plot2 <- pca_pipeline(sample_df,id="USUBJID",group="SEX",scale=T)
plot2
```

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->
