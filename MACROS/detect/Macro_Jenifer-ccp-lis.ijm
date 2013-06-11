/*Modificado de Macro_Jenifer-cooredenada central pocillo
 * La macro anterior fallaba cuando el número de pocillos con 
 * una única célula era menor al límite. Se ha creado la función 
 *  singleCellWellSelector() para solucionarlo.
 * 
 * Modificado de Macro_Jenifer-6 para devolver la coordenada del
 * centro de masas de los pocillos que contienen una única célula
 * en lugar del bounding rectangle de las células que están solas
 * en un pocillo.
 * 
 * "Esta macro se diseñó para Jenifer Clausell, dentro del proyecto
 * del CAM. Funciona sobre dos imágenes que son dos canales
 * distintos de un stitching de baja resolución. El canal rojo
 * contiene los pocillos de un chip y el verde células. La imágen
 * roja debe abrirse a mano, la macrobinariza los pocillos y 
 * selecciona las células que están solas dentro de un pocillo.
 * Devuelve el bounding rectangle de cada una de estas células.
 * El número de resultados está limitado. Para cambiar el límite
 * hay que modificar la variable "límite" en la línea 154."
 * 
 */
setBatchMode(true);
open("#file#");
run("Set Measurements...", "  center redirect=None decimal=0");
//El "Set Measurements" tiene que estar aquí, de lo contrario
//puede dar problemas
run("Options...", "iterations=1 count=1 black edm=Overwrite");
//Las anteriores son las opciones de binarización
//Aquí debería abrir la imágen roja
//open("C:\\Users\\jsoriano\\Desktop\\fluo512experiment--2012_06_06_15_18\\Slide--S00\\Chamber--U00--V00\\image--L0000--S00--U00--V00--J00--X00--Y00--T0000--Z00--C00.ome.tif");
redID = getImageID();
redTitle = getTitle();
run("Rotate 90 Degrees Right");
run("Duplicate...", "title=[rojo binario]");
binaryRedID = getImageID();
binaryRedTitle = getTitle();
//Aquí empieza el procesado de la imágen roja, la cual contiene
//los pocillos
run("Median...", "radius=4");
run("Auto Local Threshold", "method=Niblack radius=15 parameter_1=0 parameter_2=0 white");
//setAutoThreshold("Default dark");
run("Convert to Mask");
run("Fill Holes");
run("BinaryFilterReconstruct ", "erosions=6 white");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
//run("Analyze Particles...", "size=169-1088 pixel circularity=0.70-1.00 show=Nothing display exclude add in_situ");
run("Analyze Particles...", "size=169-1088 pixel circularity=0.70-1.00 show=Nothing exclude clear add");
roiManager("Show All with labels");
roiManager("Show All");

//Aquí se podría llamar a la funcion particle eraser para
//eliminar las partículas que no cumplan la condición de tamaño
//anterior

particleEraser();

