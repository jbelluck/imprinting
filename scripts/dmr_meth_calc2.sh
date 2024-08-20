#!/bin/bash

# this script reports the average maternal methylation, paternal methylation, and difference for each of the 196 (of the 200 that lifted over to CHM13) DMRs reported in Akbari et al. 2022

# load in the file with Akbari's DMRs (in CHM13 coordinates)
AKBARI_DMRS="/data/Phillippy2/projects/belluck_dmr/dmr_files/dmrs_20.bed"
echo $AKBARI_DMRS

# create a maternal and a paternal file to store the CpG sites, named for the haplotype
mat_file="/data/Phillippy2/projects/belluck_dmr/dmr_files/mat_sites_temp.bed"
pat_file="/data/Phillippy2/projects/belluck_dmr/dmr_files/pat_sites_temp.bed"

# create a maternal and paternal file to store the average methylation at each CpG site
mat_avg_file="/data/Phillippy2/projects/belluck_dmr/dmr_files/mat_sites_temp_avg.bed"
pat_avg_file="/data/Phillippy2/projects/belluck_dmr/dmr_files/pat_sites_temp_avg.bed"
touch $mat_avg_file
touch $pat_avg_file

# create a file to store the average methylation for each DMR
dmr_avg_file="/data/Phillippy2/projects/belluck_dmr/dmr_files/avg_methylation_Belluck_DMRs_chm13v2.bed"
touch $dmr_avg_file

echo "Reading each DMR..."
# loop through each row:
while IFS=$'\t' read -r chr lower upper rest; do

	# find the directory that corresponds to the chromosome of interest
	echo $chr
	CHR_DIR="/data/Phillippy2/projects/belluck_dmr/v3_bedmethyls/chr_split/$chr"
	echo $CHR_DIR

	# find the upper and lower bounds of the DMR
	echo $lower
	echo $upper

	echo "Looping through each maternal and paternal bed file"
	# loop through each maternal and paternal bed file for that chromosome
	for hap in "mat" "pat"; do
		echo $hap		

		# define the output files
		cpg_var="${hap}_file"
		cpg_path="${!cpg_var}"
		avg_site_var="${hap}_avg_file"
		avg_site_path="${!avg_site_var}"

		for bed_file in "$CHR_DIR"/*.bed; do

			filename=$(basename "$bed_file")

			file_hap=${filename:8:3}

			if [ "$file_hap" = "$hap" ]; then

				# using the upper and lower bounds, print all the CpGs within that boundary to the appropriate haplotype file
				awk -v lower="$lower" -v upper="$upper" -F'\t' '$2 >= lower && $2 <= upper' "$bed_file" >> "$cpg_path"
			fi
		done

		# now, each hap file should have a list of CpG sites (with duplicates) and the counts for each
		
		echo "calculating average at every site in the region"
		# calculate the average methylation at each site
		# filter to a specific site, total the 3rd column (reads) and the 4th column (methylated reads), and divide
		# report the average methylation at the site to a file
		# now, should have a file with each site and the average methylation
		awk '
		BEGIN {
    		# Print header for output
    		print "site\tread_sum\tmeth_sum\tavg"
		}
		{
    		# Sum column 3 and column 4 based on column 2 (site)
    		read_sum[$2] += $3
    		meth_sum[$2] += $4
		}
		END {
    		# Process each unique site
    		for (site in read_sum) {
        		# Calculate the average number of methylated reads per total reads
        		avg = (read_sum[site] == 0) ? 0 : (meth_sum[site] / read_sum[site])
        		# Print the results
        		print site "\t" read_sum[site] "\t" meth_sum[site] "\t" avg
    			}
		}
		' "$cpg_path" > "$avg_site_path"

	done

	echo "calculating average methylation over the region"
	# calculate the average methylation over the region, and report it to a file with Akbari location, mat/pat, average methylation
        average_mat=$(awk 'NR > 1 { sum += $4; count++ } END { if (count > 0) print sum / count; else print "No data" }' "$mat_avg_file")
        average_pat=$(awk 'NR > 1 { sum += $4; count++ } END { if (count > 0) print sum / count; else print "No data" }' "$pat_avg_file")
	echo $average_mat
	echo $average_pat
	num_cpg_mat=$(awk 'NR > 1 {count++} END {print count}' $mat_avg_file)
	num_cpg_pat=$(awk 'NR > 1 {count++} END {print count}' $pat_avg_file)
	echo -e "$chr\t$lower\t$upper\t$rest\t$average_mat\t$average_pat\t$num_cpg_mat\t$num_cpg_pat" >> "$dmr_avg_file"

	> "$mat_file"
	> "$pat_file"
	> "$mat_avg_file"
	> "$pat_avg_file"

	echo "done with DMR"

# now, should have a file with 200 rows, each with a column for [our] average maternal, average paternal, and difference

done < "$AKBARI_DMRS"

