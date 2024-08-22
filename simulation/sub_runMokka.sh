#!/bin/bash

CurrPATH="$PWD"
WorkPATH=$CurrPATH
MarlinPATH=/cefs/higgs/PFAData/Software/Arbor/Arbor_Baseline
# -----------------------------------------------------------
GeoType="Baseline"
# -----------------------------------------------------------
NEvt=10
# NEvt=5  # for test
#--------------------------------------------------------------



pars=("bb")
ipar=0
while [ "$ipar" -lt "1" ]
do
par=${pars[$ipar]}


EventName="nnH1000w"
#--------------------------------------------------------------
OutputPATH=$WorkPATH/${EventName}/Simu/${Radiu}/${par}
jobPATH=$OutputPATH/job
if [ ! -d "$jobPATH" ]
then
mkdir -p $jobPATH
fi

jobID=0
#--------------------------------------------------------------
iFile=0
nFile=1
while [ "$iFile" -le "$nFile" ]
do
FileID=`printf "%04d" ${iFile}`
#--------------------------------------------------------------
iStartEvtNo=0
# nStartEvtNo=1  # for test
nStartEvtNo=9  # E240_nnH_gg, (total 1e5 evts/stdhep) / (200 evts/file in simu) = 500 parts
while [ "$iStartEvtNo" -le "$nStartEvtNo" ]
do
StartEvtNo=`echo "scale=0; ${iStartEvtNo}*${NEvt}/1" | bc`
echo "StartEvtNo = $StartEvtNo"
#--------------------------------------------------------------
SampleTex=Simu_${GeoType}_${EventName}_${par}_${nStartEvtNo}
SampleName=${jobID}
jobName=${SampleTex}_${jobID}

GearFile=$OutputPATH/GearOutput.xml
SimuFile=$OutputPATH/${SampleName}.slcio
EvtMacro=$jobPATH/${jobName}_Evt.macro
GeoMacro=$jobPATH/${jobName}_Geo.macro
shFile=$jobPATH/${jobName}.sh
outFile=$jobPATH/${jobName}.out
errFile=$jobPATH/${jobName}.err
# logFile=$jobPATH/${jobName}.log
# cmdFile=$jobPATH/${jobName}.cmd


inputfile=/afs/ihep.ac.cn/users/z/zhuyf/cefs/workspace/whizard360/WhizardAis/data/higgs/E240.Pn2n2h_${par}.e0.p0.whizard195/n2n2h_${par}.e0.p0.${FileID}.stdhep

echo $inputfile

if [ -f "$inputfile" ]; then
let jobID+=1
echo ${inputfile}
fi

# Event.macro---------------------------------------------
echo \
"
# E240_nnH_gg: (1e5 evts/stdhep) * 110 files = 1.1e7 evts in total
/generator/generator    ${inputfile}
#/cefs/data/stdhep/CEPC240/higgs/Higgs_10M/data/E240.Pnnh_gg.e0.p0.whizard195/nnh_gg.e0.p0.${FileID}.stdhep

/run/beamOn ${NEvt}
exit
" > ${EvtMacro}

# Geometry.macro------------------------------------------
echo \
"
/Mokka/init/startEventNumber ${StartEvtNo}
/Mokka/init/BatchMode true
/Mokka/init/printLevel 0
/Mokka/init/dbHost 202.122.33.73
/Mokka/init/user consult
/Mokka/init/dbPasswd consult

/Mokka/init/randomSeed ${iFile}

/Mokka/init/detectorModel CEPC_v4
/Mokka/init/EditGeometry/rmSubDetector ftd_cepc_v4
/Mokka/init/EditGeometry/newSubDetector SiTracker01 1

/Mokka/init/globalModelParameter SiTrackerEndcap FTD_PIXEL,29.5,151.9,220,16;FTD_PIXEL,30.54,151.9,371,16;FTD_STRIP,32.5,299,645,16;FTD_STRIP,34,309,846,16;FTD_STRIP,35.5,309,925,16
/Mokka/init/globalModelParameter SiTrackerLayerStructure FTD_PIXEL,Si:-0.02,CarbonFiber:1;FTD_STRIP,Si:-0.2,CarbonFiber:2,Si:-0.2

/Mokka/init/lcioFilename      ${SimuFile}
/Mokka/init/initialMacroFile  ${EvtMacro}
/Mokka/init/MokkaGearFileName ${GearFile}

/Mokka/init/lcioDetailedShowerMode true
/Mokka/init/userInitBool WriteCompleteHepEvt true
/Mokka/init/lcioWriteMode WRITE_NEW
/Mokka/init/lcioStoreCalHitPosition true
/Mokka/init/lcioDetailedTRKHitMode TPCCollection

# exit
" > ${GeoMacro}

#ShellScript.sh------------------------------------------
echo \
"
source /cvmfs/cepc.ihep.ac.cn/software/cepcenv/setup.sh
cepcenv -r /cvmfs/cepc.ihep.ac.cn/software/cepcsoft use 0.1.1
#source /afs/ihep.ac.cn/users/z/zhuyf/cefs/workspace/Mokka/0.1.3/setup_cepcenv.sh

Mokka -U ${GeoMacro}
" > ${shFile}

chmod +x  ${shFile}
#-------------------- run *.sh file -----------------------------
# . ${shFile}
#-------------------- or hep_sub single *.sh --------------------
# hep_sub ${shFile} -g higgs -o ${outFile} -e ${errFile}
# -------------------------


let "iStartEvtNo+=1"
done

let "iFile+=1"
done


# --- or hep_sub in batch mode ------------------------------------------------------>
NSubJob=$jobID
echo "Total $NSubJob files will be hep_sub."

jobBatchName=$jobPATH/${SampleTex}_"%{ProcId}"

# export PATH=/afs/ihep.ac.cn/soft/common/sysgroup/hep_job/bin:$PATH
hep_sub -os CentOS7  ${jobBatchName}.sh -g higgs -o ${jobBatchName}.out -e ${jobBatchName}.err -n $NSubJob
# hep_sub -wt test ${jobBatchName}.sh -g higgs -o ${jobBatchName}.out -e ${jobBatchName}.err -n $NSubJob
# --------------------------------------------------------------------------------
## Note: -wt default(10h)/test(5min)/short(30min)/mid(100h)/long(720h)
# --------------------------------------------------------------------------------
let "ipar+=1"
done

