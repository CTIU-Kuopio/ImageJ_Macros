/*
 Macro to count and measure nucleoli in extraced nucleus images. Excludes nuclei without spots and images smaller than 10x10pix
 Generated for the Ladybug project, Lahtonen lab, 2025
 Needed fixes and improvements:
 - measure intesity on original image, not the mask
 - user input for stain and subsequent naming
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode(true);

// close all images
	close("*");
// empty the ROI manager
	roiManager("reset");
// empty the results table
	run("Clear Results");
// empty log
	print("\\Clear");
print("Well, Nucleus, Cluster, XX, Area, Mean, StdDev, Min, Max, X, Y, XM, YM, Perim., Circ., IntDen, RawIntDen, AR,  Round,  Solidity");


// Get all the subfolders in the base folder
WellList = getFileList(input);

	// Loop through Wells
	for (j = 0; j < WellList.length; j++) {
	        Well = WellList[j];
	    	WellName = substring(Well, 7, lengthOf(Well)-1);
					    
	    	images_List = getFileList(input + File.separator + Well );
	    	
	    	for (m = 0; m < images_List.length; m++) {
			   open(input + File.separator + Well + images_List[m]);
				title=getTitle();
				name = File.nameWithoutExtension;
				NucNum = substring(title, 8, lengthOf(title)-4);
				resetMinAndMax;
				run("Measure");
				run("Select None");
				run("Duplicate...", "title=Thres_1");
				run("Median...", "radius=5");
				setAutoThreshold("Minimum dark no-reset");
				run("Convert to Mask");
				run("Analyze Particles...", "display");
				if (nResults < 2 ) {
					run("Close All");
				} else {
					getDimensions(width, height, channels, slices, frames);
					if (width < 10 || height < 10) {
						run("Close All");
					} else {
					NucSize = getResult("Area", 0);
					FilteredSize = getResult("Area", 1);
					SizeRatio = FilteredSize / NucSize; 
					//print(SizeRatio);
					run("Clear Results");
					selectWindow("Thres_1");
					run("Close");
					if (SizeRatio < 0.8) {
						selectWindow(title);
						run("Duplicate...", "title="+name);
						run("Convoluted Background Subtraction", "convolution=Mean radius=50");
						run("Median...", "radius=2");
						run("8-bit");
						run("adaptiveThr ", "using=[Weighted mean] from=50 then=-30");
						run("Analyze Particles...", "display add"); /// HOW ABOUT WE MEASURE ON THE ACTUAL IMAGE YOU TWAT??? CHANGE FOR THE FUTURE
						ResultsToLog(); 
						CleanUp();
					} else {
						ResultsToLogEmpty();
						CleanUpEmpty();
					}
				}
			}
	}
}
selectWindow("Log");
saveAs("Text", output + File.separator + "SpotResults.csv");



/*
 * List of used functions: 
 */

function ResultsToLog() { 
// function description
	headings = split(String.getResultsHeadings);
	for(k=0; k<nResults; k++) {
		row = k ;
		ROI = k+1;
		line = "";
		for (a=0; a<lengthOf(headings); a++){
    		line = line + getResult(headings[a], row) + ",";
		}
		print(WellName + "," + NucNum + "," + ROI + "," + line);
		}
		//print(WellName + "," + NucNum + "," + ROIROI + "," + line);	
}

function ResultsToLogEmpty() { 
// function description
	headings = split(String.getResultsHeadings);
	for(k=0; k<1; k++) {
		row = k ;
		ROI = k+1;
		line = "";
		for (a=0; a<lengthOf(headings); a++){
    		line = line + getResult(headings[a], row) + ",";
		}
		print(WellName + "," + NucNum + ", 0, " + line);
		}	
}

function CleanUp() { 
// function description
	selectWindow(title);
	roiManager("Show All");
	run("Flatten");
	saveAs("Jpeg", output + File.separator + WellName + "_" + name + "_SpotsMeasured.jpeg");
	roiManager("reset");
	run("Clear Results");
	run("Close All");
}

function CleanUpEmpty() { 
// function description
	roiManager("reset");
	run("Clear Results");
	run("Close All");
}
