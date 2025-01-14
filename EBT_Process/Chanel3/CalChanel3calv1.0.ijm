
  requires("1.47v");

//=======INICIALIZACION DE VARIABLES==CHECKSUM=====================================
//inicializacion de variables
 	title = "Calibracion de dosis MULTICANAL - 8-FOLD WAY";
 	data="aammdd"; 
 	lot="CN";
 	temps = "90m";
 	rutacal = getDirectory("plugins")+"\\DJS3\\EBT_Process\\Lib\\EBT_Mch";
 	rutapac = "Z:\\Calibraciones\\Cal"		

//valores del fondo por sectores para evaluar su constancia
//1 plastico, 2 placa, 3 fondo del plasctico superior del escaner

	v1xc = 296;
	v1yc = 338;
	l1 = 90;
  	vmitjana1 = 25585;ç
  	vdesv1 = 1000;
	v2xc = 612;
	v2yc = 346;
	l2 = 90;	
  	vmitjana2 = 41325;
  	vdesv2 = 3000;
	v3xc = 1062;
	v3yc = 404;
	l3 = 45;
  	vmitjana3 = 25438;
 	vdesv3 = 1000;

//==================== cuadrado de media de la medida ======================

	supx = 830; //centro cuadrante baja dosis
  	supy = 640; //centro cuadrante baja dosis
  	saltx = 288;
  	salty = 174;

	costat = 50;
 	centrex = 10;
 	centrey = 10; 

//parametros de ajuste de la regresi�n

	Cresol = 0.005;

//Opcion de debug clasico, si log = 1 escribe en log window los valores de pixel de los campos

logval = 1;

//variable de los pesos por canal
wei = newArray("1","1","1");

//Dosis de referencia
dosis = newArray(0.193, 0.359, 0.6468, 0.926, 1.238, 1.727, 2.189, 2.598);
 
//========================FIN DE INICIALIZACION VARIABLES, FIN CHECKSUM===========

//=============INTERFACE===USER data INPUT====================================
//inicio de la interface de recogida de datos NH, Calibracion, cortes y placas
  Dialog.create(title);
  Dialog.addMessage("CALIBRACION DE EBT3 MULTICANAL                                       ");
  Dialog.addString("Fecha:", data);  
  Dialog.addString("Lote:", lot);
  Dialog.addCheckbox("Interrumpir ante errores de fondo", true);
  Dialog.addCheckbox("clasificacion alfabetica", true);
  Dialog.addCheckbox("placa invertida", false);
  Dialog.addMessage("Equalizador:");
  Dialog.addSlider("Red", 0.0, 1.0, 1.0);
  Dialog.addSlider("Green", 0.0, 1.0, 1.0);
  Dialog.addSlider("Blue", 0.0, 1.0, 0.0); 

  Dialog.show();
  data = Dialog.getString();
  lot = Dialog.getString();
  stoper = Dialog.getCheckbox();
  alfabet = Dialog.getCheckbox();
  invertin = Dialog.getCheckbox();
  pes1 = Dialog.getNumber();
  pes2 = Dialog.getNumber();
  pes3 = Dialog.getNumber();
  wei[0] = pes1;
  wei[1] = pes2;
  wei[2] = pes3;

//FLUJO DEL PROGRAMA PRINCIPAL

//Se crea el directorio de resultados intermedios (borrable)

	File.makeDirectory(rutapac+data+lot+temps+"\\Rest");

//Opcion de definicion de los archivos, numerico alfabet = false, A, B, C, D alfabet = true;

if (alfabet==true) {
	vA = "A";
	vB = "B";
	vC = "C";
	vD = "D";
} else {
	vA = "001";
	vB = "002";
	vC = "003";
	vD = "004";
}

//<<<<
//===========abrir fondos y placas irradiadas, realizar la media de cuatro placas
//===========extraer los tres canales de las medias
//===========correccion por uniformidad en funcion del espacio y la dosis (NO SE APLICA)
//===========substraccion del fondo a las placas irradiadas
//<<<<

///========PROCESADO INICIAL: MEDIA, SEPARACION POR COLORES, SUBSTRACCION DEL FONDO=========
//anemi, variable de stop segun stoper
  
//media de las placas irradiadas

	open(rutapac+data+lot+temps+"\\C"+lot+vA+".tif");
	open(rutapac+data+lot+temps+"\\C"+lot+vB+".tif");
	open(rutapac+data+lot+temps+"\\C"+lot+vC+".tif");
	open(rutapac+data+lot+temps+"\\C"+lot+vD+".tif");
	imageCalculator("Average create stack", "C"+lot+vA+".tif","C"+lot+vB+".tif");
	imageCalculator("Average create stack", "C"+lot+vC+".tif","C"+lot+vD+".tif");
	imageCalculator("Average create stack", "Result of C"+lot+vA+".tif","Result of C"+lot+vC+".tif");

	selectWindow("Result of C"+lot+vC+".tif");
	close();
	selectWindow("Result of C"+lot+vA+".tif");
	close();
	selectWindow("C"+lot+vD+".tif");
	close();
	selectWindow("C"+lot+vC+".tif");
	close();
	selectWindow("C"+lot+vB+".tif");
	close();
	selectWindow("C"+lot+vA+".tif");
	close();
	selectWindow("Result of Result of C"+lot+vA+".tif");


