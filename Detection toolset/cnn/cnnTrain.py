
from CiliaNet import CiliaNet
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

# read hyperPara from file
fid = open('cnn\hyperPara.txt');
tmp = fid.readline()
rootPath = fid.readline().strip()
learningRate = float(fid.readline().strip())
momentum = float(fid.readline().strip())
learningRateDecay = float(fid.readline().strip())
epoch = int(fid.readline().strip())
batchSize = int(fid.readline().strip())
earlyStopping = int(fid.readline().strip())

# define training set path
trainDataPath = rootPath + "\\trainData.mat"
trainLabelPath = rootPath + "\\trainLabel.mat"
valDataPath = rootPath + "\\valData.mat"
valLabelPath = rootPath + "\\valLabel.mat"
trainImagePath = rootPath + '\\trainImageData.mat'
valImagePath = rootPath + '\\valImageData.mat'

# define parameters to determine if PRETRAIN etc.
modelName = 'cilianet'
saveModelPath = rootPath + '\\DualAlexNet_' + \
    datetime.now().strftime('%m%d_') + 'Model.hdf5'
saveMeanPath = saveModelPath[:-10]

# create model
model = CiliaNet(trainDataPath, trainLabelPath,
                 valDataPath, valLabelPath,
                 trainImagePath, valImagePath,
                 True, saveMeanPath,
                 model=modelName)
model.CreateModel(learningRate=learningRate, 
                  momentum=momentum, 
                  decay=learningRateDecay)
# train
model.Train(epoch, batchSize, True, saveModelPath, earlyStopping)
# predict
valLabel = CiliaNet.PredictFromFile(valDataPath, valImagePath,
                                    True, saveModelPath,
                                    True, saveMeanPath)
traLabel = CiliaNet.PredictFromFile(trainDataPath, trainImagePath,
                                    True, saveModelPath,
                                    True, saveMeanPath)
# save
np.save(rootPath + '\\valLabel.npy', valLabel)
np.save(rootPath + '\\trainLabel.npy', traLabel)
