
# import the necessary packages
from keras.models import load_model
from keras.optimizers import SGD
from keras.utils import np_utils
from keras.callbacks import EarlyStopping, ModelCheckpoint, TensorBoard
# from keras.utils.visualize_util import plot as  kerasplot
import numpy as np
import h5py
from alexnet import AlexNet
from DualAlexNet import DualAlexNet
from lenet import LeNet
from Inception import Inception


class CiliaNet(object):
    # construction function
    def __init__(self, data, label,
                 valdata = None, vallabel = None,
                 imagedata = None, valimagedata = None,
                 saveMean = False, meanFile = None,
                 model = 'lenet'):
        # if data is a file path, load it from disk
        self.data = self.ReadMatData(data)
        self.label = self.ReadMatLabel(label)
        self.valdata = self.ReadMatData(valdata)
        self.vallabel = self.ReadMatLabel(vallabel)
        self.imagedata = self.ReadMatData(imagedata)
        self.valImagedata = self.ReadMatData(valimagedata)
        # pre-processing data (subtract data mean)
        self.dataMean = np.mean(self.data,axis=0)
        self.data -= self.dataMean
        if self.valdata is not None:
            self.valdata -= self.dataMean
        if self.imagedata is not None:
            self.imageMean = np.mean(self.imagedata, axis=0)
            self.imagedata -= self.imageMean
            self.valImagedata -= self.imageMean
        # save model mode
        self.modelMode = model
        # init weights and other parameters
        self.weights = None
        self.trainData = self.data[:self.data.shape[0],:,:,:]
        self.trainLabel = self.label[:self.data.shape[0],:]
        if self.imagedata is not None and self.modelMode is 'cilianet':
            self.trainData = [self.trainData,
                              self.imagedata[:self.imagedata.shape[0],:,:,:]]
            self.valdata = [self.valdata, self.valImagedata]
        # create model
        self.CreateModel()
        # save mean value
        if saveMean:
            np.save(meanFile + '_dataMean.npy', self.dataMean)
            np.save(meanFile + '_imageMean.npy', self.imageMean)

    def CreateModel(self, weights = None,
                    learningRate = 1e-4, momentum = 0.95, decay = 1e-3):
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
        elif self.modelMode is 'cilianet':
            self.Model = DualAlexNet.build(self.data.shape[1],
                                        self.data.shape[2],
                                        self.imagedata.shape[1],
                                        self.imagedata.shape[2],
                                        self.imagedata.shape[3],
                                        2,
                                        weights)
        elif self.modelMode is 'inception':
            self.Model = Inception.build(self.data.shape[1],
                                         self.data.shape[2],
                                         self.data.shape[3],
                                         2,
                                         weights)
        opt = SGD(lr=learningRate, momentum=momentum,
                  decay = decay, nesterov=True)
        self.Model.compile(loss="binary_crossentropy",
                           optimizer=opt,
                           metrics=["binary_accuracy"])

    # set parameters
    def SetNetParams(self, sampleSize = None, weightsPath = None,
                     learningRate = 0.001):
        if isinstance(sampleSize, int):
            self.trainData = self.data[:sampleSize, :, :, :]
            self.trainLabel = self.label[:sampleSize, :]
        if self.imagedata is not None:
            self.trainData = [self.trainData,
                              self.imagedata[:sampleSize, :, :, :]]
        if isinstance(weightsPath, str):
            self.CreateModel(weightsPath, learningRate)

    @staticmethod
    def ReadMatData(data):
        # read matlab data using h5py package
        if isinstance(data, str):
            dataFile = h5py.File(data)
            data = np.array(dataFile.get('data'),'float32')
        if data is not None:
            data /= 255.0

        return data

    @staticmethod
    def ReadMatLabel(label):
        # read matlab label
        if isinstance(label, str):
            label = np.array(h5py.File(label).get('label'), 'uint8')
        if label is not None:
            return np_utils.to_categorical(label,2)
        else:
            return label

    def Train(self, epoch = 1000, batchSize=128,
              saveModel = False, savePath = None,
              earlyStop = True):
        if earlyStop:
            pat = 25
        else:
            pat = epoch
        earlyStopping = EarlyStopping(monitor='binary_accuracy',
                                      min_delta=0.01,
                                      patience=pat)
        checkPoint = ModelCheckpoint(savePath,
                                     monitor='val_binary_accuracy',
                                     save_best_only=True,
                                     save_weights_only=False)
        tensorBoard = TensorBoard(log_dir=(savePath[:-5] + '.log'))
        if self.valdata is None:
            self.history = self.Model.fit(self.trainData,
                                          self.trainLabel,
                                          batch_size=batchSize,
                                          nb_epoch=epoch,
                                          verbose=1,
                                          validation_split=0.1,
                                          callbacks=[earlyStopping,
                                                     checkPoint])
        else:
            self.history = self.Model.fit(self.trainData,
                                          self.trainLabel,
                                          batch_size=batchSize,
                                          nb_epoch=epoch,
                                          verbose=1,
                                          validation_data=(self.valdata,self.vallabel),
                                          callbacks=[earlyStopping,
                                                     checkPoint])
        # if saveModel:
        #     self.Model.save_weights(savePath, overwrite=True)

    def Predict(self, testData,
                testLabel = None, testImage = None):
        self.testData = self.ReadMatData(testData) - self.dataMean
        self.testLabel = self.ReadMatLabel(testLabel)
        if testImage is not None and self.modelMode is 'cilianet':
            testImage = self.ReadMatData(testImage) - self.imageMean
            self.testData = [self.testData, testImage]
        # read label if it is not a none object
        label = self.Model.predict(self.testData)
        label = np.argmax(label, axis=1)

        return label

    @staticmethod
    def PredictFromFile(testData, testImage = None,
                        loadModel = False, modelFile = None,
                        loadMean = False, meanFile = None):
        # load mean value from file
        if loadMean and (meanFile is not None):
            dataMean = np.load(meanFile + '_dataMean.npy')
        testData = CiliaNet.ReadMatData(testData) - dataMean
        if loadMean and (testImage is not None):
            imageMean = np.load(meanFile + '_imageMean.npy')
            testImage = CiliaNet.ReadMatData(testImage) - imageMean
            testData = [testData, testImage]
        # load model from file
        if loadModel and (modelFile is not None):
            model = load_model(modelFile)
        # predict label
        label = model.predict(testData)
        label = np.argmax(label, axis=1)

        return label






