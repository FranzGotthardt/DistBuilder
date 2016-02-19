#!/usr/local/bin/bash
							    ################################################################
						       ########		Looping Versions v.2 - DistBuilder v2		#########
					    		################################################################


													#####################
													#	Path Selection	#
	    ################################################################################################################
		########																								########
		########						## Add your own path to DAP folder (dist build)							########
		########																								########
											path="/Users/$USER/Documents/build/dap"
		########																								########
		########							## Path to Create Hierarchy at ## 									########
		########																								########
											ext="/Users/$USER/Documents/Datameer"
		########																								########
		########							    ## Date Pattern to use: ## 										########
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
VERSIONEN[$v]=$1 && echo "Version $v was set to $1 $SPEC "
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

if [ ${#VERSION} -gt 6 ]; 
	then 

	## Need checkout Master before Building Developer Branch
	## Use same pattern as Case Statements later!!
					
	git checkout master && git pull 
		
fi
				
## Need Date Reset for specific Versions

if [ "$d" = "true" ]; 
	then 
		now="${datum}" 
fi 

## Activate Hadoop Property for Ant

if [[ ${#SPEC} -gt 0 ]];
	then
		Hadoop="-Dhadoop.dist=$SPEC"
fi


if [[ ${#dest} -eq 0 ]];
	then
	dest=${ext}
fi

git checkout $VERSION && git pull && ant clean-all dist $Hadoop && mkdir -p ${dest}/"$VERSION"/ && unzip -qq ${path}/build/dist/*.zip -d ${dest}/"$VERSION"/$now

##teste && echo "I Build $VERSION $SPEC at Hadoop: $Hadoop ; dest is $dest from path: $path" && echo " Now is $now started at $datum" && echo "MySql is set to $m (${MYSQL[@]})"


test -d ${dest}/$VERSION/"$now"Datameer*/ && echo "> $VERSION $SPEC was unzipped successfully!" || echo "[ERROR:#95] $VERSION $SPEC was NOT unzipped successfully!"

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

if [ "$cval" -eq 1 ];
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


if [ "$h" = "false" ];
	then	
		append "$VERSION"
else
		Speccheck "$VERSION"
fi
  
			      }



function HandleIt {

echo "No Version has been entered on start"	&& read -p "Please type your desired Versions separated by Blankspace:`echo $'\n> '` " -a VERSIONEN
v=0
if [[ "${#VERSIONEN[@]}" -gt 0 ]];
	then
		for VERSION in "${VERSIONEN[$v]}"
			do
		
		VERSION=${VERSIONEN[$v]}

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

		for v in "${!VERSIONEN[@]}"
			do

			VERSION=${VERSIONEN[$v]}
			SPEC=${SPECS[$v]}
			dest=${DESTS[$v]}

			echo "Distribution(s) left to build: ${VERSIONEN[@]}"		
			echo "Building $VERSION $SPEC"

			build "$VERSION"

			if [[ ${#VERSIONEN[@]} -lt 2 ]];
				then
					run "$VERSION"
					times
					continue
			fi

## Remove the used Version from the Array and Clear the Variables

			unset VERSIONEN[$v]

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
	exit

elif [ "$r" = "false" ];
	then
		echo "You've decided not to run the Version, building is finished."
else

		echo "Building $VERSION $SPEC was NOT successfull!" 
fi

				}

## Get SPEC which defines Hadoop dist - SPECHECK

function Speccheck {

VERSION="$1"

## For HandleIt -z if empty String

if [ -z "$VERSION" ];
	then
		VERSION=${VERSIONEN[$v]}
fi

read -p "Add a specific Hadoop Parameter (e.g hdp-2.2.0) for $VERSION submit with Enter to use Apache:`echo $'\n> '`" -r SPEC && specsize=${#SPEC} 
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
	if [ $val -eq 1 ]; 
		then
			echo "$SPEC was FOUND, it was already used for $VERSION !"
			dest="${dest}/Hadoop/$SPEC"
			Hadoop="-Dhadoop.dist=$SPEC"
			
			append "$VERSION"
		else
			echo "$SPEC was NOT found, it was not used for $VERSION before!"
			gradir="${dest}/$VERSION/Specs/Gradlelist-${VERSION///}.txt"
			test -s ${gradir} && gval=$( grep -ic "$SPEC" < "$gradir" ) || ./gradlew -q versions > $gradir

			if [ $gval -eq 1 ];
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

						if [ $gval -eq 1 ];
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

function teste {

echo $dest
echo ${DESTS[$v]}
echo ${DESTS[@]}
echo $SPEC
echo ${SPECS[$v]}
echo ${SPECS[@]}
echo $VERSION
echo ${VERSIONEN[$v]}
echo ${VERSIONEN[@]}
echo ${MYSQL[@]}

}

###########################################################################################################################
#########################################	Script Starts here !   ########################################################
###########################################################################################################################

## Go to Local Repository

cd ${path}

## This is necessary to be able to validate branches

git checkout -q master && git pull -q

## Declare Arrays

declare -a VERSIONEN
declare -a SPECS
declare -a MYSQL

## Declare and Set Variables

declare d h m n r v x 

			d="true"
			h="true"
			m=0
			n=0
			r="true"
			v=1
			x=0
			
dest="${ext}"
now="${datum}"

## ErrorHandling

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
					 -d*) d=false ; echo "Date Parameter was turned off!" ;; 
					  -m) m=false ;;
					  =m) m=true ;;				
				#   -dmg) build trial
				#     -p) use ports
					-*r*) r="false" ; echo "You have decided NOT to run the last Version" ;; 
				 	   *) continue ;;
				esac
		done
			
## Version Input
	        
		for i in "$@"
			do
	        	case "$i" in		 	

## Use Pattern for Versions in the future!!
				
				      =*) continue ;;
			  -[dDrRmM]*) continue ;;
		  		'Master') check "master" ;; 
?????????*|v?.*|*[dDaApP]*|'orca'*|'pi'*|'sealion'*|'fd'*|?.*.*|'master') check "$i" ;; 
	                  -?) echo "Bad option '$i'; only -d for Date ; -m for MySQL and -r are supported!" ;;
					   *) echo $i "is not valid!" ;;

	        	esac
		done

## If something went wrong, try usual way
## else continue.

		if [ ${#VERSIONEN[@]} -eq 0 ];
			then
			
			HandleIt

		else

			Iterate
		
		fi

exit

########################################################################################################################
#############################################     End of Script    #####################################################
########################################################################################################################