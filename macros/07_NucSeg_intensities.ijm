close("*");
setBatchMode(true);

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

// open roi images
images_roi = subdir[h] + "images_roi/";
files = getFileList(images_roi);
for (i = 0; i < lengthOf(files); i++) {
	name = files[i];
	if (endsWith(name, "DAPI.tif")) {
		image = images_roi + files[i];
		open(image);
	}
}
wait(2000);

// open segmention images
image_seg = subdir[h] + "image_NucSeg/";
files = getFileList(image_seg);
for (i = 0; i < files.length; i++) {
	name = files[i];
	if (indexOf(name, "DAPI") >=0) {
		image = image_seg + files[i];
		open(image);
		}
}
wait(2000);

// sort images and create arrays of images vs segments
list = getList("image.titles");
Array.sort(list);
roi = newArray(0);
seg = newArray(0);
for (i = 0; i < list.length; i++) {
	title = list[i];
	if (indexOf(title, "seg") >=0 ) {
		seg = Array.concat(seg, title);
		}
	else { roi = Array.concat(roi, title);
	}
}

// 3D suite intensity measurements
for (i = 0; i < roi.length; i++) {
	i_roi = substring(roi[i], 0, lastIndexOf(roi[i], ".tif"));
	i_seg = substring(seg[i], 0, lastIndexOf(seg[i], ".tif"));
	run("3D Intensity Measure", "objects=&i_seg signal=&i_roi");
}

// saving as one csv file
savedir = subdir[h] + "measure_NucIntensity/";
File.makeDirectory(savedir);
saveAs("Results", savedir + "3D_intensities.csv");
selectWindow("Results");
run("Close");

close("*");
}

close("*");
setBatchMode(false);

// complete
Dialog.create("Process completed");
	Dialog.addMessage("The macro has successfully completed processing");
	Dialog.show();

