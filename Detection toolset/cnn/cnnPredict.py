#import the necessary packages
import CiliaLenet
import numpy as np

# set data path
trainDataPath = "cnn\\trainData.mat"
trainLabelPath = "cnn\\trainLabel.mat"
weightsPath = "cnn\\alexnet_weights.hdf5"
augmentationMultiple = 24
tpThreshold = 0.5

# init model and predict
model = CiliaLenet.CiliaLenet(trainDataPath, trainLabelPath,
    model = 'alexnet')
model.SetNetParams(weightsPath = weightsPath)
(label, loss, accuracy) = model.Predict("cnn\\data.mat")

# reshape label and store
rawDataSize = np.int32(label.shape[0] / augmentationMultiple)
label = np.reshape(label,[augmentationMultiple, rawDataSize])
label = np.mean(label,axis=0)
label[label > tpThreshold] = 1
label[label <= tpThreshold] = 0
np.save('cnn\\label.npy', label)