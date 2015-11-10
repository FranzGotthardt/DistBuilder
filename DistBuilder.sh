#Set variables in console
VERSION=$@
VERSION1=$1
VERSION2=$2
VERSION3=$3
VERSION4=$4
VERSION5=$5

now="$(date +"%H_%M_%d_%m_%Y")/" #Required for Date Hierarchy Disable with #
path="/Users/$USER/Documents/build/dap" #Add your own path to DAP folder (dist build)
ext="/Users/$USER/Documents/Datameer" #Path to Create Hierarchy at

cd ${path}

#When no Version is set in console before, set one now:
if [[ "$VERSION" == "" ]]; 
	then 
	
	echo "No Version has been entered on start"	
	read -p "Please Type up to 5 Versions separated by Blankspace: " -r VERSION1 VERSION2 VERSION3 VERSION4 VERSION5
	
	if [[ "$VERSION1" == "" ]]; 
		then 
	
	echo "No Input given"
	read -p "Press x to exit or submit with enter to build current Master with standard Apache.. " -r xit
		
		if [[ "$xit" == x ]]; 
			then
			echo "x means exit"
			exit
		fi

	git checkout master && git pull && ant clean-all dist
	mkdir -p ${ext}/Master/
	unzip ${path}/build/dist/*.zip -d ${ext}/Master/$now
			if [ -d ${ext}/Master/$now/ ]; 
				then
					open -f ${ext}/Master/"$now"Datameer* || echo "Building Dists was successfull!" 
					exit
			fi
	fi
fi



#Get SPEC which defines Hadoop dist - SPECHECK
	read -p "Add a specific Dist or submit with Enter to use standard Apache: " -r SPEC
	specsize=${#SPEC} 
 
if [ "$SPEC" == "" ]; 
	then
	echo "Building standard Apache Distributions.."

	elif [ $specsize -ge 6 ]; 
		then
	
			ext="${ext}/$SPEC"
			Hadoop="-Dhadoop.dist=$SPEC"
			echo "Building $VERSION with $SPEC"

	else
			echo "Invalid Specification, displaying available Versions:"
			./gradlew versions -q
			echo "please try again using one of these"
			read -p "Add a specific Dist or submit with Enter to use standard Apache: " -r SPEC
			if [ "$SPEC" == x ]; 
				then 
					echo "x means exit"
					exit 
			fi
fi


#Building Distributions

size1=${#VERSION1} 
if [ $size1 -gt 6 ]; 
	then # Need checkout Master before Building Developer Branch
		
	git checkout master && git pull 
	git checkout $VERSION1 && git pull && ant clean-all dist $Hadoop

	elif [ $size1 -lt 3 ]; 
		then
		
			echo "Please enter a valid Version for Version 1!"
			exit
	else
	
	git checkout $VERSION1 && git pull && ant clean-all dist $Hadoop
	
fi
	mkdir -p ${ext}/"$VERSION1"/
	unzip ${path}/build/dist/*.zip -d ${ext}/"$VERSION1"/$now
	
	if [ -d ${ext}/$VERSION1 ]
		then
			echo "First Version, $VERSION1 was unzipped successfully!"
		else
			echo "First Version, $VERSION1 was NOT unzipped successfully!"
	fi



if [ "$VERSION2" = "" ]; 
	then 
		exit 
fi

size2=${#VERSION2} 
if [ $size2 -gt 6 ]; 
	then # Need checkout Master before Building Developer Branch	
		git checkout master && git pull 
		git checkout $VERSION2 && git pull && ant clean-all dist $Hadoop

	elif [ $size2 -le 3 ]; 
		then
			echo "The second Version was invalid!"
			exit
	else
		git checkout $VERSION2 && git pull && ant clean-all dist $Hadoop
	
fi
		mkdir -p ${ext}/"$VERSION2"/
		unzip ${path}/build/dist/*.zip -d ${ext}/$VERSION2/$now

		if [ -d ${ext}/$VERSION2 ]
			then
			echo "Second Version, $VERSION2 was unzipped successfully!"
		else
			echo "Second Version, $VERSION2 was NOT unzipped successfully!"
		fi


if [ "$VERSION3" = "" ]; 
	then 
		exit 
fi

size3=${#VERSION3} 	
if [ $size3 -gt 6 ];
	then # Need checkout Master before Building Developer Branch
		
		git checkout master && git pull 
		git checkout $VERSION3 && git pull && ant clean-all dist $Hadoop
	
	elif [ $size3 -le 3 ];
		then
	
		echo "The third Version entered was invalid!"
		exit

	else
		
		git checkout $VERSION3 && git pull && ant clean-all dist $Hadoop
fi
		mkdir -p ${ext}/"$VERSION3"/
		unzip ${path}/build/dist/*.zip -d ${ext}/$VERSION3/$now
		
		if [ -d ${ext}/$VERSION3 ]	
			then
				echo "Third Version, $VERSION3 was unzipped successfully!"
		else
				echo "Third Version, $VERSION3 was NOT unzipped successfully!"
		fi


if [ "$VERSION4" = "" ]; 
	then 
		exit 
fi

size4=${#VERSION4} 
if [ $size4 -gt 6 ]; 
	then # Need checkout Master before Building Developer Branch
	
		git checkout master && git pull 
		git checkout $VERSION4 && git pull && ant clean-all dist $Hadoop
	
	elif [ $size4 -le 3 ]; 
		then
			echo "The fourth Version entered was invalid!"
			exit
	else

		git checkout $VERSION4 && git pull && ant clean-all dist $Hadoop
fi
		mkdir -p ${ext}/"$VERSION4"/
		unzip ${path}/build/dist/*.zip -d ${ext}/$VERSION4/$now

	if [ -d ${ext}/$VERSION4 ]
		then
			echo "Fourth Version, $VERSION4 was unzipped successfully!"
	else
			echo "Fourth Version, $VERSION4 was NOT unzipped successfully!"
	fi


if [ "$VERSION5" = "" ]; 
	then 
		exit 
fi

size5=${#VERSION5} 
if [ $size5 -gt 6 ]; 
	then # Need checkout Master before Building Developer Branch
	
		git checkout master && git pull 
		git checkout $VERSION5 && git pull && ant clean-all dist $Hadoop
	
	elif [ $size5 -le 3 ]; 
		then
		
		echo "The last Version entered was invalid!"
		exit

	else
		
		git checkout $VERSION5 && git pull && ant clean-all dist $Hadoop

fi
		mkdir -p ${ext}/"$VERSION5"/
		unzip ${path}/build/dist/*.zip -d ${ext}/$VERSION5/$now
		
		if [ -d ${ext}/$VERSION5 ]
			then
				echo "Last Version, $VERSION5 was unzipped successfully!"
		else
				echo "Last Version, $VERSION5 was NOT unzipped successfully!"
		fi


open ${ext} || echo "Building Dists was successfull!"

exit
