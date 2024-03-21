# centrin_dist
Series of ImageJ macros for 3D segmentation and spatial measurements of mitotic machinery

Requires ImageJ version 1.54f or later

Requires 3D ImageJ Suite version 4.1.5 or later
Ollion et al, 2003, PMID: 23681123
https://imagej.net/plugins/3d-imagej-suite/

Function of each macro:
01 determines min and max pixel values per channel from all images
02 RoI drawing to isolate single cells from multi-cell FoV
03 Splits channels
04 Determines threshold per image and 3D segments images
05 Computes distances between segments, both centrin-centrin distance and centrin-nearest_object distance, as well as segment volumes
06 3D segmentation of nuclei based on DAPI signal
07 Computes signal intensities for nuclear segments
08 Computes signal intensities for non-nuclear segments
09 Quantifies the number of centrosomes per image by determining the number of cen1 maxima