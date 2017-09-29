
#usage: sh gid_project.sh project_name_filter [gitinspect_options]
#example: sh gid_project.sh "futures/ios" --since=2017/08/20
#example: sh gid_project.sh "java-backend/futures" --since=2017/08/20
#example: sh gid_project.sh "futures/node"


if [ $# -lt 1 ];then
	echo "usage sh gid_project.sh project_name_filter [gitinspect_options]"
	exit 0
fi	

echo "fetch projects from gitlab, please wait....." 

projects=`gitlab projects | grep 'ssh_url_to_repo' | sed -e 's/"ssh_url_to_repo": "//g' | sed -e 's/",//g' |grep -i -E "$1" |sed 's/ //g'`


if [ ! -d output ]; then
  mkdir output
fi
pushd output
for p in $projects
do
	name=`echo $p |awk -F '/' '{print $NF}' |sed -n 's/.git//p'` 
	echo "name="$name
	if [ -d $name ];then
		cd $name
		git pull
		cd -	
	else
		git clone $p
	fi
	project=$project" "$name
done


echo "generate project record, please wait ....."

gitinspector $2 --format=html --timeline --localize-output -w $project > ../project.html

popd

open project.html
