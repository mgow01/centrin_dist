close("*");
setBatchMode(true);
// enter the names of the channels to be used in image titles
ch1 = "DAPI"
ch2 = "centrin1"
ch3 = "cenh3"
// enter the channel titles as used during acquistion
fp1 = "DAPI"
fp2 = "Alexa 488"
fp3 = "Alexa 594"

dir = getDirectory("Choose a directory");
subdir = newArray(0);
list = getFileList(dir);
for (i = 0; i < list.length; i++) {
	if (endsWith(list[i], "/")) {
		temp = dir + list[i];
		subdir = Array.concat(subdir, temp);
	}
}

for (h = 0; h < subdir.length; h++) {

// open images
files = getFileList(subdir[h] + "images_roi/");
for (i = 0; i < files.length; i++) {
	temp = subdir[h] + "images_roi/" + files[i];
	if (endsWith(temp, "DAPI.tif")) {
		open(temp);
	}
}

list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	selectWindow(list[i]);
	run("3D Fast Filters", "filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
	selectWindow("3D_Median");
	run("3D Nuclei Segmentation", "auto_threshold=MinError manual=0");
	close("3D_Median");
	selectWindow("merge");
	run("3D Binary Close Labels", "radiusxy=5 radiusz=3 operation=Close");
	close("merge");
	selectWindow("CloseLabels");
	rename(list[i] + "_seg");
	run("glasbey");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	setMinAndMax(min, max);
	run("Apply LUT", "stack");
	save_seg = subdir[h] + "image_NucSeg/";
	File.makeDirectory(save_seg);
	name = getTitle();
	saveAs("tiff", save_seg + name);
	run("Z Project...", "projection=[Max Intensity]");
	rename(name + "Max");
	name = getTitle();
	save_segmax = subdir[h] + "image_NucSegMax/";
	File.makeDirectory(save_segmax);
	saveAs("tiff", save_segmax + name);
}
close("*");

}

close("*");
setBatchMode(false);

// complete
Dialog.create("Process completed");
	Dialog.addMessage("The macro has successfully completed processing");
	Dialog.show();

/////////////////////////////////////////////////////////////////////////////////////////