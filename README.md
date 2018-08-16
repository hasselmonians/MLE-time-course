# MLE-time-course
Estimate the bandwidth parameter for smoothing spike-train data.

## What is this?
Firing rate is a convenient mathematical construct useful in analyzing spike trains. It's believed that firing rate (measured in number of spikes per unit time) plays an important role in neural coding. Since actual spike-timing is somewhat stochastic, determining the firing rate is often non-trivial. A [2001 paper](https://www.ncbi.nlm.nih.gov/pubmed/21732865) describes a method by which Bayesian likelihood analysis and leave-one-out cross-validation can be used to determine an optimal bandwidth parameter for use in turning point-process spike-train data into smoothed firing rate vs. time curves.

## How do I use it?
This toolbox is designed to be as general as possible. As long as your spike trains are vectors or matrices, you should be all set! Of course, at the moment, nothing is ready to go, so please be patient.

The project is written in `MATLAB`. You will need to make sure that you have the following dependencies
* None at the moment
