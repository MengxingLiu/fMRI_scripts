#!/bin/sh

# create /sourcedata /rawdata under the project directory
# put subject dicom data in /sourcedata

cd rawdata
mkdir sub-02
cd sub-02
mrconvert ../../sourcedata/sub02/DWI/diff_cmrr*64/ sub-02.mif

