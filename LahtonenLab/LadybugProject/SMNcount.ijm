/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

//setBatchMode(true);

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
				
				getDimensions(width, height, channels, slices, frames);
				if (width < 10 || height < 10) {
					run("Close All");
				} else {
					title=getTitle();
					selectWindow(title);
					roiManager("Add");
					run("Duplicate...", "title=detection ignore");
					run("Enhance Contrast", "saturated=0.35");
					run("Grays");
					run("Convoluted Background Subtraction", "convolution=Mean radius=50");
					run("Median...", "radius=1");
					run("8-bit");
					run("adaptiveThr ", "using=[Weighted mean] from=20 then=-25");
					run("Select None");
					run("Analyze Particles...", "  show=[Count Masks]");
					roiManager("Select", 0);
					run("Enlarge...", "enlarge=-1");
					run("Border Exclude Labels", "keep_overlaps=false interpolation=5");
					run("Select None");
					roiManager("reset");					
					run("Label image to ROIs", "rm=[RoiManager[size=1, visible=true]]");
					Spotcount = roiManager("count");
					if (Spotcount < 1) {
						run("Close All");
					} else {
					roiManager("Select", 0);
					selectImage(title);
					roiManager("Show All");
					roiManager("Deselect");
					roiManager("Measure");
					selectWindow("Results");
					ResultsToLog();
					CleanUp();
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

function CleanUp() { 
// function description
	selectWindow(title);
	run("Enhance Contrast", "saturated=0.35");
	run("Green");
	roiManager("Show All without labels");
	run("Flatten");
	saveAs("Jpeg", output + File.separator + WellName + "_" + name + "_SpotsMeasured.jpeg");
	roiManager("reset");
	run("Clear Results");
	run("Close All");
}
