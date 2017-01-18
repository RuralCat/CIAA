#import the necessary packages
from CiliaNet import CiliaNet
import numpy as np

# set data path
meanPath = "cnn\\DualAlexNet"
modelPath = "cnn\\DualAlexNetModel.hdf5"
dataPath = "cnn\\testData.mat"
imagePath = "cnn\\imageData.mat"
augmentationMultiple = 16
tpThreshold = 0.5

# init model and predict
label = CiliaNet.PredictFromFile(dataPath, imagePath, 
                                 True, modelPath, 
                                 True, meanPath)

# reshape label and store
rawDataSize = np.int32(label.shape[0] / augmentationMultiple)
label = np.reshape(label,[augmentationMultiple, rawDataSize])
label = np.mean(label,axis=0)
label[label > tpThreshold] = 1
label[label <= tpThreshold] = 0
np.save('cnn\\label.npy', label)