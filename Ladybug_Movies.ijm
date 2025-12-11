#@ File (label = "Base directory - sorted", style = "directory") sortDir
#@ File (label = "Base Output directory - series", style = "directory") SeriesOutput

//setBatchMode(true);
run("Close All");


// Get all the subfolders in the base folder
list = getFileList(sortDir);

// Loop through ROWS
for (i = 0; i < list.length; i++) {
    Row = list[i];
    File.makeDirectory(SeriesOutput + File.separator + Row);
    // Get the list of subfolders in the row folder 
    WellList = getFileList(sortDir + File.separator + Row);
    

    // Loop through all the WELLS
    for (j = 0; j < WellList.length; j++) {
        Well = WellList[j];
        File.makeDirectory(SeriesOutput+ File.separator + Row + File.separator + Well);
        // Get the list of subfolders in the well folder
        FieldList = getFileList(sortDir + File.separator + Row + File.separator + Well);

        // Loop through all the FIELDS
        for (k = 0; k < FieldList.length; k++) {
            Field = FieldList[k];
            FieldName = substring(Field, 0, lengthOf(Field)-1);
            // Get the list of channels in fields folder
            ChannelList = getFileList(sortDir + File.separator + Row + File.separator + Well + File.separator + Field);

            // Loop through all the image groups in the sample folder "1-5" 
            for (l = 0; l < ChannelList.length; l++) {
                Channel = ChannelList[l];

                // Get the list of image groups in the sample folder
                stackMap = newArray("p01","p02","p03","p04","p05","p06","p07");
                for (m = 0; m < stackMap.length; m++) {
	                stack = stackMap[m];
	                File.openSequence(sortDir + File.separator + Row + File.separator + Well + File.separator + Field + File.separator + Channel, "virtual filter="+stack);
	                run("Properties...", "channels=1 slices=1 frames=73 pixel_width=0.0064500 pixel_height=0.0064500 voxel_depth=0.0064500");
	                ChannelName = substring(Channel, 0, lengthOf(Channel)-1);
	                rename(ChannelName+"_"+stack);            
            	}
				run("Concatenate...", "  title="+ChannelName+"_Conca image1="+ChannelName+"_p01 image2="+ChannelName+"_p02 image3="+ChannelName+"_p03 image4="+ChannelName+"_p04 image5="+ChannelName+"_p05 image6="+ChannelName+"_p06 image7="+ChannelName+"_p07");
				run("Stack to Hyperstack...", "order=xyctz channels=1 slices=7 frames=73 display=Color");
        	}
        	run("Merge Channels...", "c2=ch1_Conca c4=ch2_Conca c6=ch3_Conca create");
        	rename(FieldName+"_Combined");
        	title = getTitle();
        	saveAs("Tiff", SeriesOutput + File.separator + Row + File.separator + Well + File.separator + title);
			run("Close All");
    	}
	}
}