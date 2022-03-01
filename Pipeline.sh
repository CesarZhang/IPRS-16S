#!/bin/bash

for filename in 8C1.2.3 8C4.5.6 8C7.8.9 8S1.2.3 8S4.5.6 8S7.8.9 D19AU527-8ZJG1 D19AU528-8ZJG2 D19AU529-8ZJG3 D19AU530-8ZJG4 D19AU531-8ZJG5 D19AU532-8ZJG6 D19AU533-8N1 D19AU534-8N5 D19AU535-8N6; do echo $filename; flash $filename'_R1.fq.gz' $filename'_R2.fq.gz' -o $filename; done


source activate qiime2-2021.4
cd RAS_16s/

qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path RAS_16s/mainfest.tsv --output-path Seq/paired-end-demux.qza --input-format SingleEndFastqManifestPhred33V2

###https://docs.qiime2.org/2021.4/tutorials/atacama-soils/

mkdir quality-summarize
qiime demux summarize --i-data import/paired-end-demux.qza --o-visualization quality-summarize/paired-end-demux.qzv

mkdir quality-summarize/report
qiime tools export --input-path quality-summarize/paired-end-demux.qzv --output-path quality-summarize/report

mkdir dada2
qiime dada2 denoise-single --i-demultiplexed-seqs import/demux.qza --p-trunc-len 200 --o-table dada2/table.qza --o-representative-sequences dada2/rep-seqs.qza --o-denoising-stats dada2/denoising-stats.qza

##relative
qiime feature-table relative-frequency --i-table dada2/table.qza --o-relative-frequency-table dada2/Relative-table.qza

export TMPDIR=/home/repldba/tempfiles/


###taxonomy
mkdir taxonomy
qiime feature-classifier classify-sklearn --i-classifier ../SILVA138/silva-138-99-nb-classifier.qza --i-reads dada2/rep-seqs.qza --o-classification taxonomy/taxonomy.qza --p-reads-per-batch 500 --p-n-jobs 1

for i in 2 3 4 5 6 7; do qiime taxa collapse --i-table dada2/table.qza --i-taxonomy taxonomy/taxonomy.qza --p-level $i --o-collapsed-table taxonomy/taxonomy.L$i.qza; done

mkdir taxonomy/Relative
for i in 2 3 4 5 6 7; do qiime feature-table relative-frequency --i-table taxonomy/taxonomy.L$i.qza --o-relative-frequency-table taxonomy/Relative/taxonomy.L$i.qza; done

mkdir alpha
##rarefy
qiime feature-table rarefy --i-table dada2/table.qza --p-sampling-depth 23140 --o-rarefied-table alpha/rare.table.qza

for i in shannon ace chao1 simpson observed_features
 do
 qiime diversity alpha --i-table alpha/rare.table.qza --p-metric $i --o-alpha-diversity alpha/$i.qza
 done
#make tree 
mkdir tree
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences dada2/rep-seqs.qza --o-alignment tree/aligned-rep-seqs.qza --o-masked-alignment tree/masked-aligned-rep-seqs.qza --o-tree tree/unrooted-tree.qza --o-rooted-tree tree/rooted-tree.qza

qiime diversity alpha-phylogenetic --i-table alpha/rare.table.qza --i-phylogeny tree/rooted-tree.qza --p-metric faith_pd --o-alpha-diversity alpha/faith_pd.qza

mkdir beta
for i in jaccard braycurtis; do qiime diversity beta --i-table alpha/rare.table.qza --p-metric $i --o-distance-matrix beta/$i.qza; done
for i in unweighted_unifrac weighted_unifrac; do qiime diversity beta-phylogenetic --i-table alpha/rare.table.qza --i-phylogeny tree/rooted-tree.qza --p-metric $i --o-distance-matrix beta/$i.qza; done

########Export result
qiime tools export --input-path dada2/table.qza --output-path dada2/table
qiime tools export --input-path dada2/Relative-table.qza --output-path dada2/Relative-table

for i in ace chao1 faith_pd observed_features shannon simpson; do qiime tools export --input-path alpha/$i.qza --output-path alpha/$i; done

for i in braycurtis jaccard unweighted_unifrac weighted_unifrac; do qiime tools export --input-path beta/$i.qza --output-path beta/$i; done

for i in rooted unrooted; do qiime tools export --input-path tree/$i-tree.qza --output-path tree/$i; done

for i in 2 3 4 5 6 7; do qiime tools export --input-path taxonomy/Relative/taxonomy.L$i.qza --output-path taxonomy/Relative/L$i; done

qiime tools export --input-path taxonomy/taxonomy.qza --output-path taxonomy/taxonomy

qiime tools export --input-path dada2/rep-seqs.qza --output-path dad2/rep-seqs
###biom convert and merge taxonomy
#convert
mkdir taxonomy/Relative/Result
for i in 2 3 4 5 6 7; do biom convert -i taxonomy/Relative/L$i/feature-table.biom -o taxonomy/Relative/Result/L$i.tsv --to-tsv; done

biom convert -i dada2/table/feature-table.biom -o dada2/table/table.tsv --to-tsv
biom convert -i dada2/Relative-table/feature-table.biom -o dada2/Relative-table/Relative-table.tsv --to-tsv

#merge taxonomy
biom add-metadata -i dada2/table/feature-table.biom --observation-metadata-fp taxonomy/taxonomy/taxonomy.tsv -o dada2/table/table.tax.biom --sc-separated taxonomy --observation-header OTU_ID,taxonomy

biom convert -i dada2/table/table.tax.biom -o dada2/table/table.tax.tsv --to-tsv  --header-key taxonomy

biom add-metadata -i dada2/Relative-table/feature-table.biom --observation-metadata-fp taxonomy/taxonomy/taxonomy.tsv -o dada2/Relative-table/Relative-table.tax.biom --sc-separated taxonomy --observation-header OTU_ID,taxonomy

biom convert -i dada2/Relative-table/Relative-table.tax.biom -o dada2/Relative-table/Relative-table.tax.tsv --to-tsv  --header-key taxonomy


