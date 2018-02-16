#!/bin/bash
set -f

startPath=$1
outputPath=$2
dataSince=$3;
dataUntil=$4;
author=$5
commitFrom=$6
commitTo=$7

y=$(date +'%G');
m=$(date +'%m');
d=$(date +'%d');
pkupSourcePath=$outputPath
actualMonthSourcePath="$pkupSourcePath/$y/$m/source";

cd "$startPath"

if [ ! -d $actualMonthSourcePath ];
then
    echo "Directory $actualMonthSourcePath doesnt exists";
    echo "Createing $actualMonthSourcePath";
    $(mkdir -p $actualMonthSourcePath);
else
    echo "Directory $actualMonthSourcePath exists";
fi

gitLogCommand="git log --no-merges --format=\"%H|%P|%s\"";

if [ ! -z $dataSince ];
then
    gitLogCommand+=" --since=\"$dataSince\""
fi;

if [ ! -z $dataUntil ];
then
    gitLogCommand+=" --until=\"$dataUntil\""
fi;

if [ ! -z $author ];
then
    gitLogCommand+=" --author=\"$author\""
fi;

if [ ! -z $commitFrom ];
then
    if [ ! -z $commitTo ];
    then
        gitLogCommand+=" $commitFrom..$commitTo"
    else
        gitLogCommand+=" $commitFrom"
    fi
fi;

echo $gitLogCommand;
# exit 1;
c = `eval $gitLogCommand`

for commit in $c;
do
    echo $commit;
    exit 1;
    IFS='|';
    commitDetails=($commit);
    childCommit=${commitDetails[0]};
    parentCommit=${commitDetails[1]};
    commitMessage=${commitDetails[2]};
    futurePath=$actualMonthSourcePath;
    if [[ $commitMessage == DE* ]] || [[ $commitMessage == US* ]];
    then
        IFS='_';
        tmpArry=($commitMessage);
        futureName=${tmpArry[0]};
        futurePath+="/$futureName";
    else
        futurePath+="/$commitMessage";
    fi 
    IFS=' ';
    if [ ! -d $futurePath ];
    then
        $(mkdir -p $futurePath);
    fi

    fileDifPath="$futurePath/$commitMessage.diff.log";

    echo $fileDifPath;
    $(git diff $parentCommit $childCommit > $fileDifPath);
done