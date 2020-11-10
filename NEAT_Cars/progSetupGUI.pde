// NOTE: I ACCIDENTALLY DELETED GUI_BUILDER_DATA
//       I CHANGED THE NAME SO THAT OPENING GUI 
//       BUILDER WON'T WIPE THIS FILE'S CODE

/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void drawProgSetup(PApplet appc, GWinData data) { //_CODE_:progSetupWin:883482:
  appc.background(230);
} //_CODE_:progSetupWin:883482:

public void progMode_dl_click(GDropList source, GEvent event) { //_CODE_:progMode_dl:222692:
  //println("progMode_dl - GDropList >> GEvent." + event + " @ " + millis());
  if (progMode_dl.getSelectedIndex() == 0) {
    println("Course set to easy_tck.txt");
    CAR_POS = new Vec2f(500, 300);
    CAR_DIR = new Vec2f(1, 0);
    TRACK_FILE_PATH = "racetracks/easy_tck.txt";
  } else if (progMode_dl.getSelectedIndex() == 1) {
    println("Course set to hardhairpins_tck.txt");
    CAR_POS = new Vec2f(100, 100);
    CAR_DIR = new Vec2f(0, 1);
    TRACK_FILE_PATH = "racetracks/hardhairpins_tck.txt";
  }
  course.load(TRACK_FILE_PATH);
} //_CODE_:progMode_dl:222692:

public void xmlFile_tf_change(GTextField source, GEvent event) { //_CODE_:xmlFile_tf:276638:
  //println("xmlFile_tf - GTextField >> GEvent." + event + " @ " + millis());
  // Do nothing.
} //_CODE_:xmlFile_tf:276638:

public void loadXML_btn_click(GButton source, GEvent event) { //_CODE_:loadXML_btn:445140:
  //println("loadXML_btn - GButton >> GEvent." + event + " @ " + millis());
  EVAL_MODE = true;

  String genomeXMLPath = xmlFile_tf.getText();
  println("Loading " + genomeXMLPath + " and starting simulation...");
  EVAL_GENOME = new Genome(genomeXMLPath);
  SIM_START = true;
  progSetupWin.close(); // Close the window and start the simulation

} //_CODE_:loadXML_btn:445140:

public void pop_tf_change(GTextField source, GEvent event) { //_CODE_:pop_tf:833161:
  //println("pop_tf - GTextField >> GEvent." + event + " @ " + millis());
  POPULATION = int(pop_tf.getText());
  println("POPULATION set to " + POPULATION);
} //_CODE_:pop_tf:833161:

public void wmutchan_sl_change(GCustomSlider source, GEvent event) { //_CODE_:wmutchan_sl:306607:
  //println("custom_slider1 - GCustomSlider >> GEvent." + event + " @ " + millis());
  WEIGHT_MUTATION_CHANCE = wmutchan_sl.getValueF();
  println("WEIGHT_MUTATION_CHANCE set to " + WEIGHT_MUTATION_CHANCE);
} //_CODE_:wmutchan_sl:306607:

public void nnodechan_sl_change(GCustomSlider source, GEvent event) { //_CODE_:nnodechan_sl:933516:
  //println("nnodechan_sl - GCustomSlider >> GEvent." + event + " @ " + millis());
  NEW_NODE_CHANCE = nnodechan_sl.getValueF();
  println("NEW_NODE_CHANCE set to " + NEW_NODE_CHANCE);
} //_CODE_:nnodechan_sl:933516:

public void nconnchan_sl_change(GCustomSlider source, GEvent event) { //_CODE_:nconnchan_sl:915369:
  //println("nconnchan_sl - GCustomSlider >> GEvent." + event + " @ " + millis());
  NEW_CONN_CHANCE = nconnchan_sl.getValueF();
  println("NEW_CONN_CHANCE set to " + NEW_CONN_CHANCE);
} //_CODE_:nconnchan_sl:915369:

public void wmuti_sl_change(GCustomSlider source, GEvent event) { //_CODE_:wmuti_sl:283450:
  //println("custom_slider1 - GCustomSlider >> GEvent." + event + " @ " + millis());
  PERTURBATION_BOUND = wmuti_sl.getValueF();
  println("PERTURBATION_BOUND set to " + PERTURBATION_BOUND);
} //_CODE_:wmuti_sl:283450:

