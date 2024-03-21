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
	open(temp);
}

images = getList("image.titles");
for (i = 0; i < images.length; i++) {
	selectWindow(images[i]);
	print(images[i]);
	run("Split Channels");
}

images = getList("image.titles");
Array.sort(images);
for (i = 0; i < images.length; i++) {
	title = images[i];
	selectWindow(title);
	if (startsWith(title, "C1")) {
		rename(substring(title, 3, lastIndexOf(title, "_")) + "_" + ch3);
	}
	if (startsWith(title, "C2")) {
		rename(substring(title, 3, lastIndexOf(title, "_")) + "_" + ch2);
	}
	if (startsWith(title, "C3")) {
		rename(substring(title, 3, lastIndexOf(title, "_")) + "_" + ch1);
	}
	name = getTitle();
	path = subdir[h] + "images_roi/";
	print("Name: " + name);
	print("Path: " + path);
	saveAs("tiff", path + name);
	close();
	}

}
setBatchMode(false);

// complete
Dialog.create("Process completed");
	Dialog.addMessage("The macro has successfully completed processing");
	Dialog.show();

/////////////////////////////////////////////////////////////////////////////////////////
