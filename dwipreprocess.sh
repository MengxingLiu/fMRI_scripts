#!/bin/sh

# create /sourcedata /rawdata under the project directory
# put subject dicom data in /sourcedata

cd rawdata
mkdir sub-02
cd sub-02
mrconvert ../../sourcedata/sub02/DWI/diff_cmrr*64/ sub-02_dwi.mif
mrconvert ../../sourcedata/sub02/DWI/diff_cmrr*SBRef_63/ sub-02_SBRef.mif
mrconvert ../../sourcedata/sub02/DWI/diff_cmrr*b0*62/ sub-02_b0.mif
mrconvert ../../sourcedata/sub02/DWI/diff_cmrr*b0*61/ sub-02_b0SBRef.mif

## Dilated brain mask can offer a significant speed improvement
dwi2mask ../raw/dwi.mif - | maskfilter - dilate preproc_mask.mif -npass 5
dwidenoise ../raw/dwi.mif denoise.mif -noise noiselevel.mif -mask preproc_mask.mif

# Gibbs ringing correction
mrdegibbs denoise.mif degibbs.mif

## pair b0 AP and PA
dwiextract -bzero sub-02_dwi.mif - | mrmath - -axis 3 mean sub-02_b0_AP.mif
mrcat sub-02_b0.mif sub-02_b0_AP.mif b0_pair.mif
## Motion & distortion correction
dwifslpreproc degibbs.mif geomcorr.mif -pe_dir AP -rpe_pair -se_epi b0pair.mif

## B1 bias field correction, strategy ANTs fits smooth bias fiield that maximizes frequency content
dwibiascorrect ants geomcorr.mif biascorr.mif -bias biasfield.mif 

##brain mask to speed up subsequent analysis
dwi2mask sub-02_dwi.mif mask.mif

## Multi-model registration, FSL flirt
mrconvert ../../sourcedata/sub02/anat/t1*/ T1w.nii.gz
mrconvert sub-02_b0_AP.mif sub-02_b0_AP.nii.gz
flirt -dof 6 -cost normmi -in raw/T1w -ref sub-02_b0_AP.mif -omat T_fsl.txt
transformconvert T_fsl.txt T1w.nii.gz sub-02_b0_AP.nii.gz flirt_import T_T1toDWI.txt
mrtransform -linear T_T1toDWI.txt T1w.nii.gz aT1w.nii.gz

## WM and CSF response function estimation
dwi2response dhollander biascorr.mif response_wm.txt response_gm.txt response_csf.txt

## fibre orientation distribution (fod) estimation

dwi2fod msmt_csd biascorr.mif response_wm.txt wmfod.mif response_csf.txt csf.mif -mask mask.mif

## intensity normalisation and bias field corretion
mtnormalise wmfod.mif wmfod_norm.mif csf.mif csf_morm.mif -mask mask.mif 