selectImage(redID);
run("Open Next");
binaryGreenID = getImageID();
binaryGreenTitle = getTitle();
run("Rotate 90 Degrees Right");
//Aquí empieza el procesado de la imàgen verde, la cual contiene
// las partículas
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Median...", "radius=1");
setThreshold(#thresholdMin#, #thresholdMax#);
run("Convert to Mask");
//run("BinaryFilterReconstruct ", "erosions=1 white");

run("Watershed");
//waitForUser("antes del analyze particles previo al último particle eraser");
//run("Analyze Particles...", "size=4-64 circularity=0.70-1.00 show=Nothing display exclude clear add in_situ");
run("Analyze Particles...", "size=#size#-#maxsize# pixel circularity=#circularity#-1.00 show=Outlines display clear include add");
roiManager("Show All with labels");
roiManager("Show All");



//La funcion particle eraser para elimina las partículas que no
//cumplen la condición de tamaño anterior

//nResults;

//IJ.deleteRows(0, nResults-1);

//waitForUser("empieza el último particle eraser");
particleEraser();

//waitForUser("termina el último particle eraser");

//A partir de aquí se empieza a seleccionar las partículas que 
//están contenidas dentro de un pocillo
imageCalculator("AND create", ""+binaryRedTitle+"",""+binaryGreenTitle+"");
binarygreenANDredID = getImageID();//Esta imágen contiene las partículas que están dentro de un pocillo
binarygreenANDredTitle = getTitle();
run("BinaryReconstruct ", "mask=["+binaryRedTitle+"] seed=["+binarygreenANDredTitle+"] create white");
binaryReconstructedID = getImageID();//Esta imágen estará compuesta por los pocillos que contienen una célula o más
binaryReconstructedTitle = getTitle();
selectImage(binaryRedID);
close();
selectImage(binarygreenANDredID);
close();
selectImage(binaryReconstructedID);
//run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude add in_situ");
run("Analyze Particles...", "size=0-Infinity pixel circularity=0.00-1.00 show=Nothing exclude clear add");
roiManager("Show All with labels");
roiManager("Show All");
//waitForUser("0");
close();//Cierra la imágen binaryReconstructed, pero mantiene en 
//el ROI manager la selección de pocillos que contienen una célula
//o más

//La siquiente línea de código permite seleccionar en la imágen que
// contiene a las partículas, aquellas partículas que están solas
//en un pocillo
selectImage(binaryGreenID);
run("Duplicate...", "title=BinaryGreen-duplicate.tif");
binaryGreenDuplicateID = getImageID();
binaryGreenDuplicateTitle = getTitle();

nRois = roiManager("count");
//print("nRois: "+nRois);
individualCellCounter = 0;//Esta variable va a contar el número
//de partículas que están solas en un pocillo
for(i=nRois; i>=1;i--)
{
//print("i: "+i);
//waitForUser("1");
//updateResults();
//waitForUser("2");
//nResults;
//waitForUser("3");
//IJ.deleteRows(0, nResults);
roiManager("select", i-1);
//run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude in_situ");
//waitForUser("aosdif");
run("Analyze Particles...", "size=0-Infinity pixel circularity=0.00-1.00 show=Nothing exclude clear");
//print("nResults: "+nResults);
//waitForUser("4");
if(nResults!=1)
{
roiManager("select", i-1);
roiManager("Delete");
}
/*Este código va a limitar el número de resultados a un nùmero.
 * Para variar el número hay que escribirlo en la "variable" 
 * limite (línea 144) 
 */
if(nResults ==1)
{
	individualCellCounter ++;
	//print("individualCellCounter: "+individualCellCounter);
}
	limite=100;
if (individualCellCounter == limite)
{
	//exit();
	//exit("we have reached 100 results");//La versión de Ángel
	// no puede mostrar ventanas emergentes

n = roiManager("count");
//print(n);
a=n-1;
//print(a);
//parseInt(a);
b=n-limite-1;
//print(b);
//parseInt(b);
singleCellWellSelector();
}
}
limite = roiManager("count");
//print(n);
a=limite-1;
//print(a);
//parseInt(a);
b=0;
//print(b);
//parseInt(b);
singleCellWellSelector();

//-------------------------------------------------------------------
//Esta función permite eliminar las partículas que no están en 
//el ROI manager
function particleEraser()
{
n = roiManager("count");
//print(n);
indexes = newArray(n);
for(i=0; i<n;i++)
{
indexes[i] = i;	
//print("indexes["+i+"]: "+indexes[i]);
}

run("Select All");
setForegroundColor(0, 0, 0);
run("Fill", "slice");

setForegroundColor(255, 255, 255);
roiManager("select", indexes);
roiManager("Fill");
roiManager("Reset");
}
//-------------------------------------------------------------
/*Esta función selecciona los pocillos con una única célula,
 * crea una serie de imágenes intermedias, salva los resultados,
 *cierra las imágenes y finaliza la macro
 */
function singleCellWellSelector()
{
indexes = newArray(limite);//Este es el número al que se limitará el
//número de resultados
elementMatrixCounter=0;
for(i=a; i>b;i--)
{
//print("elementMatrixCounter: "+elementMatrixCounter);
indexes[elementMatrixCounter] = i;	
//print("indexes["+elementMatrixCounter+"]: "+indexes[elementMatrixCounter]);
elementMatrixCounter++;
}

run("Select All");
setForegroundColor(0, 0, 0);
run("Fill", "slice");

setForegroundColor(255, 255, 255);
roiManager("select", indexes);
roiManager("Fill");

imageCalculator("AND create", ""+binaryGreenDuplicateTitle+"",""+binaryGreenTitle+"");
finalImageID = getImageID();
finalImageTitle = getTitle();
updateResults();
//nResults;
IJ.deleteRows(0, nResults);
selectImage(binaryGreenDuplicateID);
//run("Set Measurements...", "  bounding display redirect=None decimal=3");
run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display exclude in_situ");
selectImage(finalImageID);
close();
selectImage(binaryGreenDuplicateID);
close();
selectImage(binaryGreenID);
close();
//print("\\Clear");//Ángel necesita que el Log window está vacía
//selectWindow("Results");
//saveAs("Results", "C:\\Users\\jsoriano\\Desktop\\Ximo\\Plugins\\Plugins unidad\\UNIDAD CONFOCAL\\CAM\\Macro Jenifer\\fluo512experiment--2012_06_06_15_18\\Slide--S00\\Chamber--U00--V00\\Results.txt");
exit();
}
