#!/bin/bash

# DIPY-B0: For visualization and ROI-building
# FSL-FA vs DIPY-FA: Between-software convergence
# FSL-MD vs DIPY-MD: Between-software convergence
# AMICO_NODDI-FW vs DIPY FW: Between-software convergence
# DIPY-FA vs DIPY-FAc: Effect of correction

usage (){

	cat <<USAGE
	
	Usage: 
	
	`basename $0` -m -i -n
	
	Description: 

	Assemble DWI MODALITYs through various stages of 
	by-group/by-session merging and subtraction

	Compulsory arguments: 
	
	-m: Modality <dipy_b0, dipy_FW, amico_noddi, pasternak_fw>
	
	-i: Image type <see below for options per modality>
			dipy_b0: dipy-b0mean
			dipy_fw: dipy-FW, dipy-FA, dipy-FAc, dipy-MD, dipy-MDc, fsl_FA, fsl_MD
			amico_noddi: FIT_ISOVF, FIT_ICVF, FIT_OD
			pasternak_fw: FW, dcmp_FA, dcmp_MD
	
	-n: Normalization type <n1, n2>

USAGE

	exit 1

}

# Provide help
[ "$1" == "" ] && usage >&2
[ "$1" == "-h" ] && usage >&2
[ "$1" == "--help" ] && usage >&2

# Get command-line options
while getopts ":m:i:n:" OPT; do

	case "${OPT}" in 
		m)
			echo ">>> -m ${OPTARG}"
			optM=${OPTARG}
		;;
		i)
			echo ">>> -i ${OPTARG}"
			optI=${OPTARG}
		;;
		n)
			echo ">>> -n ${OPTARG}"
			optN=${OPTARG}
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
MODALITY=${optM}
IMG=${optI}
NORM=${optN}
DIR=/project/3024006.02/Analyses/MJF_FreeWater/data/${NORM}_${MODALITY}
mkdir -p ${DIR}
cd ${DIR}
rm ./${IMG}*

if [[ ${MODALITY} == "amico_noddi" && ${IMG} == "FIT_ISOVF" ]] || [[ ${MODALITY} == "amico_noddi" && ${IMG} == "FIT_OD" ]] || [[ ${MODALITY} == "amico_noddi" && ${IMG} == "FIT_ICVF" ]] || [[ ${MODALITY} == "dipy_b0" && ${IMG} == "dipy-b0mean" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "dipy-FW" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "dipy-FA" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "dipy-FAc" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "dipy-MD" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "dipy-MDc" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "fsl_FA" ]] || [[ ${MODALITY} == "dipy_fw" && ${IMG} == "fsl_MD" ]] || [[ ${MODALITY} == "pasternak_fw" && ${IMG} == "FW" ]] || [[ ${MODALITY}=="pasternak_fw" && ${IMG}=="dcmp_FA" ]]|| [[ ${MODALITY}=="pasternak_fw" && ${IMG}=="dcmp_MD" ]]; then 
	echo ">>> IMG type compatible with modality"
else
  echo ">>> Error: IMG type not compatible with modality"
  usage >&2
fi

if [[ ${NORM} == "n1" || ${NORM} == "n2" ]]; then
	echo ">>> Normalization type correctly specified"
else
	echo ">>> Error: Incorrect normalization type specified"
fi

# Img search pattern differs by img type
if [ ${MODALITY} == "amico_noddi" ]; then
	SPTN="${NORM}_${IMG}.nii.gz"
else
	SPTN="${NORM}_sub-*_${IMG}.nii.gz"
fi

# PIT

i_PIT1=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-PITVisit1/metrics/${MODALITY}/${SPTN}` )
# PIT1=${i_PIT1[@]:0:50}
PIT1=${i_PIT1[@]}
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_PIT1 ${PIT1}
${FSLDIR}/bin/fslmaths ${IMG}_norm_PIT1 -Tmean ${IMG}_norm_avg_PIT1

i_PIT2=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-PITVisit2/metrics/${MODALITY}/${SPTN}` )
# PIT2=${i_PIT2[@]:0:50}
PIT2=${i_PIT2[@]}
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_PIT2 ${PIT2}
${FSLDIR}/bin/fslmaths ${IMG}_norm_PIT2 -Tmean ${IMG}_norm_avg_PIT2

