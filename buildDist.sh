#!/usr/local/bin/bash
							    ################################################################
						       ########					DistBuilder v2					#########
					    		################################################################


													#####################
													#	Path Selection	#
	    ################################################################################################################
		########																								########
		########						## Add your own path to DAP folder (dist build)							########
		########																								########
											path="/Users/$USER/Documents/GitRepo/dap"
		########																								########
		########							## Path to Create Hierarchy at ## 									########
		########																								########
											ext="/Users/$USER/Documents/Datameer"
		########																								########
		########					    ## Date Pattern to use: ( also at line 80 ) ##							########
		########																								########
											datum="$(date +"%d-%B-%Y_%H-%M_%Z")/"
		########																								########
	    ################################################################################################################



## Functions

function append {

if [ "$m" = "true" ];
	then
		MYSQL[$v]=$m

elif [[ $m -eq 0 ]];
	then
		read -p "Do you want to use MySQL - yY/nN?" -n 1 -r
		echo ""
	if [[ $REPLY =~ ^[Yy]$ ]];
		then
			MYSQL[$v]="true" && echo "Activated MySQL for $1"
	fi
fi

SPECS[$v]=$SPEC 
VERSIONS[$v]=$1 && echo "Version $v was set to $1 $SPEC "
DESTS[$v]=$dest

	let v++

if [ "$h" = "true" ]; 
	then
		SPEC=""
		dest="${ext}"
fi
	
}

