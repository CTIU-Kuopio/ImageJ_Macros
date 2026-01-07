#@ File (label = "Base directory - sorted", style = "directory") sortDir
#@ File (label = "Base Output directory - MaxProject", style = "directory") MaxProOutput

// close all images
	close("*");

setBatchMode(true);

// Get all the subfolders in the base folder
list = getFileList(sortDir);

// Loop through ROWS
for (i = 0; i < list.length; i++) {
    Row = list[i];
    File.makeDirectory(MaxProOutput + File.separator + Row);
    // Get the list of subfolders in the row folder 
    WellList = getFileList(sortDir + File.separator + Row);
    

    // Loop through all the WELLS
    for (j = 0; j < WellList.length; j++) {
        Well = WellList[j];
        File.makeDirectory(MaxProOutput+ File.separator + Row + File.separator + Well);
        // Get the list of subfolders in the well folder
        FieldList = getFileList(sortDir + File.separator + Row + File.separator + Well);
		
        // Loop through all the FIELDS
        for (k = 0; k < FieldList.length; k++) {
            Field = FieldList[k];
            FieldName = substring(Field, 0, lengthOf(Field)-1);
            
            // Get the list of channels in fields folder
            ChannelList = getFileList(sortDir + File.separator + Row + File.separator + Well + File.separator + Field);
			
			// Define Tile mapping for fields f01 to f16
			tileMap = newArray("13","01","02","03","04","05","06","07","08","09","10","11","12","14","15","16");

			// Loop through all channels
			for (l = 0; l < ChannelList.length; l++) {
			    Channel = ChannelList[l];
			    ChannelName = substring(Channel, 0, lengthOf(Channel)-1);
			    print(ChannelName);

		    // Get images in this channel folder
		    images_List = getFileList(sortDir + File.separator + Row + File.separator + Well + File.separator + Field + File.separator + Channel);

		    // Determine Tile based on Field index
		    fieldIndex = parseInt(substring(FieldName, 1)) - 1; // f01 -> index 0
		    Tile = tileMap[fieldIndex];

		    if (ChannelName == "ch4") { // This is supposed to be used for the brightfield channel
		        // For channel 4 : open only first plane
		        open(sortDir + File.separator + Row + File.separator + Well + File.separator + Field + File.separator + Channel + File.separator + images_List[0]);
		        title = substring(Well, 0, lengthOf(Well)-1) + "-Tile" + Tile + "-" + ChannelName + "_Plane1";
		        saveAs("Tiff", MaxProOutput + File.separator + Row + File.separator + Well + File.separator + title);
		        run("Close All");
		    } else {
		        // For other channels: open all .tiff files and do max projection
		        for (m = 0; m < images_List.length; m++) {
		            if (endsWith(images_List[m], ".tiff")) {
		                open(sortDir + File.separator + Row + File.separator + Well + File.separator + Field + File.separator + Channel + File.separator + images_List[m]);
		            }
		        }
		        title = substring(Well, 0, lengthOf(Well)-1) + "-Tile" + Tile + "-" + ChannelName + "_MaxProject";
		        run("Images to Stack", "use");
		        run("Enhance Contrast", "saturated=0.35");
		        run("Z Project...", "projection=[Max Intensity]");
		        saveAs("Tiff", MaxProOutput + File.separator + Row + File.separator + Well + File.separator + title);
		        run("Close All");
    		}
			}
       
            }
        }
}
