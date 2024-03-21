close("*");
setBatchMode(true);

// open images
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
	
images_roi = subdir[h] + "images_roi/";
files = getFileList(images_roi);
for (i = 0; i < lengthOf(files); i++) {
	name = files[i];
	if (endsWith(name, "centrin1.tif")) {
		image = images_roi + files[i];
		open(image);
	}
}
wait(2000);

// fetching threshold values
image_thres = subdir[h] + "image_threshold/";
files = getFileList(image_thres);
thresh = newArray(0);
for (i = 0; i < files.length; i++) {
	name = files[i];
	if (indexOf(name, "centrin") >=0) {
		thresh = Array.concat(thresh, substring(name, lastIndexOf(name, "_") +1, lastIndexOf(name, "intermodes")));
	}
}

list = getList("image.titles");
Array.sort(list);
save_cenmaxima = subdir[h] + "measure_cen1_maxima/";
File.makeDirectory(save_cenmaxima);
for (i = 0; i < list.length; i++) {
	title = list[i];
	thres = thresh[i];
	print("title: " + title);
	print("threshold: " + thres);
	selectWindow(title);
	run("3D Maxima Finder", "minimmum=&thres radiusxy=1.50 radiusz=1.50 noise=100");
	if (nResults > 0) {
		result_title = substring(title, 0, indexOf(title, "RoI") +6);
		saveAs("Results", save_cenmaxima + result_title + ".csv");
	}
	selectWindow("Results");
	run("Close");
}

save_maxima = subdir[h] + "image_cen1_maxima/";
File.makeDirectory(save_maxima);
list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	title = list[i];
	if (startsWith(title, "peaks")) {
		selectWindow(title);
		rename(substring(title, indexOf(title, "Measurement", lastIndexOf(title, "_") + "cenMaxima")));
		name = getTitle();
		saveAs("tif", save_maxima + name + ".csv");
		close();
	}
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

