Run main.m to start detection toolset.
There is a detailed help document in toolset.

Update log:
1. v0.2 -> v0.3
(1) add two slider to control snr threshold and direction threshold
(2) add TrainingSetView tool to view saved training set
(3) add detection method to remove white proportional scale

2. v0.3 -> v0.4
(1) modify training set's saved method
(2) add a window in TrainingSetView tool to view cilia position in full image
(3) add a 'Cnn Predict' button to view a beta cnn's prediction
(4) reorganize code file
(5) add 'cnn training tool' to train a better net from better training set

3. v0.4 -> v0.5
(1) add method to process different types of image
(2) add method to count nuclei
(3) modifed the method for calculating cilia length
(4) add a timer to get manual analysis's time
(5) export cilia analysis report (excel or text)