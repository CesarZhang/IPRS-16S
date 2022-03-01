#!/bin/bash

source activate qiime2-2021.4

cd RAS_16s/2/SourceTrack

###filter table and seqs

qiime feature-table filter-samples \
  --i-table ../dada2/table.qza \
  --m-metadata-file sample-metadata.csv \
  --o-filtered-table filtered-table.qza
  
qiime tools export --input-path filtered-table.qza --output-path table

conda activate st2

sourcetracker2 gibbs -i dada2/table/table.tax.biom -m SourceTrack2/str-map.txt -o SourceTrack2/str


