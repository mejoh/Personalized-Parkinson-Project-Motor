#!/bin/bash

usage (){

	cat <<USAGE
	
	Usage: 
	
	`basename $0` -d -i -m
	
	Description: 

	Extract summary statistics from regions-of-interest

	Compulsory arguments: 
	
	-d: Data directory (output of assemble_images.sh)
	
	-i: Image type
	
	-m: Index mask

USAGE

	exit 1

}

# Provide help
[ "$1" == "" ] && usage >&2
[ "$1" == "-h" ] && usage >&2
[ "$1" == "--help" ] && usage >&2

# Get command-line options
while getopts ":d:i:m:" OPT; do

	case "${OPT}" in 
		d)
			echo ">>> -d ${OPTARG}"
			optD=${OPTARG}
		;;
		i)
			echo ">>> -i ${OPTARG}"
			optI=${OPTARG}
		;;
		m)
			echo ">>> -m ${OPTARG}"
			optM=${OPTARG}
		;;
		\?)
			echo ">>> Error: Invalid option -${OPTARG}."
			usage >&2
		;;
		:)
			echo ">>>> Error: Option -${OPTARG} requires an argument."
			usage >&2
		;;
	esac

done

# Set up environment
export FSLDIR=/opt/fsl/6.0.5
.  ${FSLDIR}/etc/fslconf/fsl.sh
DATADIR=${optD}
IMG=${optI}
MASK=${optM}
mkdir -p ${DATADIR}/wd_${IMG}
cd ${DATADIR}/wd_${IMG}
rm $(pwd)/*

# Bilateral masks
${FSLDIR}/bin/fslmaths ${MASK} -thr 1 -uthr 2 -bin bi_aSN
${FSLDIR}/bin/fslmaths ${MASK} -thr 3 -uthr 4 -bin bi_pSN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 5 -uthr 6 -bin bi_STN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 7 -uthr 8 -bin bi_RN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 9 -uthr 10 -bin bi_PPN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 11 -uthr 12 -bin bi_SCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 13 -uthr 14 -bin bi_MCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 16 -uthr 17 -bin bi_Dent
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 18 -uthr 19 -bin bi_LobV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 20 -uthr 21 -bin bi_LobIV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 22 -uthr 23 -bin bi_RRA
# Unilateral masks
${FSLDIR}/bin/fslmaths ${MASK} -thr 1 -uthr 1 -bin R_aSN
${FSLDIR}/bin/fslmaths ${MASK} -thr 2 -uthr 2 -bin L_aSN
${FSLDIR}/bin/fslmaths ${MASK} -thr 3 -uthr 3 -bin R_pSN
${FSLDIR}/bin/fslmaths ${MASK} -thr 4 -uthr 4 -bin L_pSN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 5 -uthr 5 -bin R_STN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 6 -uthr 6 -bin L_STN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 7 -uthr 7 -bin R_RN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 8 -uthr 8 -bin L_RN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 9 -uthr 9 -bin R_PPN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 10 -uthr 10 -bin L_PPN
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 11 -uthr 11 -bin R_SCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 12 -uthr 12 -bin L_SCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 13 -uthr 13 -bin R_MCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 14 -uthr 14 -bin L_MCP
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 15 -uthr 15 -bin InfVerm
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 16 -uthr 16 -bin R_Dent
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 17 -uthr 17 -bin L_Dent
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 18 -uthr 18 -bin R_LobV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 19 -uthr 19 -bin L_LobV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 20 -uthr 20 -bin R_LobIV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 21 -uthr 21 -bin L_LobIV
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 22 -uthr 22 -bin R_RRA
# ${FSLDIR}/bin/fslmaths ${MASK} -thr 23 -uthr 23 -bin L_RRA

# MASKLIST=(bi_aSN bi_pSN bi_STN bi_RN bi_PPN bi_SCP bi_MCP bi_Dent bi_LobV bi_LobIV bi_RRA R_aSN L_aSN R_pSN L_pSN R_STN L_STN R_RN L_RN R_PPN L_PPN R_SCP L_SCP R_MCP L_MCP InfVerm R_Dent L_Dent R_LobV L_LobV R_LobIV L_LobIV R_RRA L_RRA)
MASKLIST=(bi_aSN bi_pSN R_aSN L_aSN R_pSN L_pSN)

# Extract stats for each mask
for m in ${MASKLIST[@]}; do

	echo ">>> MASK: ${m}"
	# Extract stats
	${FSLDIR}/bin/fslstats -t ${DATADIR}/${IMG}_norm_ALL.nii.gz -k ${m}.nii.gz -m | tr -d "[:blank:]" > avg_${m}.txt
	${FSLDIR}/bin/fslstats -t ${DATADIR}/${IMG}_norm_ALL.nii.gz -k ${m}.nii.gz -s | tr -d "[:blank:]" > sd_${m}.txt
	echo ">>> done"

done

# Combine to single file
for i in avg sd; do

  # echo "IMG,aSN_${i},pSN_${i},STN_${i},RN_${i},PPN_${i},SCP_${i},MCP_${i},InfVerm_${i},Dentate_${i},LobV_${i},LobIV_${i},RRA_${i},R_aSN_${i},L_aSN_${i},R_pSN_${i},L_pSN_${i},R_STN_${i},L_STN_${i},R_RN_${i},L_RN_${i},R_PPN_${i},L_PPN_${i},R_SCP_${i},L_SCP_${i},R_MCP_${i},L_MCP_${i},R_Dent_${i},L_Dent_${i},R_LobV_${i},L_LobV_${i},R_LobIV_${i},L_LobIV_${i},R_RRA_${i},L_RRA_${i}" > ${DATADIR}/${IMG}_stats_${i}.csv
  # paste -d , ../${IMG}_list_ALL.txt ${i}_bi_aSN.txt ${i}_bi_pSN.txt ${i}_bi_STN.txt ${i}_bi_RN.txt ${i}_bi_PPN.txt ${i}_bi_SCP.txt ${i}_bi_MCP.txt ${i}_InfVerm.txt ${i}_bi_Dent.txt ${i}_bi_LobV.txt ${i}_bi_LobIV.txt ${i}_bi_RRA.txt ${i}_R_aSN.txt ${i}_L_aSN.txt ${i}_R_pSN.txt ${i}_L_pSN.txt ${i}_R_STN.txt ${i}_L_STN.txt ${i}_R_RN.txt ${i}_L_RN.txt ${i}_R_PPN.txt ${i}_L_PPN.txt ${i}_R_SCP.txt ${i}_L_SCP.txt ${i}_R_MCP.txt ${i}_L_MCP.txt ${i}_R_Dent.txt ${i}_L_Dent.txt ${i}_R_LobV.txt ${i}_L_LobV.txt ${i}_R_LobIV.txt ${i}_L_LobIV.txt ${i}_R_RRA.txt ${i}_L_RRA.txt >> ${DATADIR}/${IMG}_stats_${i}.csv
	
	# echo "IMG,aSN_${i},pSN_${i},RRA_${i},R_aSN_${i},L_aSN_${i},R_pSN_${i},L_pSN_${i},R_RRA_${i},L_RRA_${i}" > ${DATADIR}/${IMG}_stats_${i}.csv
  # paste -d , ../${IMG}_list_ALL.txt ${i}_bi_aSN.txt ${i}_bi_pSN.txt ${i}_bi_RRA.txt ${i}_R_aSN.txt ${i}_L_aSN.txt ${i}_R_pSN.txt ${i}_L_pSN.txt ${i}_R_RRA.txt ${i}_L_RRA.txt >> ${DATADIR}/${IMG}_stats_${i}.csv
	
	echo "IMG,aSN_${i},pSN_${i},R_aSN_${i},L_aSN_${i},R_pSN_${i},L_pSN_${i}" > ${DATADIR}/${IMG}_stats_${i}.csv
  paste -d , ../${IMG}_list_ALL.txt ${i}_bi_aSN.txt ${i}_bi_pSN.txt ${i}_R_aSN.txt ${i}_L_aSN.txt ${i}_R_pSN.txt ${i}_L_pSN.txt >> ${DATADIR}/${IMG}_stats_${i}.csv

done

#rm -r wd_${IMG}





