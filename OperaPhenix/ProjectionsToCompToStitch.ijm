/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Base Directory directory - stacks", style = "directory") baseDir
#@ File (label = "Base Directory - composites", style = "directory") baseDirComp
#@ File (label = "Output directory stitched", style = "directory") output2
#@ String (label = "File suffix", value = ".tif") suffix

// close all images
	close("*");

setBatchMode(true);

list = getFileList(baseDir);
	
	// Loop through ROWS
	for (i = 0; i < list.length; i++) {
    Row = list[i];
    File.makeDirectory(baseDirComp + File.separator + Row);
    
    // Get the list of subfolders in the row folder 
    WellList = getFileList(baseDir + File.separator + Row);
	
		// Loop through all the WELLS
  		  for (j = 0; j < WellList.length; j++) {
  	      Well = WellList[j];
			File.makeDirectory(baseDirComp+ File.separator + Row + File.separator + Well);
			
		// Get the list of image groups in the well folder
                images_List = getFileList(baseDir + File.separator + Row + File.separator + Well );
                //Array.print(images_List);
                
               	//File.makeDirectory(baseDirComp+ File.separator + Row + File.separator + Well + File.separator + "Comp/");
                for (m = 0; m < images_List.length; m+=4) {
                    if (images_List[m].endsWith(".tif")) {      
                        // Open the image
                        open(baseDir + File.separator + Row + File.separator + Well + images_List[m]);   
                        ch1 = getTitle;
						name = substring(ch1,0,lengthOf(ch1)-19);
						open(baseDir + File.separator + Row + File.separator + Well + images_List[m+1]);
						ch2 = getTitle;
						open(baseDir + File.separator + Row + File.separator + Well + images_List[m+2]);
						ch3 = getTitle;
						open(baseDir + File.separator + Row + File.separator + Well + images_List[m+3]);
						ch4 = getTitle;
						run("Merge Channels...", "c1=" + ch1 + "  c2=" + ch2 + " c3=" + ch3 + " c4=" + ch4 + " create");
					 	rename("Composite");
					   }
				selectWindow("Composite");
				setSlice(1);
				run("Green");
				setSlice(2);
				run("Magenta");
				saveAs("Tif", baseDirComp+ File.separator + Row + File.separator + Well + File.separator + name + "_MaxProject-Comp.tif");	
				run("Close All");	
				}
  		  }
	}

complist = getFileList(baseDirComp);
	
	// Loop through ROWS
	for (i = 0; i < complist.length; i++) {
    CompRow = complist[i];
    Array.print(complist); 
    // Get the list of subfolders in the row folder 
    CompWellList = getFileList(baseDirComp + File.separator + CompRow);
	
		// Loop through all the WELLS
  		  for (j = 0; j < CompWellList.length; j++) {
  	      CompWell = CompWellList[j];
  	      WellName = substring(CompWell, 0, lengthOf(CompWell)-1);
  	      Array.print(CompWellList);
			run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=10 first_file_index_i=1 directory="+ baseDirComp + File.separator + CompRow + File.separator + CompWell +" file_names="+ WellName+"-Tile{ii}_MaxProject-Comp.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap display_fusion computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");	
			saveAs("Tif", output2 + File.separator + WellName + "_MaxProject-Comp.tif");	
			setSlice(1);
			run("Green");
			setMinAndMax(100, 7500);
			setSlice(2);
			run("Magenta");
			setMinAndMax(100, 15000);
			saveAs("PNG", output2 + File.separator + WellName + "_MaxProject-Comp.png");
  		  }
	}
selectWindow("Log");
saveAs("Text", output2 + File.separator + "StitchingLog.txt");
