#!/bin/sh

if [[ "$#" -lt 2 ]]; then
  echo "Usage: ./wfmash.sh qry.fa ref.fa"
  echo "Align qry.fa to ref.fa"
  echo "using wfmash --no-split -ad --one-to-one -s100000 -p95"
  echo "Output: qry_to_ref.bam, qry_to_ref.paf"
  exit 0
fi
cpu=$SLURM_CPUS_PER_TASK
if [[ -z $cpu ]]; then
  cpu=12
fi

qry_fa=$1
ref_fa=$2

ln -s $qry_fa
ln -s $ref_fa

if [[ -s $qry_fa.fai ]]; then
  ln -s $qry_fa.fai
fi
if [[ -s $ref_fa.fai ]]; then
  ln -s $ref_fa.fai
fi

qry_fa=`basename $qry_fa`
ref_fa=`basename $ref_fa`

module load samtools
set -x
if [[ ! -s $qry_fa.fai ]]; then
  samtools faidx $qry_fa
fi

if [[ ! -s $ref_fa.fai ]]; then
  samtools faidx $ref_fa
fi
set +x

qry=`echo $qry_fa | sed 's/\.gz$//g' | sed 's/\.fasta$//g' | sed 's/\.fa$//g'`
ref=`echo $ref_fa | sed 's/\.gz$//g' | sed 's/\.fasta$//g' | sed 's/\.fa$//g'`

out=${qry}_to_${ref}
echo "Output prefix: $out"

# Run with 100g mem (used ~82g) for aligning a diploid genome to a diploid ref
# Run per-haplotype
module load wfmash
set -e
set -x

wfmash --no-split -d --one-to-one -s100000 -p95 -t$cpu $ref_fa $qry_fa > $out.paf

# Print col 1-12 + %idy %qry_cov %ref_cov
cat $out.paf | cut -f1-12 - | awk '{print $0"\t"(100*$10/$11)"\t"(100*($4-$3)/$2)"\t"(100*($9-$8)/$7)}' | sort -k15,15nr > $out.wfmash