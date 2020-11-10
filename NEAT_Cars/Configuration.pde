/* Program parameters */
// All undefined parameters will be set by the GUI

// TRAINING CONSTANTS
int POPULATION = 1000;
Activation DEFAULT_ACTIVATION = new Sigmoid(4.9);

// Weight initialization
// The initial values of weights will be sampled from a Gaussian distribution.
float WEIGHT_INIT_MEAN = 0.0;
float WEIGHT_INIT_STDDEV = 1.0;

// Mutation chances
float NEW_NODE_CHANCE = 0.03; // Chance of mutating a new node.
float NEW_CONN_CHANCE = 0.05; // Chance of mutating a new connection.
float WEIGHT_MUTATION_CHANCE = 0.8;  // Chance of weight mutating in offspring.
                                    
float PERTURBATION_BOUND = 0.2; // Bounds of the random perturbation (-bound <= perturb < bound). Should be > 0.

// Genome comparison weights
float CW_E = 1.4; // Weight of excess genes.
float CW_D = 1.4; // Weight of disjoint genes.
float CW_DW = 0.8; // Weight of average weight difference of matching genes.

float COMPATABILITY_THRESHOLD = 1.5; // Maximum compatability between two genomes while still being considered the same species.

// Natural selection and reproduction
float CULL_PERCENT = 0.25; // Percentage of the population that is not allowed to reproduce at the end of a generation.
float CHANCE_NO_CROSSOVERS = 0.25;

/* SIMULATION PARAMS AND FLAGS */

// Simulation description:
// 5 units in the coordinate system is equivalent to 1 meter
// The units that will be used are: m, m/s, m/s^2

float FRAMERATE = 60;
float DT = 1/FRAMERATE; // Seconds between frames
boolean VISION_LINES = true; // Draw car vision lines
boolean DRAW_CHECKPOINTS = true;
boolean TRAIN_INDEF = false; // Set in the generation summary. Generation summary doesn't wait for user if true.
boolean SIM_START = false; // Set to true when setup is finished
String GENOME_SAVE_PATH = "model/car.xml"; // Path to save trained Genome XMLs. Set by GUI
String TRACK_FILE_PATH = "racetracks/easy_tck.txt";

// EVAL MODE PARAMS
boolean EVAL_MODE = false; // false => training mode
Genome EVAL_GENOME; // Genome used in the car during evaluation. Set by GUI