//multi-canal r g b placas irradiadas

	run("Split Channels");
	selectWindow("C1-Result of Result of C"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"r.tif");
	selectWindow("C2-Result of Result of C"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"g.tif");
	selectWindow("C3-Result of Result of C"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"b.tif");

//media de los fondos

	open(rutapac+data+lot+temps+"\\F"+lot+vA+".tif");
	open(rutapac+data+lot+temps+"\\F"+lot+vB+".tif");
	open(rutapac+data+lot+temps+"\\F"+lot+vC+".tif");
	open(rutapac+data+lot+temps+"\\F"+lot+vD+".tif");
	imageCalculator("Average create stack", "F"+lot+vA+".tif","F"+lot+vB+".tif");
	imageCalculator("Average create stack", "F"+lot+vC+".tif","F"+lot+vD+".tif");
	imageCalculator("Average create stack", "Result of F"+lot+vA+".tif","Result of F"+lot+vC+".tif");

	selectWindow("Result of F"+lot+vC+".tif");
	close();
	selectWindow("Result of F"+lot+vA+".tif");
	close();
	selectWindow("F"+lot+vD+".tif");
	close();
	selectWindow("F"+lot+vC+".tif");
	close();
	selectWindow("F"+lot+vB+".tif");
	close();
	selectWindow("F"+lot+vA+".tif");
	close();
	selectWindow("Result of Result of F"+lot+vA+".tif");
	
//multi-canal r g b del fondo

	run("Split Channels");
	
	selectWindow("C1-Result of Result of F"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\f"+lot+"r.tif");
	selectWindow("C2-Result of Result of F"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\f"+lot+"g.tif");
	selectWindow("C3-Result of Result of F"+lot+vA+".tif");
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\f"+lot+"b.tif");
	selectWindow("f"+lot+"r.tif");

// <<<Verificacion constancia escaneo canal rojo
	//PARENTESIS DE VERIFICACION DE CONSTANCIA
		makeRectangle(v1xc, v1yc, l1, l1);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana1+vdesv1) && (mean > vmitjana1-vdesv1)) { 
			print("sector 1 escaner constante OK");}
		else { if(stoper == true){
			Dialog.create("Error sector1");
			Dialog.addMessage("Error en el fondo de cristal");
			Dialog.show();}}
		makeRectangle(v2xc, v2yc, l2, l2);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana2+vdesv2) && (mean > vmitjana2-vdesv2)) { 
			print("sector 2 escaner constante OK");}
		else { if(stoper == true){ 
			Dialog.create("Error sector2");
			Dialog.addMessage("Error en el fondo de placa");
			Dialog.show();}}
		makeRectangle(v3xc, v3yc, l3, l3);
		getStatistics(n, mean, min, max, std, histogram);
		if ((mean < vmitjana3+vdesv3) && (mean > vmitjana3-vdesv3)) { 
			print("sector 3 escaner constante OK");}
		else { if(stoper == true){
			Dialog.create("Error sector3");
			Dialog.addMessage("Error en el fondo de plastico");
			Dialog.show();}}
	run("Select None");
	//FIN DE PARENTESIS

//====resta y division de la placa irradiada por canales
//rojo
	
	imageCalculator("Substract create", "f"+lot+"r.tif","c"+lot+"r.tif");
	imageCalculator("Divide create 32-bit", "Result of f"+lot+"r.tif","f"+lot+"r.tif");
	selectWindow("c"+lot+"r.tif");
	close();
	selectWindow("f"+lot+"r.tif");
	close();
	selectWindow("Result of Result of f"+lot+"r.tif");	
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"fr.tif");
	selectWindow("Result of f"+lot+"r.tif");	
	close();	

//verde
	
	imageCalculator("Substract create", "f"+lot+"g.tif","c"+lot+"g.tif");
	imageCalculator("Divide create 32-bit", "Result of f"+lot+"g.tif","f"+lot+"g.tif");
	selectWindow("c"+lot+"g.tif");
	close();
	selectWindow("f"+lot+"g.tif");
	close();
	selectWindow("Result of Result of f"+lot+"g.tif");	
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"fg.tif");
	selectWindow("Result of f"+lot+"g.tif");	
	close();	

