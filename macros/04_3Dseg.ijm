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
	if (endsWith(temp, "centrin1.tif") || endsWith(temp, "cenh3.tif")) {
		open(temp);
	}
}

// 3D segmentation
list = getList("image.titles");
Array.sort(list);
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	title = getTitle();
	run("3D Fast Filters","filter=Maximum radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=4");
	selectWindow("3D_Maximum");
	run("Z Project...", "projection=[Max Intensity]");
	print("\\Clear");
	run("Auto Threshold", "method=Intermodes white show");
	logString = getInfo("log");
	thres = substring(logString, lastIndexOf(logString, " ") +1, lengthOf(logString) -1);
	rename(substring(title, 0, lengthOf(title) -4) + "_" + thres + "intermodes");
	name = getTitle();
	save_thres = subdir[h] + "/image_threshold/";
	File.makeDirectory(save_thres);
	saveAs("tiff", save_thres + name);
	close();
	close("3D_Maximum");
	selectWindow(title);
	run("3D Iterative Thresholding", "min_volpix=10 max_vol_pix=1000 min_threshold=thres min_contrast=0 criteria_method=MSER threshold_method=STEP segment_results=Best value_method=1");
	run("glasbey");
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	setMinAndMax(min, max);
	run("Apply LUT", "stack");
	rename(substring(title, 0, lengthOf(title) -4) + "_" + "seg");
	name = getTitle();
	save_seg = subdir[h] + "image_segment/";
	File.makeDirectory(save_seg);
	saveAs("tiff", save_seg + name);
	run("Z Project...", "projection=[Max Intensity]");
	rename(name + "Max");
	name = getTitle();
	save_segmax = subdir[h] + "image_segMax/";
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

