#!/bin/bash

path=`pwd`
cd $path

pars=("bb")

ipar=0
while [ "$ipar" -lt "1" ]
do
par=${pars[$ipar]}


export RecoWorkDir=$path/nnH1000w

export OUTPUTDATA=${par}
mkdir -p $RecoWorkDir/$OUTPUTDATA/
echo $RecoWorkDir/$OUTPUTDATA
outNumSlcio=`ls ${RecoWorkDir}/$OUTPUTDATA/*.slcio |wc -l`
outnumSlcio=$((10#${outNumSlcio}))


export InputFilesDir=/afs/ihep.ac.cn/users/z/zhuyf/cefs/workspace/simuYuexin/nnH1000w/Simu/1.0/${par}


inNumSlcio=`ls ${InputFilesDir}/*.slcio |wc -l`
innumSlcio=$((10#${inNumSlcio}))


outjob=${outnumSlcio}

ijob=0
while [ "$ijob" -lt "${innumSlcio}" ]
do
job=$ijob

echo $outjob

for file in ${InputFilesDir}/${job}.slcio
do
	InputFiles_stdhep=${file}
    GEARFILE=/afs/ihep.ac.cn/users/z/zhuyf/cefs/workspace/simuYuexin/nnH_supply/Simu/1.0/${par}/GearOutput.xml

	if [ -f "$InputFiles_stdhep" ]; then
        echo $InputFiles_stdhep
        echo "input file exist"

	ojob=$outjob

	while [ -f "$RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh" ]
	do
	let "outjob+=1"
        ojob=$outjob
	done

	if [ ! -f "$RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh" ]; then
        echo "create slcio file"
	OUTPUT_slcio=$RecoWorkDir/$OUTPUTDATA/${ojob}.slcio
	echo $OUTPUT_slcio

	rm -f $OUTPUT_slcio
	rm -f ${OUTPUTROOT}

	cp -fr recoOld.xml $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.xml


	sed -i "s#YYYYY1#$InputFiles_stdhep#g" $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.xml
	sed -i "s#YYYYY2#$OUTPUT_slcio#g" $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.xml
	sed -i "s#GEARFILE#$GEARFILE#g" $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.xml

	echo \
	"#! /bin/bash
	


	unset MARLIN_DLL
	source /cvmfs/cepc.ihep.ac.cn/software/cepcenv/setup.sh
	cepcenv -r /cvmfs/cepc.ihep.ac.cn/software/cepcsoft use 0.1.0-rc9


	Marlin $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.xml 
	#> $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.log

	" > $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh
	
	chmod +x $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh
	#hep_sub -os CentOS7 $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh
	sh $RecoWorkDir/$OUTPUTDATA/reco_${par}_${ojob}.sh
	fi
	fi
done

let "ijob+=1"
done

let "ipar+=1"
done

