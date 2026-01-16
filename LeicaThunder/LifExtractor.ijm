//This macro extracts all images saved in a lif file 
  
//Defining directories for saving and analysis
dir = getDirectory("Select a directory containing one or several .lif files");
saveDir = dir + "/ExtractedTifs/";
File.makeDirectory(saveDir);
files = getFileList(dir);

//Batch process .tif extraction
setBatchMode(true);
k=0;
n=0;
run("Bio-Formats Macro Extensions");
for(f=0; f<files.length; f++) {
	if(endsWith(files[f], ".lif")) {
		k++;
		id = dir+files[f];
		Ext.setId(id);
		Ext.getSeriesCount(seriesCount);
		n+=seriesCount;
		for (i=0; i<seriesCount; i++) {
			run("Bio-Formats Importer", "open=["+id+"] color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack series_"+(i+1));
			Title = getTitle();	
			iText = IJ.pad(i, 3);  
			saveAs("tiff", saveDir+Title+"_"+iText+".tif");
      		run("Close All");
     		}	
		}
	}
setBatchMode(false);
waitForUser("All Done", "All images are extracted :)");
exit();