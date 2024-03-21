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
	if (indexOf(list[i], "minmax_all.csv") >=0 ) {
		Table.open(dir + list[i]);
		dapi_min = Table.get("value", 0);
		dapi_max = Table.get("value", 1);
		cen1_min = Table.get("value", 2);
		cen1_max = Table.get("value", 3);
		cenh3_min = Table.get("value", 4);
		cenh3_max = Table.get("value", 5);
		close("minmax_all.csv");
	}
}

for (h = 0; h < subdir.length; h++) {

// open images
files = getFileList(subdir[h]);
for (i = 0; i < lengthOf(files); i++) {
	name = files[i];
	if (endsWith(name, ".msr")) {
		image = "[" + subdir[h] + files[i] + "]";
		run("Bio-Formats Importer", "open=" + image + "color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_2 series_3 series_4");
	}
}
wait(2000);

// rename image titles and convert to 8-bit
for (i = 0; i < nImages; i++) {
	selectImage(i+1);
	name = getTitle();
	string1 = substring(name, 0, lastIndexOf(name, ".msr"));
	if (indexOf(name, fp1) >=0) {rename(string1 + "_" + ch1);}
	else if (indexOf(name, fp2) >=0) {rename(string1 + "_" + ch2);}
	else if (indexOf(name, fp3) >=0) {rename(string1 + "_" + ch3);}
}

list = getList("image.titles");
Array.sort(list);
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	call("ij.ImagePlus.setDefault16bitRange", 16);
	if (endsWith(title, ch1)) {setMinAndMax(dapi_min, dapi_max);}
	if (endsWith(title, ch2)) {setMinAndMax(cen1_min, cen1_max);}
	if (endsWith(title, ch3)) {setMinAndMax(cenh3_min, cenh3_max);}
	run("8-bit");
}

// concatentate and create hyperstack
list = getList("image.titles");
ary1 = newArray(0);
ary2 = newArray(0);
ary3 = newArray(0);
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	name = getTitle();
	if (indexOf(name, ch1) >=0) {ary1 = Array.concat(ary1, title);}
	else if (indexOf(name, ch2) >=0) {ary2 = Array.concat(ary2, title);}
	else if (indexOf(name, ch3) >=0) {ary3 = Array.concat(ary3, title);}
}
for (i = 0; i < ary1.length; i++) {
	title = ary1[i];
	selectWindow(title);
	name = getTitle();
	concat1 = ary1[i];
	concat2 = ary2[i];
	concat3 = ary3[i];
	run("Concatenate...", "image1 = concat1 image2 = concat2 image3 = concat3");
	rename(substring(name, 0, lastIndexOf(name, "_")));
}
list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	numZ = nSlices / 3;
	run("Stack to Hyperstack...", "order=xyzct channels=3 slices=numZ frames=1 display=Grayscale");
}

// duplicating hyperstacks to create merges that can be used for ROI selection

list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	selectImage(i+1);
	name = getTitle();
	run("Duplicate...", "duplicate");
	run("Z Project...", "projection=[Sum Slices]");
	rename("SUM_" + name);
}
close("*-1");
list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	if (startsWith(title, "SUM")) {run("Split Channels");}
}
list = getList("image.titles");
cyan = newArray(0);
magenta = newArray(0);
yellow = newArray(0);
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	name = getTitle();
	if (startsWith(title, "C1")) {magenta = Array.concat(magenta, title);}
	else if (startsWith(title, "C2")) {yellow = Array.concat(yellow, title);}
	else if (startsWith(title, "C3")) {cyan = Array.concat(cyan, title);}
}
for (i = 0; i < cyan.length; i++) {
	title = list[i];
	cyanChannel = cyan[i];
	yellowChannel = yellow[i];
	magentaChannel = magenta[i];
	run("Merge Channels...", "c5=&cyanChannel c6=&magentaChannel c7=&yellowChannel");
	selectWindow("RGB");
	rename(title + "_SumMerge");
}

// ROI drawing

  // Converts 'n' to a string, left padding with zeros
  // so the length of the string is 'width'
  function leftPad(n, width) {
      s =""+n;
      while (lengthOf(s)<width)
          s = "0"+s;
      return s;
  }

list = getList("image.titles");
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	if (endsWith(title, "SumMerge")) {
		setTool("freehand");
		selectWindow(title);
		setBatchMode("show");
		Dialog.create("How many RoIs?");
			Dialog.addMessage("This macro will process each toxo cell individually. \n In the next steps you will be drawing a RoI for each cell. \n How many RoIs do you need for this image along?");
			Dialog.addNumber("Number of RoIs", 1);
			Dialog.show();
			rois = Dialog.getNumber();
			setBatchMode("hide");
			if (rois >= 1) {
				for (j = 0; j < rois; j++) {
				selectWindow(title);
				setBatchMode("show");
				waitForUser("RoI Selection", "Draw a RoI around a single cell and click OK when done. \n This process will repeat for the previously entered number of RoIs to be drawn.");
				setBatchMode("hide");
				selectWindow(substring(title, 0, lastIndexOf(title, "_")));
				run("Restore Selection");
				run("Duplicate...", "duplicate");
				run("Clear Outside", "stack");
				pad = leftPad(j+1, 3);
				rename(substring(title, 0, lastIndexOf(title, "_")) + "_RoI" + pad);
				}
			}
			else {
				selectWindow(title);
				close();
				selectWindow(substring(title, 0, lastIndexOf(title, "_")));
				close();
			}
	}
}

list = getList("image.titles");
Array.sort(list);
save_raw = substring(subdir[h], 0, lastIndexOf(subdir[h], "/")) + "/images_raw/";
File.makeDirectory(save_raw);
for (i = 0; i < list.length; i++) {
	title = list[i];
	selectWindow(title);
	if (indexOf(title, "RoI") >=0 ) {continue;}
	else {
		name = getTitle();
		name = substring(name, lastIndexOf(name, "/"));
		saveAs("tiff", save_raw + name);
		wait(2000);
		close();
		}
}

list = getList("image.titles");
Array.sort(list);
save_roi = substring(subdir[h], 0, lastIndexOf(subdir[h], "/")) + "/images_roi/";
File.makeDirectory(save_roi);
for (i = 0; i < list.length; i++) {
	selectWindow(list[i]);
	name = getTitle();
	name = substring(name, lastIndexOf(name, "/")) + "_hypstack";
	saveAs("tiff", save_roi + name);
	close();
}
}


close("*");
setBatchMode(false);

// complete
Dialog.create("Process completed");
	Dialog.addMessage("The macro has successfully completed processing");
	Dialog.show();

/////////////////////////////////////////////////////////////////////////////////////////
