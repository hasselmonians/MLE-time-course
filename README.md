# MLE-time-course
Estimate the bandwidth parameter for smoothing spike-train data.

## What is this?
Firing rate is a convenient mathematical construct useful in analyzing spike trains. It's believed that firing rate (measured in number of spikes per unit time) plays an important role in neural coding. Since actual spike-timing is somewhat stochastic, determining the firing rate is often non-trivial. A [2011 paper](https://www.ncbi.nlm.nih.gov/pubmed/21732865) describes a method by which Bayesian likelihood analysis and leave-one-out cross-validation can be used to determine an optimal bandwidth parameter for use in turning point-process spike-train data into smoothed firing rate vs. time curves.

## How do I use it?
The core files are packed within `BandwidthEstimator`. `MLE-time-course` contains the scripts and `.xsl` files to build `.pdf`s with text and figures.

* `getSpikeTimes`. Produces a vector of spike times from a `CMBHOME` Session object.
* `getSpikeTrain`. Produces a binned spike train vector, where the bin size is determined by the video sample size (for _in-vivo_ recordings).
* `cvKernel`. Perform the leave-one-out cross-validated maximum likelihood analysis. This is the main function in the project. The second output is the best estimate for the bandwidth parameter in units of time-steps. Multiply by the time-step (`1/root.fs_video`) to get the actual bandwidth in seconds.
* `getFiringRate`. Produces a vector of the convolved binned spike train given a known bandwidth parameter.

The project is written in `MATLAB`. You will need to make sure that you have the following dependencies
* The analysis structures (e.g. [BandwidthEstimator](https://github.com/hasselmonians/BandwidthEstimator)) expects [CMBHOME](https://github.com/hasselmonians/CMBHOME) `Session` objects for the constructor to work, though in theory, any spike train should be perfectly fine.
* [`mtools`](https://github.com/sg-s/srinivas.gs_mtools) by Srinivas Gorur-Shandilya is used extensively for handy little functions.
* You will likely want [`RatCatcher`](https://github.com/hasselmonians/RatCatcher) to generate scripts to run batches of analyses on cluster computers (using `qsub`).

### Acknowledgements
* Stephen Cobeldick developed the `natsort` tools (included in `RatCatcher`).
* Michael Prerau and Uri Eden developed the MLE/CV bandwidth parameter estimation algorithm (included in `BandwidthEstimator`).