# ${FSLDIR}/bin/fslmaths ${IMG}_norm_PIT2 -sub ${IMG}_norm_PIT1 ${IMG}_norm_PIT2subPIT1
${FSLDIR}/bin/fslmaths ${IMG}_norm_avg_PIT2 -sub ${IMG}_norm_avg_PIT1 ${IMG}_norm_avg_PIT2subPIT1

# ${FSLDIR}/bin/fslmerge -t ${IMG}_norm_PIT `echo "${PIT1} ${PIT2}"`
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_PIT ${IMG}_norm_PIT1 ${IMG}_norm_PIT2
# ${FSLDIR}/bin/fslmaths ${IMG}_norm_PIT -Tmean ${IMG}_norm_avg_PIT

printf '%s\n' ${PIT1} > ${DIR}/${IMG}_list_PIT1.txt
printf '%s\n' ${PIT2} > ${DIR}/${IMG}_list_PIT2.txt
cat ${DIR}/${IMG}_list_PIT1.txt > ${DIR}/${IMG}_list_PIT.txt; cat ${DIR}/${IMG}_list_PIT2.txt >> ${DIR}/${IMG}_list_PIT.txt

# POM

i_POM1=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-POMVisit1/metrics/${MODALITY}/${SPTN}` )
# POM1=${i_POM1[@]:0:50}
POM1=${i_POM1[@]}
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_POM1 ${POM1}
${FSLDIR}/bin/fslmaths ${IMG}_norm_POM1 -Tmean ${IMG}_norm_avg_POM1

i_POM3=( `ls /project/3022026.01/pep/bids/derivatives/qsiprep/sub-*/ses-POMVisit3/metrics/${MODALITY}/${SPTN}` )
# POM3=${i_POM3[@]:0:50}
POM3=${i_POM3[@]}
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_POM3 ${POM3}
${FSLDIR}/bin/fslmaths ${IMG}_norm_POM3 -Tmean ${IMG}_norm_avg_POM3

# ${FSLDIR}/bin/fslmaths ${IMG}_norm_POM3 -sub ${IMG}_norm_POM1 ${IMG}_norm_POM3subPOM1
${FSLDIR}/bin/fslmaths ${IMG}_norm_avg_POM3 -sub ${IMG}_norm_avg_POM1 ${IMG}_norm_avg_POM3subPOM1

# ${FSLDIR}/bin/fslmerge -t ${IMG}_norm_POM `echo "${POM1} ${POM3}"`
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_POM ${IMG}_norm_POM1 ${IMG}_norm_POM3
# ${FSLDIR}/bin/fslmaths ${IMG}_norm_POM -Tmean ${IMG}_norm_avg_POM

printf '%s\n' ${POM1} > ${DIR}/${IMG}_list_POM1.txt
printf '%s\n' ${POM3} > ${DIR}/${IMG}_list_POM3.txt
cat ${DIR}/${IMG}_list_POM1.txt > ${DIR}/${IMG}_list_POM.txt; cat ${DIR}/${IMG}_list_POM3.txt >> ${DIR}/${IMG}_list_POM.txt

# ALL
# ${FSLDIR}/bin/fslmerge -t ${IMG}_norm_ALL `echo "${PIT1} ${PIT2} ${POM1} ${POM3}"`
${FSLDIR}/bin/fslmerge -t ${IMG}_norm_ALL ${IMG}_norm_PIT ${IMG}_norm_POM
${FSLDIR}/bin/fslmaths ${IMG}_norm_ALL -Tmean ${IMG}_norm_avg_ALL
cat ${DIR}/${IMG}_list_PIT.txt > ${DIR}/${IMG}_list_ALL.txt; cat ${DIR}/${IMG}_list_POM.txt >> ${DIR}/${IMG}_list_ALL.txt



