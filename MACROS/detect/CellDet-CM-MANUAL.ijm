setBatchMode(true);
file=getArgument()
open("#file#");
run("8-bit");
// run("Median...", "radius=3");
// run("Subtract Background...", "rolling=2 separate create sliding");
run("Enhance Contrast", "saturated=0.35");
run("Rotate 90 Degrees Right");
setAutoThreshold("Default");
setThreshold(#thresholdMin#, #thresholdMax#);
run("Convert to Mask");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Measurements...", "  center redirect=None decimal=0");
run("Analyze Particles...", "size=#size#-#maxsize# pixel circularity=#circularity#-1.00 show=Nothing display exclude clear");
