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
dwifslpreproc degibbs.mif geomcorr.mif -pe_dir AP -rpe_pair -se_epi
b0pair.mif