function build {

dest=${DESTS[$v]}
SPEC=${SPECS[$v]}
m=${MYSQL[$v]}

VERSION="$1"

## Need checkout Master before Building Developer Branch, every Version with namesize bigger 6 is a developer branch, crosslogically; which also avoids the redundance for master

if [ ${#VERSION} -gt 6 ]; 
	then 
					
	git checkout master && git pull 
		
fi
				
## Need Date Reset for specific Versions

if [ "$d" = "true" ]; 
	then 
		now="$(date +"%d-%B-%Y_%H-%M_%Z")/" 
fi 

## Activate Hadoop Property for Gradle

if [[ ${#SPEC} -gt 0 ]];
	then
			if [ "$b" = "ant" ];
				then
					Hadoop="-Dhadoop.dist=$SPEC"
			elif [ "$b" = "gradle" ];
				then
					Hadoop="-Phadoop.dist=$SPEC"
			else
					echo "b is $b [Error#97]" && exit
			fi
fi

## Set standard path for standard Dists

if [[ ${#dest} -eq 0 ]];
	then
		dest="${ext}"
fi

## Start Time Counting for Task

if [ "$t" = "true" ];
	then
		starttime=$(date +%s)

				if [ "$b" = "ant" ];
					then
						git checkout $VERSION && git pull && ant clean-all dist $Hadoop && mkdir -p ${dest}/"$VERSION"/ && unzip -qq ${path}/build/dist/*.zip -d ${dest}/"$VERSION"/$now && e="true" || e="false"
					elif [ "$b" = "gradle" ];
					then
						git checkout $VERSION && git pull && ./gradlew clean dist $Hadoop ${PROPERTIES[@]} && mkdir -p ${dest}/"$VERSION"/ && unzip -qq ${path}/build/dist/*.zip -d ${dest}/"$VERSION"/$now
					else
						echo "$b [Error#129]" && exit
				fi

		while [ "$e" = "false" ];
			do
	
				read -p "There was an Error while building, do you want to restart the Process? Gradlew Clean GenerateImmutables will be exectued before."  -n 1 -r

				if [[ $REPLY =~ ^[Yy]$ ]];
					then
						MYSQL[$v]="true" && echo "Activated MySQL for $1"
					else
						exit
				fi

				./gradlew clean cleanGenerateImmutables generateImmutables

				if [ "$b" = "ant" ];
					then
						git checkout $VERSION && git pull && ant clean-all dist $Hadoop && mkdir -p ${dest}/"$VERSION"/ && unzip -qq ${path}/build/dist/*.zip -d ${dest}/"$VERSION"/$now && e="true" || e="false"
					elif [ "$b" = "gradle" ];
					then
						git checkout $VERSION && git pull && ./gradlew clean dist $Hadoop ${PROPERTIES[@]} && mkdir -p ${dest}/"$VERSION"/ && unzip -qq ${path}/build/dist/*.zip -d ${dest}/"$VERSION"/$now
					else
						echo "$b [Error#129]" && exit
				fi
		done

	else
		teste && echo "I Build $VERSION $SPEC at Hadoop: $Hadoop ; dest is $dest from path: $path" && echo " Now is $now started at $datum" && echo "MySql is set to $m (${MYSQL[@]})"
fi

test -d ${dest}/$VERSION/"$now"Datameer*/ && echo "> $VERSION $SPEC was unzipped successfully!" || echo "[ERROR:#114] $VERSION $SPEC was NOT unzipped successfully!"

endtime=$(date +%s)
buildtime=$(($endtime - $starttime))
echo "Building this Version took $buildtime seconds."

if [ "$m" = "true" ];
	then
		echo "You've decided to use MySQL.."

		cp ${path}/modules/dap-common/lib/job/restricted-mysql*.jar ${dest}/$VERSION/"$now"/Datameer*/etc/custom-jars/
	
		sed -i.bkp '15s/.*/export DAS_DEPLOY_MODE=live/' ${dest}/$VERSION/"$now"/Datameer*/etc/das-env.sh 

		echo "$VERSION $SPEC has been transformed to MYSQL!"
		echo "Checking MySQL status.."
		mysql.server status || mysql.server restart
		echo "done."
fi


}

function check {

	VERSION="$1"
	check="true"
	cdir="${dest}/Versionlist.txt"

test -s ${cdir} || ( echo "Destination ($cdir) was not found!" && echo "" >> $cdir && echo "Created a new Versionlist at $cdir" ) 
test -s ${cdir} && cval=$( grep -ic "$VERSION" < "$cdir" ) || echo "You didn't build $VERSION before, it was not found at the Versionlist at $cdir !"

if [[ "$cval" -eq 1 ]];
	then
		echo "$VERSION was used before, it was found in the Versionlist"
	
elif [[ ${#VERSION} -gt 3 ]]; 
	then
		git checkout -q $VERSION || check="false"

		if [ "$check" = "true" ];
			then
				echo "Checked GIT, $VERSION is valid." 
				echo "$VERSION" >> $cdir && echo "Added $VERSION to the Versionlist at $cdir"
		else
			echo "[checkERROR:#142] $VERSION is not a valid Branch!" 
			read -p "You entered $VERSION, which is not known by GIT please retype your desired Version:`echo $'\n> '`" -r VERSION 
		fi
else
	read -p "Please enter a valid Version instead of ' $VERSION ' ($v):`echo $'\n> '` " -r VERSION
	git checkout -q $VERSION || check="false"

	if [ "$check" = "true" ];
		then
			echo "Checked, $VERSION is valid." 
	else
			echo "[checkERROR:153] $VERSION is not a valid Branch!"
			read -p "You entered $VERSION, which is not known by GIT please retype your desired Version:`echo $'\n> '`" -r VERSION 
	fi
fi

Speccheck "$VERSION"
  
			      }


function HandleIt {

echo "No Version has been entered on start"	&& read -p "Please type your desired Versions separated by Blankspace:`echo $'\n> '` " -a VERSIONS
v=0
if [[ "${#VERSIONS[@]}" -gt 0 ]];
	then
		for VERSION in "${VERSIONS[$v]}"
			do
		
		VERSION=${VERSIONS[$v]}

		check "$VERSION"		
	

		done

else
		echo "No valid Input was entered!" && read -n 1 -p "Submit with enter to build and start current Master with standard Apache.. or x to exit`echo $'\n> '`" -r xit

	if [ "$xit" = "x" ]; 
		then
			echo " = exit! Bye." && exit
	else
		if [[ $m -eq 0 ]];
			then
				read -p "Do you want to use MySQL - yY/nN?" -n 1 -r
				echo ""
			if [[ $REPLY =~ ^[Yy]$ ]];
				then
					MYSQL[$v]="true" && echo "Activated MySQL for Master"		
			fi
		fi
		
	## Fast Master Build
		dest="${ext}"
		build master
		run master
	exit
	fi
fi
				}

function Iterate {

		for v in "${!VERSIONS[@]}"
			do

			VERSION=${VERSIONS[$v]}
			SPEC=${SPECS[$v]}
			dest=${DESTS[$v]}

			echo "Distribution(s) left to build: ${VERSIONS[@]}"		
			echo "Building $VERSION $SPEC"

			build "$VERSION"

			if [[ ${#VERSIONS[@]} -lt 2 ]];
				then
					run "$VERSION"
					times
					continue
			fi

## Remove the used Version from the Array and Clear the Variables

			unset VERSIONS[$v]

			if [ "$h" = "false" ]; 
				then
				SPEC=""
				dest="${ext}/"
			fi
			Hadoop=""
			
		done
				 }

function run   {
			
## Run in Subshell? Try it! or not?

VERSION="$1"

if [ -d ${dest}/$VERSION/"$now"Datameer*/ ] && [ "$r" = "true" ]; 
	then
		cd ${dest}/$VERSION/"$now"Datameer*/
		bin/conductor.sh restart && echo "Successful!"
		open -a Google\ Chrome --new --args -incognito "http:\\localhost:8080"

		echo "It took $(( $buildtime / 60 )) Minutes and $(( $buildtime % 60 )) seconds to complete this task."

	exit

elif [ "$r" = "false" ];
	then
		echo "You've decided not to run the Version, building is finished."
		echo "It took $(( $buildtime / 60 )) Minutes and $(( $buildtime % 60 )) seconds to complete this task."
else
		echo "Building $VERSION $SPEC was NOT successfull!"
		echo "It took $(( $buildtime / 60 )) Minutes and $(( $buildtime % 60 )) seconds to complete this task."

fi

				}

## Get SPEC which defines Hadoop dist - SPECHECK

function Speccheck {

VERSION="$1"
dest="${ext}"

## For HandleIt -z if empty String

if [ -z "$VERSION" ];
	then
		VERSION=${VERSIONS[$v]}
fi

if [ -z "$SPEC" ];
	then

read -e -p "Add a specific Hadoop Parameter (e.g hdp-2.2.0) for $VERSION submit with Enter to use Apache:`echo $'\n> '`" -r SPEC && specsize=${#SPEC} 

fi

dir="${dest}/$VERSION/Specs/Speclist-${VERSION///}.txt"
mkdir -p "${dest}/$VERSION/Specs/"

if [ -s ${dir} ];
	then
		val=$( grep -ic "$SPEC" < "$dir" ) || ( echo "Destination ($dir) was not found!" && echo "" >> $dir && echo "Created a new Speclist for $VERSION at $dir" )
fi

if [ -z "$SPEC" ];
	then
		echo "Using standard Apache Distribution."
		SPEC=""
		append "$VERSION"
		
elif [[ ${#SPEC} -lt 6 ]]; 
	then
		echo "Invalid Specification was '$SPEC' `echo $'\n> '` Displaying available Versions:"
		./gradlew versions -q
		echo "please try again using one of these"
		read -p "Please add a specific Hadoop Parameter for $VERSION or submit with Enter to use Apache:`echo $'\n> '`" -r SPEC
		val=$( grep -ic "$SPEC" < "$dir" )

		if [ $val -eq 1 ];
			then
				echo "$SPEC was FOUND, it was already used for $VERSION !"
				dest="${dest}/Hadoop/$SPEC"
				Hadoop="-Dhadoop.dist=$SPEC"
				
				append "$VERSION"
			
		elif [ "$SPEC" = "x" ]; 
			then 
				echo "Entering 'x' means Exit!"
				echo "Version was $VERSION"
				exit
		else
				echo "Input was empty or $SPEC not found in Versionlist!"
				echo "Using standard Apache Distribution."
				SPEC=""
				append "$VERSION"
		fi
else
	if [[ $val -eq 1 ]]; 
		then
			echo "$SPEC was FOUND, it was already used for $VERSION !"
			dest="${dest}/Hadoop/$SPEC"
			Hadoop="-Dhadoop.dist=$SPEC"
			
			append "$VERSION"
		else
			echo "$SPEC was NOT found, it was not used for $VERSION before!"
			gradir="${dest}/$VERSION/Specs/Gradlelist-${VERSION///}.txt"
			gval=$( grep -ic "$SPEC" < "$gradir" ) || ./gradlew -q versions > $gradir

			#test -s ${gradir} && 

			if [[ $gval -eq 1 ]];
				then	
					echo "$SPEC was found in gradle versions!"
					dest="${dest}/Hadoop/$SPEC"
					Hadoop="-Dhadoop.dist=$SPEC"
					echo "$SPEC" >> $dir
					echo "[LOOPER] Learned a new Spec for $VERSION : $SPEC !"
					append "$VERSION"
			else						
					echo "Invalid Specification was '$SPEC' `echo $'\n> '` Displaying available Versions:"
					./gradlew versions -q
					echo "please try again using one of these"
					read -p "Please add a specific Hadoop Parameter for $VERSION or submit with Enter to use Apache:`echo $'\n> '`" -r SPEC
					gval=$( grep -ic "$SPEC" < "$gradir" )

						if [[ $gval -eq 1 ]];
							then
								echo "$SPEC was found in gradle versions!"
								dest="${dest}/Hadoop/$SPEC"
								Hadoop="-Dhadoop.dist=$SPEC"
								echo "$SPEC" >> $dir
								echo "[LOOPER] Learned a new Spec for $VERSION : $SPEC !"
								append "$VERSION"
					
						elif [ "$SPEC" = "x" ]; 
							then 
								echo "Entering 'x' means Exit!"
								echo "Version was $VERSION"
							exit
						else
							echo "Input was empty or $SPEC not found in Versionlist!"
							echo "Using standard Apache Distribution."
							SPEC=""
							append "$VERSION"
							
						fi
					
				fi
		fi
fi


}

## Additions

function helpMe {

 echo "DistBuilder

Created by Franz Gotthardt
GNU Licensed

This is the second iteration of the DistBuilder.sh script, the intention was a foolproof approach to building distributions in the local git repository, which has to be entered after "path=".
The Script will ask you for every required information and has several ways to handle wrong input.
After the required input has been entered, the script will build the Distribution and create a folder hierarchy in the path entered after "ext="

Accepted Patterns for Versions are:

*	v x.y
*	x.y.z
*	revision number
*	branch tag
*	"master"/"Master"

Parameters 
These can be placed everywhere within commandline input
The Script will create a path including the date by default. 

	* -d Disables the date pattern
	* = Select one Hadoop Property for all builds. Instead of deciding for each Versions, simply add e.g ='cdh-5.0.0-mr1'
	* -r Decide to turn off automatic run
	* -m Turn MySql off for all versions
 	* +m Turn MySQL on for all versions
 	* -P to add a Feature; e.g.: -PtabNavigationFeature=true 


 "
}

function helpVersion {

echo "
Accepted Patterns for Versions are:

*	v x.y
*	x.y.z
*	revision number
*	branch tag
*	"master"/"Master"
"
}

function helpParam {

echo "
Parameters 
These can be placed everywhere within commandline input
The Script will create a path including the date by default. 

	* -d Disables the date pattern
	* = Select one Hadoop Property for all builds. Instead of deciding for each Versions, simply add e.g ='cdh-5.0.0-mr1'
	* -r Decide to turn off automatic run
	* -m Turn MySql off for all versions
 	* +m Turn MySQL on for all versions
  	* -P to add a Feature; e.g.: -PtabNavigationFeature=true 

"


}


function teste {

echo $dest
echo ${DESTS[$v]}
echo ${DESTS[@]}
echo $SPEC
echo ${SPECS[$v]}
echo ${SPECS[@]}
echo $VERSION
echo ${VERSIONS[$v]}
echo ${VERSIONS[@]}
echo ${MYSQL[@]}
echo $PROPERTY 	
echo ${PROPERTIES[$v]}
echo ${PROPERTIES[@]}

}

###########################################################################################################################
#########################################	Script Starts here !   ########################################################
###########################################################################################################################

## Go to Local Repository

cd ${path}

## This is necessary to be able to validate branches

git checkout -q master && git pull -q

## Declare Arrays

declare -a VERSIONS
declare -a SPECS
declare -a MYSQL
declare -a PROPERTIES


## Declare and Set Variables

declare b d e h m n p r t v x z 
			
			b="ant"		   # Build Way Parameter
			d="true"	   # Date Parameter
			e="true"	   # Error Parameter
			h="true"	   # Hadoop Parameter
			m=0			   # MySQL Parameter
			n=0			   # LoopCounter
			p="true"	   # Build Parameters
			r="true"       # Run Parameter
			t="true"	   # Test Parameter
			v=1 		   # Loop
			x=0 		   # Loop
			z=0 		   # Loop for Properties
			
dest="${ext}"
now="${datum}"
STARTMIN=$(date +%M)
STARTSEC=$(date +%s)
## Run old approach if no Input was given

if [ -z "$1" ];
	then
		HandleIt
fi

## Looping for each Element from command line
## Searching for Parameters:

for i in "$@"
	do
		case "$i" in 
				      =*) SPEC="${i//=/}" ; dest="${dest}/Hadoop/$SPEC" ; h=false ; echo "You've decided to use $SPEC for all Versions" ;;
					  -d) d=false ; echo "Date Parameter was turned off!" ;;
		   -h|'help'|'h') helpMe ;; 
					  -m) m=false ; echo "MySQL has been turned off" ;;
					  +m) m=true ; echo "You decided to use MySQL for all Versions" ;;				
			 	   '-P'*) PROPERTIES[$z]=$i  ; p="false" ; let z++ ; echo "[NOTICE!] Parameter $i was added for all Versions!" ;;
					  -r) r="false" ; echo "You have decided NOT to run the last Version" ;; 
					  -t) t="false" ; echo "Starting Test Mode" ;;
				      -*) echo "Bad option '$i' " ; helpParam ; exit ;;
				 	   *) continue ;;
			
				#   -dmg) build trial
				#     -p) use ports
		
		esac
done
			
## Version Input
	        
for i in "$@"
	do
	case "$i" in		 	

## Could use patterns for Versions in the future!
				      												  =*) continue ;;
			  									         -[dDhHPrRtTmM]*) continue ;;
                                    					  'ant'|'gradle') b="$i" ; echo "You've decided to Build using '$b' " ;;
		  														'Master') check "master" ;; 
?????????*|v?.*|*[dDaApP]*|'orca'*|'pi'*|'sealion'*|'fd'*|?.*.*|'master') check "$i" ;; 
					   												   *) echo $i ; helpVersion ;;
   	esac
done

## If something went wrong, indicated by the lack of versions, the try usual way, else continue as planned.

if [ ${#VERSIONS[@]} -eq 0 ];
	then
		HandleIt
	else
		Iterate
fi

exit

########################################################################################################################
#############################################     End of Script    #####################################################
########################################################################################################################