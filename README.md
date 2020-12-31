# NEAT_Cars

  I wanted to make a project using genetic algorithms for a long time so I decided to write an implementation of NeuroEvolution of Augmenting Topologies (NEAT) and train it to do something.

  I'm a Tesla fanboy so it's about cars.


**Goal:** Use NEAT to evolve artificial neural networks that have the ability to steer a 2D car around curved courses.

Driving Example:
![KAnsei Dorifto??](https://raw.githubusercontent.com/tdude92/NEAT_Cars/main/car_drive_demo.gif)

GUI Example:
![Interface Demo](https://raw.githubusercontent.com/tdude92/NEAT_Cars/main/gensummary_demo.png)
Note 1: Input sizes of the nets are different from the Driving Example because I added two more "vision lines" to the front of the car (in hopes of beating the Impossible Hairpins track. Alas, my efforts were fruitless lol)

Note 2: There's a big chunk of neural nets to the left of the normal distribution (on the Fitness Distribution chart) due to mutations that cause them to drive into the walls.


NEAT Paper: http://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf

Car Physics: https://asawicki.info/Mirror/Car%20Physics%20for%20Games/Car%20Physics%20for%20Games.html (My implementation is sketchy)