//azul
	
	imageCalculator("Substract create", "f"+lot+"b.tif","c"+lot+"b.tif");
	imageCalculator("Divide create 32-bit", "Result of f"+lot+"b.tif","f"+lot+"b.tif");
	selectWindow("c"+lot+"b.tif");
	close();
	selectWindow("f"+lot+"b.tif");
	close();
	selectWindow("Result of Result of f"+lot+"b.tif");	
	saveAs("Tiff", rutapac+data+lot+temps+"\\Rest\\c"+lot+"fb.tif");
	selectWindow("Result of f"+lot+"b.tif");	
	close();	

		
//========FIN PROCESADO INICIAL PLACAS

/////============================OBTENCION DE VALORES POR SECTORES Y COLORES==============

quark = newArray("r","g","b");
ng = newArray(8);
ang = newArray(8);

//====Valores de referencia de las dosis para los ocho campos de 5x5 cm a DFS 100 y 10 cm de prof. Ver NH 00200.
//dosis vieja del OMP usando Magic factors
//dosis = newArray(0.1498, 0.2996, 0.5993, 0.8989, 1.1986, 1.648, 2.0975, 2.5469);
//dosis = newArray(0.2996, 0.5992, 1.1986, 1.7978, 1.984, 3.296, 4.195, 5.0938);  //doble irradiacion

sortida = File.open(rutacal+"\\cal3ch"+lot+".txt");
stream = newArray(8);

for (k=0; k<3; k++){

	selectWindow("c"+lot+"f"+quark[k]+".tif");

	if(invertin==false){
		makeRectangle(supx-centrex, supy-centrey,costat, costat);
		getStatistics(area, ng[0], min, max, std);
		makeRectangle(supx-centrex, supy-salty-centrey, costat, costat);
		getStatistics(area, ng[1], min, max, std);
		makeRectangle(supx-centrex, supy-2*salty-centrey, costat, costat);
		getStatistics(area, ng[2], min, max, std);
		makeRectangle(supx-centrex, supy-3*salty-centrey, costat, costat);
		getStatistics(area, ng[3], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-3*salty-centrey, costat, costat);
		getStatistics(area, ng[4], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-2*salty-centrey, costat, costat);
		getStatistics(area, ng[5], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-salty-centrey, costat, costat);
		getStatistics(area, ng[6], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-centrey, costat, costat);
		getStatistics(area, ng[7], min, max, std);	
		if(logval ==1){
			print("nivel de gris "+quark[k]+" :");
			ngsort = d2s(ng[0], 2);
			for(kin=1; kin<8;kin++){
				ngsort = ngsort+", "+d2s(ng[kin], 2);
			}
			print(ngsort);
		}

	}else{
		makeRectangle(supx-centrex, supy-3*salty-centrey,costat, costat);
		getStatistics(area, ng[0], min, max, std);
		makeRectangle(supx-centrex, supy-2*salty-centrey, costat, costat);
		getStatistics(area, ng[1], min, max, std);
		makeRectangle(supx-centrex, supy-salty-centrey, costat, costat);
		getStatistics(area, ng[2], min, max, std);
		makeRectangle(supx-centrex, supy-centrey, costat, costat);
		getStatistics(area, ng[3], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-centrey, costat, costat);
		getStatistics(area, ng[4], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-salty-centrey, costat, costat);
		getStatistics(area, ng[5], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-2*salty-centrey, costat, costat);
		getStatistics(area, ng[6], min, max, std);
		makeRectangle(supx-saltx-centrex, supy-3*salty-centrey, costat, costat);
		getStatistics(area, ng[7], min, max, std);
		if(logval ==1){
			print("nivel de gris "+quark[k]+" :");
			ngsort = d2s(ng[0], 2);
			for(kin=1; kin<8;kin++){
				ngsort = ngsort+", "+d2s(ng[kin], 2);
			}
			print(ngsort);
		}
	}	

	mem = 0.0;	
	for(j = 0; j < 7; j = j + Cresol){

		for(i=0; i<8; i++){
			ang[i] = ng[i]*(j+dosis[i])/10000;
		}
	
		Fit.doFit("Straight Line", ang, dosis);
		rsq = Fit.rSquared;
		if(rsq >= mem){
			Cpar = j;
			mem2 = rsq;
		}
		mem = rsq;
	}

	for(i=0; i<8; i++){
		ang[i] = ng[i]*(Cpar+dosis[i])/10000;
	}	
	Fit.doFit("Straight Line", ang, dosis);
	Npar= Fit.p(0);
	Mpar = Fit.p(1);
	mem3 = Fit.rSquared;
	Bpar = 1/Mpar*10000;
	Apar = -Npar/Mpar*10000;
	sA = d2s(Apar, 3);
	sB = d2s(Bpar, 3);
	sC = d2s(Cpar, 2);
	print(sortida, sA+"	"+sB+"	"+sC+"	"+wei[k]);
	print("A: "+sA+", B: "+sB+", C:	"+sC+", W: "+wei[k]);
	print(" R^2 para C = ", mem2, " para A y B = ", mem3);
	
}


print("\n FIN DEL PROCESADO TOTAL");


