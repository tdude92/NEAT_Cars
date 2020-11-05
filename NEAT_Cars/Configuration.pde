/* Default values for program constants         */
/* Values can be set here or updated in the GUI */

// Weight initialization
// The initial values of weights will be sampled from a Gaussian distribution.
float WEIGHT_INIT_MEAN   = 0.0;
float WEIGHT_INIT_STDDEV = 1.0;

// Mutation chances
float NEW_NODE_CHANCE        = 0.03; // Chance of mutating a new node.
float NEW_CONN_CHANCE        = 0.05; // Chance of mutating a new connection.
float WEIGHT_MUTATION_CHANCE = 0.8;  // Chance of weight mutating in offspring.
float WEIGHT_REASSIGN_CHANCE = 0.1;  // Chance of the mutation being a reassignment to a random value.
                                     // If weight will not be reassigned, perturb it slightly.
                                    
float PERTURBATION_BOUND = 0.2;      // Bounds of the random perturbation (-bound <= perturb < bound). Should be > 0.

// Genome comparison weights
float CW_E  = 1.0; // Weight of excess genes.
float CW_D  = 1.0; // Weight of disjoint genes.
float CW_DW = 0.4; // Weight of average weight difference of matching genes.

float COMPATABILITY_THRESHOLD = 1.0; // Maximum compatability between two genomes while still being considered the same species.

// Natural selection and reproduction
float CULL_PERCENT = 0.25; // Percentage of the population that is not allowed to reproduce at the end of a generation.
float CHANCE_NO_CROSSOVERS = 0.25;
float CHANCE_INTERSPECIES = 0.001; // Unimplemented TODO

/* SIMULATION CONSTANTS */

// Simulation description:
// 5 units in the coordinate system is equivalent to 1 meter
// The units that will be used are: m, m/s, m/s^2

float FRAMERATE = 60;
float DT = 1/FRAMERATE; // Seconds between frames
