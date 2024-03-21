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

for (i = 0; i < subdir.length; i++) {
	files = getFileList(subdir[i]);
	for (j = 0; j < lengthOf(files); j++) {
		name = files[j];
		if (endsWith(name, ".msr")) {
			image = "[" + subdir[i] + files[j] + "]";
			run("Bio-Formats Importer", "open=" + image + "color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_2 series_3 series_4");
		}
	}
wait(2000);
}

list = getList("image.titles");
dapi = newArray(0);
cen1 = newArray(0);
cenh3 = newArray(0);
for (i = 0; i < list.length; i++) {
	title = list[i];
	if (indexOf(title, fp1) >=0 ) {dapi = Array.concat(dapi, title);}
	if (indexOf(title, fp2) >=0 ) {cen1 = Array.concat(cen1, title);}
	if (indexOf(title, fp3) >=0 ) {cenh3 = Array.concat(cenh3, title);}
}

dapi_min = 65535;
dapi_max = 0;
cen1_min = 65535;
cen1_max = 0;
cenh3_min = 65535;
cenh3_max = 0;
for (i = 0; i < dapi.length; i++) {
	selectWindow(dapi[i]);
	print(dapi[i]);
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (min < dapi_min) {
		dapi_min = min;
	}
	if (max > dapi_max) {
		dapi_max = max;
	}
}
for (i = 0; i < cen1.length; i++) {
	selectWindow(cen1[i]);	
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (min < cen1_min) {
		cen1_min = min;
	}
	if (max > cen1_max) {
		cen1_max = max;
	}
}
for (i = 0; i < cenh3.length; i++) {
	selectWindow(cenh3[i]);	
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	if (min < cenh3_min) {
		cenh3_min = min;
	}
	if (max > cenh3_max) {
		cenh3_max = max;
	}
}

channel = newArray(0);
channel = Array.concat(channel, ch1, ch1, ch2, ch2, ch3, ch3);
type = newArray(0);
type = Array.concat(type, "minimum", "maximum","minimum", "maximum","minimum", "maximum");
values = newArray(0);
values = Array.concat(values, dapi_min, dapi_max, cen1_min, cen1_max, cenh3_min, cenh3_max);
Table.create("minmax_all");
Table.setColumn("channel", channel);
Table.setColumn("type", type);
Table.setColumn("value", values);
Table.save(dir + "minmax_all.csv");
close("minmax_all");

file = File.open(dir + "minmax_all.txt");
print(file, "DAPI minimum = " + dapi_min);
print(file, "DAPI maximum = " + dapi_max);
print(file, "cen1 (AlexaFluor 488) minimum = " + cen1_min);
print(file, "cen1 (AlexaFluor 488) maximum = " + cen1_max);
print(file, "cenh3 (AlexaFluor 594) minimum = " + cenh3_min);
print(file, "cenh3 (AlexaFluor 594) maximum = " + cenh3_max);

close("*");
setBatchMode(false);

// complete
Dialog.create("Process completed");
	Dialog.addMessage("The macro has successfully completed processing");
	Dialog.show();
