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
files = getFileList(subdir[h] + "image_segment/");
for (i = 0; i < files.length; i++) {
	temp = subdir[h] + "image_segment/" + files[i];
	if (endsWith(temp, "centrin1_seg.tif") || endsWith(temp, "cenh3_seg.tif")) {
		open(temp);
	}
}

// create arrays of each channel
centrin1 = newArray(0);
cenh3 = newArray(0);

list = getList("image.titles");
Array.sort(list);
for (i = 0; i < list.length; i++) {
	title = list[i];
	if (indexOf(title, "centrin1") >=0) {
		centrin1 = Array.concat(centrin1 , substring(title, 0, lengthOf(title) -4));
	}
	if (indexOf(title, "cenh3") >=0) {
		cenh3 = Array.concat(cenh3, substring(title, 0, lengthOf(title) -4));
	}
}

// measure
distcen1cenh3unit_save = subdir[h] + "measure_dist_cen1_cenh3_unit/";
File.makeDirectory(distcen1cenh3unit_save);
for (i = 0; i < cenh3.length; i++) {
	cen1_dist = centrin1[i];
	cenh3_dist = cenh3[i];
	run("3D Distances Closest", "image_a=&cenh3_dist image_b=&cen1_dist distance=DistCenterCenterUnit distance_maximum=1000");
	result_title = substring(cenh3_dist, 0, indexOf(cenh3_dist, "RoI") +6);
	IJ.renameResults("ClosestDistanceCCUnit", result_title);
	saveAs("Results", distcen1cenh3unit_save + result_title + ".csv");
	temp = result_title + ".csv";
	selectWindow(temp);
	run("Close");
}

distcen1_save = subdir[h] + "measure_dist_cen1_unit/";
File.makeDirectory(distcen1_save);
for (i = 0; i < centrin1.length; i++) {
	cen1_dist = centrin1[i];
	run("3D Distances", "image_a=&cen1_dist image_b=&cen1_dist distance=DistCenterCenterUnit distance_maximum=1000");
	result_title = substring(cen1_dist, 0, indexOf(cen1_dist, "RoI") +6);
	IJ.renameResults("DistCenterCenterUnit", result_title);
	saveAs("Results", distcen1_save + result_title + ".csv");
	temp = result_title + ".csv";
	selectWindow(temp);
	run("Close");
}

vol_save = subdir[h] + "measure_volume/";
File.makeDirectory(vol_save);
for (i = 0; i < cenh3.length; i++) {
	title = cenh3[i];
	vol_cenh3 = title + ".tif";
	selectWindow(vol_cenh3);
	run("3D Volume");
	result_title = substring(vol_cenh3, 0, lastIndexOf(vol_cenh3, "_"));
	saveAs("Results", vol_save + result_title + ".csv");
	selectWindow("Results");
	run("Close");
}
for (i = 0; i < centrin1.length; i++) {
	title = centrin1[i];
	vol_cen = title + ".tif";
	selectWindow(vol_cen);
	run("3D Volume");
	result_title = substring(vol_cen, 0, lastIndexOf(vol_cen, "_"));
	saveAs("Results", vol_save + result_title + ".csv");
	selectWindow("Results");
	run("Close");
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

