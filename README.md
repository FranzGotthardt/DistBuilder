# DistBuilder V.2
##### Created by Franz Gotthardt
##### GNU Licensed

This is the second iteration of the DistBuilder.sh script, the intention was a foolproof approach to building distributions in the local git repository, which has to be entered after "path=".

The Script will ask you for every required information and has several ways to handle wrong input.

After the required input has been entered, the script will build the Distribution and create a folder hierarchy in the path entered after "ext="

# Properties

* Adjust path to your build destination (Git Repository)
* Adjust ext to your desired destination for the hierarchy
 
# How To Use

* Download the Script and access the Folder where you've placed it with the console. 
* Open the file with a text editor and adjust your path to Datameer (path=) and your desired path for the hierarchy (ext=).
* Once adjusted, you can open this script with mac using Terminal as standard application:
 
#### Otherwise you have to run it using the terminal manually; access the folder with cd path/to/script and run it using sh DistBuilder.sh

# These are all accepted input formats, you can use:

* v x.y
* x.y.z
* revision number
* branch tag
* "master"

# Hadoop Specifications

Once you've successfully submitted your versions to build, you can also add a Hadoop specification, you can do this by simply waiting for the step:

Add a specific Dist or submit with Enter to use standard Apache:

* add the dist String, e.g hdp-2.2.0
* press enter to use standard distribution
* invalid input will lead to list with available versions, you then have the chance to enter the right one or exit with "x"

# Hierarchy

* This works intentionally, it will create a path including the date by default. The date pattern can be disabled with the Parameter -d .

 
# Parameters
 
* = Select one Hadoop Property for all builds. Instead of deciding for each Versions, simply add e.g ='cdh-5.0.0-mr1'
* -d Remove date pattern from Build-Hierarchy, this can be placed everywhere within the input
* -r Decide to turn off automatic run
* -m Decide to turn MySql off for all versions
 
# Versionlog
## Goal of V1:

* building multiple distributions (/)
+ handle typical errors (tick)
* support variables, set path manually (tick)
 
## Goal V2:

+ Iterating through $@ to get scalability (tick)
+ for looping the Versions to clear the code (tick)
+ add attributes for date hierarchy (tick) skinning (error) secure mode (error)trials (error) -> these are not used at the moment (warning)
+ individual hadoop dists for versions (tick)
+ easily add the same for all (tick)
+ Add Revisioncheck to avoid duplicated versions (error) - this is not practicable (warning)
+ Added validation of Specs and Versions on Input (tick)
+ Last Version will be detected and automatically ran (tick) ( turn off via -r (tick) )
+ Added Machine Learning, an already built distribution will be verified faster (tick)
+ MySql (tick)

## Goal V3: 

* Feature Flags (warning)
* Ports (warning)
* Trials - necessary or possible after build (question)
* Skinning - used (question)
* Secure Mode - used (question)
