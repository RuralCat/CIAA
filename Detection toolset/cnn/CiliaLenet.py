
# import the necessary packages
from lenet import LeNet
from sklearn.cross_validation import train_test_split
from keras.optimizers import SGD
from keras.utils import np_utils
import numpy as np
import h5py
from alexnet import AlexNet


class CiliaLenet(object):
    # construction function
    def __init__(self, data, label, valdata = None, vallabel = None, model = 'lenet'):
        # if data is a file path, load it from disk
        self.data = self.ReadMatData(data)
        self.label = self.ReadMatLabel(label)
        self.valdata = self.ReadMatData(valdata)
        self.vallabel = self.ReadMatLabel(vallabel)
        # pre-processing data (subtract data mean)
        self.dataMean = np.mean(self.data,axis=0)
        self.data -= self.dataMean
        if self.valdata is not None:
            self.valdata -= self.dataMean
        # save model mode
        self.modelMode = model
        # init weights and other parameters
        self.weights = None
        self.trainData = self.data[:self.data.shape[0],:,:,:]
        self.trainLabel = self.label[:self.data.shape[0],:]
        # create model
        self.CreateModel()

    def CreateModel(self, weights = None, learningRate = 0.001):
        # create train model
        if self.modelMode is 'lenet':
            self.Model = LeNet.build(self.data.shape[1],
                                      self.data.shape[2],
                                      self.data.shape[3],
                                      2,
                                      weights)
        elif self.modelMode is 'alexnet':
            self.Model = AlexNet.build(self.data.shape[1],
                                       self.data.shape[2],
                                       self.data.shape[3],
                                       2,
                                       weights)
        opt = SGD(lr=learningRate, momentum=0.99, decay = 0.008, nesterov=True)
        self.Model.compile(loss="binary_crossentropy",
                           optimizer=opt,
                           metrics=["binary_accuracy"])

    # set parameters
    def SetNetParams(self, sampleSize = None, weightsPath = None,
                     learningRate = 0.001):
        if isinstance(sampleSize, int):
            self.trainData = self.data[:sampleSize, :, :, :]
            self.trainLabel = self.label[:sampleSize, :]
        if isinstance(weightsPath, str):
            self.CreateModel(weightsPath, learningRate)

    def ReadMatData(self, data):
        # read matlab data using h5py package
        if isinstance(data, str):
            dataFile = h5py.File(data)
            data = np.array(dataFile.get('data'),'float32')
        if data is not None:
            data /= 255.0

        return data

    def ReadMatLabel(self, label):
        # read matlab label
        if isinstance(label, str):
            label = np.array(h5py.File(label).get('label'), 'uint8')
        if label is not None:
            return np_utils.to_categorical(label,2)
        else:
            return label

    def Train(self, epoch = 1000, saveModel = False, savePath = None):
        if self.valdata is None:
            self.history = self.Model.fit(self.trainData,
                                           self.trainLabel,
                                           batch_size=128,
                                           nb_epoch=epoch,
                                           verbose=1,
                                           validation_split=0.1)
        else:
            self.history = self.Model.fit(self.trainData,
                                               self.trainLabel,
                                               batch_size=128,
                                               nb_epoch=epoch,
                                               verbose=1,
                                               validation_data=(self.valdata,self.vallabel))
        if saveModel:
            self.Model.save_weights(savePath, overwrite=True)

    def Predict(self, testData, testLabel = None):
        self.testData = self.ReadMatData(testData) - self.dataMean
        self.testLabel = self.ReadMatLabel(testLabel)
        # read label if it is not a none object
        if testLabel is not None:
            (loss, accuracy) = self.Model.evaluate(self.testData,
                                                    self.testLabel)
        else:
            loss = 0.0
            accuracy = 0.0
        label = self.Model.predict_classes(self.testData, batch_size=128)

        return label, loss, accuracy