public void wd_tf_change(GTextField source, GEvent event) { //_CODE_:wd_tf:305626:
  //println("textfield1 - GTextField >> GEvent." + event + " @ " + millis());
  CW_D = float(wd_tf.getText());
  println("Compatability weight of disjoint genes set to " + CW_D);
} //_CODE_:wd_tf:305626:

public void we_tf_change(GTextField source, GEvent event) { //_CODE_:we_tf:574208:
  //println("textfield2 - GTextField >> GEvent." + event + " @ " + millis());
  CW_E = float(we_tf.getText());
  println("Compatability weight of excess genes set to " + CW_E);
} //_CODE_:we_tf:574208:

public void wdw_tf_change(GTextField source, GEvent event) { //_CODE_:wdw_tf:765557:
  //println("textfield3 - GTextField >> GEvent." + event + " @ " + millis());
  CW_DW = float(wdw_tf.getText());
  println("Compatability weight of weight diff. set to " + CW_DW);
} //_CODE_:wdw_tf:765557:

public void ct_tf_change(GTextField source, GEvent event) { //_CODE_:ct_tf:769832:
  COMPATABILITY_THRESHOLD = float(ct_tf.getText());
  println("Compatability threshold set to " + COMPATABILITY_THRESHOLD);
} //_CODE_:ct_tf:769832:

public void wim_tf_change(GTextField source, GEvent event) { //_CODE_:wim_tf:606060:
  //println("textfield1 - GTextField >> GEvent." + event + " @ " + millis());
  WEIGHT_INIT_MEAN = float(wim_tf.getText());
  println("WEIGHT_INIT_MEAN set to " + WEIGHT_INIT_MEAN);
} //_CODE_:wim_tf:606060:

public void wis_tf_change(GTextField source, GEvent event) { //_CODE_:wis_tf:862046:
  //println("textfield2 - GTextField >> GEvent." + event + " @ " + millis());
  WEIGHT_INIT_STDDEV = float(wis_tf.getText());
  println("WEIGHT_INIT_STDDEV set to " + WEIGHT_INIT_STDDEV);
} //_CODE_:wis_tf:862046:

public void quickgen_btn_click(GButton source, GEvent event) { //_CODE_:quickgen_btn:423030:
  //println("quickgen_btn - GButton >> GEvent." + event + " @ " + millis());
  EVAL_MODE = false;
  println("Starting Training...");
  
  // Ensure that GENOME_SAVE_PATH is valid
  if (GENOME_SAVE_PATH.indexOf(".") == -1 || !GENOME_SAVE_PATH.substring(GENOME_SAVE_PATH.indexOf(".")).equals(".xml")) {
    println("ERROR: Ensure that the genome save path is a valid xml file name");
    return;
  }
  
  // Initialize evaluator
  eval = new Evaluator(POPULATION, DEFAULT_ACTIVATION);
  eval.initPopulation(5, 2);
  
  SIM_START = true;
  progSetupWin.close(); // Close the window and start the simulation
} //_CODE_:quickgen_btn:423030:

public void xmlSavePath_tf_change(GTextField source, GEvent event) {
  GENOME_SAVE_PATH = xmlSavePath_tf.getText();
  println("GENOME_SAVE_PATH set to " + GENOME_SAVE_PATH);
}

// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("Sketch Window");
  progSetupWin = GWindow.getWindow(this, "Car Neuroevolution Setup", 0, 0, 500, 600, JAVA2D);
  progSetupWin.noLoop();
  progSetupWin.setActionOnClose(G4P.CLOSE_WINDOW);
  progSetupWin.addDrawHandler(this, "drawProgSetup");
  label1 = new GLabel(progSetupWin, 9, 155, 450, 20);
  label1.setText("NEAT Training Settings (Defaults are the Recommended Settings)");
  label1.setOpaque(false);
  
  // I added this one in myself because the builder broke.. shhh
  xmlSavePath_tf = new GTextField(progSetupWin, 15, 186, 455, 17, G4P.SCROLLBARS_NONE);
  xmlSavePath_tf.setPromptText("Trained Genome XML Save Path... (Default model/car.xml)");
  xmlSavePath_tf.setOpaque(true);
  xmlSavePath_tf.addEventHandler(this, "xmlSavePath_tf_change");
  
  progMode_dl = new GDropList(progSetupWin, 13, 40, 153, 60, 2, 10);
  progMode_dl.setItems(loadStrings("list_222692"), 0);
  progMode_dl.addEventHandler(this, "progMode_dl_click");
  label2 = new GLabel(progSetupWin, 12, 14, 143, 20);
  label2.setText("Racetrack");
  label2.setOpaque(false);
  label3 = new GLabel(progSetupWin, 12, 90, 356, 20);
  label3.setText("NN Eval Settings (Only works in Eval Mode)");
  label3.setOpaque(false);
  xmlFile_tf = new GTextField(progSetupWin, 11, 122, 220, 17, G4P.SCROLLBARS_NONE);
  xmlFile_tf.setPromptText("Pretrained Genome XML File Path...");
  xmlFile_tf.setOpaque(true);
  xmlFile_tf.addEventHandler(this, "xmlFile_tf_change");
  loadXML_btn = new GButton(progSetupWin, 233, 121, 129, 20);
  loadXML_btn.setText("Load NN Genome!");
  loadXML_btn.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  loadXML_btn.addEventHandler(this, "loadXML_btn_click");
  pop_tf = new GTextField(progSetupWin, 15, 240, 120, 18, G4P.SCROLLBARS_NONE);
  pop_tf.setText("1000");
  pop_tf.setOpaque(true);
  pop_tf.addEventHandler(this, "pop_tf_change");
  label4 = new GLabel(progSetupWin, 15, 214, 80, 20);
  label4.setText("Population");
  label4.setOpaque(false);
  wmutchan_sl = new GCustomSlider(progSetupWin, 13, 382, 177, 40, "grey_blue");
  wmutchan_sl.setShowValue(true);
  wmutchan_sl.setShowLimits(true);
  wmutchan_sl.setLimits(0.8, 0.0, 1.0);
  wmutchan_sl.setNumberFormat(G4P.DECIMAL, 2);
  wmutchan_sl.setOpaque(false);
  wmutchan_sl.addEventHandler(this, "wmutchan_sl_change");
  label6 = new GLabel(progSetupWin, 13, 358, 178, 20);
  label6.setText("Weight Mutation Chance");
  label6.setOpaque(false);
  nnodechan_sl = new GCustomSlider(progSetupWin, 277, 380, 180, 40, "grey_blue");
  nnodechan_sl.setShowValue(true);
  nnodechan_sl.setShowLimits(true);
  nnodechan_sl.setLimits(0.03, 0.0, 0.5);
  nnodechan_sl.setNumberFormat(G4P.DECIMAL, 3);
  nnodechan_sl.setOpaque(false);
  nnodechan_sl.addEventHandler(this, "nnodechan_sl_change");
  label7 = new GLabel(progSetupWin, 276, 355, 184, 20);
  label7.setText("New Neuron Chance");
  label7.setOpaque(false);
  label8 = new GLabel(progSetupWin, 278, 426, 179, 20);
  label8.setText("New Synapse Chance");
  label8.setOpaque(false);
  nconnchan_sl = new GCustomSlider(progSetupWin, 278, 450, 179, 40, "grey_blue");
  nconnchan_sl.setShowValue(true);
  nconnchan_sl.setShowLimits(true);
  nconnchan_sl.setLimits(0.05, 0.0, 0.5);
  nconnchan_sl.setNumberFormat(G4P.DECIMAL, 3);
  nconnchan_sl.setOpaque(false);
  nconnchan_sl.addEventHandler(this, "nconnchan_sl_change");
  wmuti_sl = new GCustomSlider(progSetupWin, 13, 453, 178, 40, "grey_blue");
  wmuti_sl.setShowValue(true);
  wmuti_sl.setShowLimits(true);
  wmuti_sl.setLimits(0.2, 0.0, 1.0);
  wmuti_sl.setNumberFormat(G4P.DECIMAL, 2);
  wmuti_sl.setOpaque(false);
  wmuti_sl.addEventHandler(this, "wmuti_sl_change");
  label9 = new GLabel(progSetupWin, 13, 429, 178, 20);
  label9.setText("Weight Mutation Intensity");
  label9.setOpaque(false);
  wd_tf = new GTextField(progSetupWin, 352, 239, 120, 18, G4P.SCROLLBARS_NONE);
  wd_tf.setText("1.4");
  wd_tf.setOpaque(true);
  wd_tf.addEventHandler(this, "wd_tf_change");
  label10 = new GLabel(progSetupWin, 200, 214, 158, 20);
  label10.setText("Speciation Settings");
  label10.setOpaque(false);
  label11 = new GLabel(progSetupWin, 207, 239, 128, 20);
  label11.setText("Weight of Disjoints");
  label11.setOpaque(false);
  we_tf = new GTextField(progSetupWin, 352, 260, 120, 16, G4P.SCROLLBARS_NONE);
  we_tf.setText("1.4");
  we_tf.setOpaque(true);
  we_tf.addEventHandler(this, "we_tf_change");
  wdw_tf = new GTextField(progSetupWin, 352, 279, 120, 16, G4P.SCROLLBARS_NONE);
  wdw_tf.setText("0.8");
  wdw_tf.setOpaque(true);
  wdw_tf.addEventHandler(this, "wdw_tf_change");
  label12 = new GLabel(progSetupWin, 206, 258, 135, 20);
  label12.setText("Weight of Excesses");
  label12.setOpaque(false);
  label13 = new GLabel(progSetupWin, 206, 280, 142, 16);
  label13.setText("Weight of Weight Diff.");
  label13.setOpaque(false);
  label5 = new GLabel(progSetupWin, 205, 297, 142, 17);
  label5.setText("Compatability Thresh.");
  label5.setOpaque(false);
  ct_tf = new GTextField(progSetupWin, 352, 298, 120, 17, G4P.SCROLLBARS_NONE);
  ct_tf.setText("1.5");
  ct_tf.setOpaque(true);
  ct_tf.addEventHandler(this, "ct_tf_change");
  label14 = new GLabel(progSetupWin, 15, 265, 148, 20);
  label14.setText("Weight Init. Mean");
  label14.setOpaque(false);
  label15 = new GLabel(progSetupWin, 14, 310, 159, 20);
  label15.setText("Weight Init. Stddev");
  label15.setOpaque(false);
  wim_tf = new GTextField(progSetupWin, 16, 288, 120, 20, G4P.SCROLLBARS_NONE);
  wim_tf.setText("0.0");
  wim_tf.setOpaque(true);
  wim_tf.addEventHandler(this, "wim_tf_change");
  wis_tf = new GTextField(progSetupWin, 15, 331, 122, 19, G4P.SCROLLBARS_NONE);
  wis_tf.setText("1.0");
  wis_tf.setOpaque(true);
  wis_tf.addEventHandler(this, "wis_tf_change");
  quickgen_btn = new GButton(progSetupWin, 14, 530, 135, 50);
  quickgen_btn.setText("Train!!");
  quickgen_btn.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  quickgen_btn.addEventHandler(this, "quickgen_btn_click");
  label16 = new GLabel(progSetupWin, 16, 505, 156, 20);
  label16.setText("Start Training!");
  label16.setOpaque(false);
  label17 = new GLabel(progSetupWin, 316, 532, 173, 50);
  label17.setTextAlign(GAlign.LEFT, GAlign.TOP);
  label17.setText("Note: Clicking on the green buttons will close the setup window.");
  label17.setOpaque(false);
  progSetupWin.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow progSetupWin;
GLabel label1; 
GDropList progMode_dl; 
GLabel label2; 
GLabel label3; 
GTextField xmlFile_tf;
GTextField xmlSavePath_tf;
GButton loadXML_btn; 
GTextField pop_tf; 
GLabel label4; 
GCustomSlider wmutchan_sl; 
GLabel label6; 
GCustomSlider nnodechan_sl; 
GLabel label7; 
GLabel label8; 
GCustomSlider nconnchan_sl; 
GCustomSlider wmuti_sl; 
GLabel label9; 
GTextField wd_tf; 
GLabel label10; 
GLabel label11; 
GTextField we_tf; 
GTextField wdw_tf; 
GLabel label12; 
GLabel label13; 
GLabel label5; 
GTextField ct_tf; 
GLabel label14; 
GLabel label15; 
GTextField wim_tf; 
GTextField wis_tf; 
GButton quickgen_btn; 
GButton slowgen_btn; 
GLabel label16; 
GLabel label17; 
