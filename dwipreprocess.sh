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



