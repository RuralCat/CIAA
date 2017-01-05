from keras.models import Sequential, Model
from keras.layers import Flatten, Dense, Dropout, Reshape, Permute, Activation, \
    Input, merge
from keras.layers.convolutional import Convolution2D, MaxPooling2D, ZeroPadding2D

from keras.layers.normalization import BatchNormalization

from keras.regularizers import l2, activity_l2

BatchNorm = True
w_reg = 0.1
activity_reg = 0.01

class AlexNet:
    @staticmethod
    def build(width, height, depth, classes, weightsPath = None):
        # initialize the model
        model = Sequential()

        #conv1
        model.add(Convolution2D(48, 11, 11, subsample=(1,1), W_regularizer=l2(w_reg), input_shape=(height, width, depth)))
        if BatchNorm:
            model.add(BatchNormalization(axis=1))
        model.add(Activation("relu"))
        model.add(MaxPooling2D(pool_size=(3,3), strides=(2,2)))

        # conv2
        model.add(ZeroPadding2D((2,2), dim_ordering='tf'))
        model.add(Convolution2D(64, 5, 5, W_regularizer=l2(w_reg)))
        if BatchNorm:
            model.add(BatchNormalization(axis=1))
        model.add(Activation("relu"))
        model.add(MaxPooling2D(pool_size=(3,3), strides=(2,2)))

        # conv3
        model.add(ZeroPadding2D((1,1), dim_ordering='tf'))
        model.add(Convolution2D(96, 3, 3, W_regularizer=l2(w_reg)))
        if BatchNorm:
            model.add(BatchNormalization(axis=1))
        model.add(Activation("relu"))
        
        # conv4
        model.add(ZeroPadding2D((1,1), dim_ordering='tf'))
        model.add(Convolution2D(96, 3, 3, W_regularizer=l2(w_reg)))
        if BatchNorm:
            model.add(BatchNormalization(axis=1))
        model.add(Activation("relu"))

        # conv5
        model.add(ZeroPadding2D((1,1), dim_ordering='tf'))
        model.add(Convolution2D(64, 3, 3, W_regularizer=l2(w_reg)))
        if BatchNorm:
            model.add(BatchNormalization(axis=1))
        model.add(Activation("relu"))
        model.add(MaxPooling2D(pool_size=(3,3), strides=(1,1)))

        # fc1
        model.add(Flatten())
        model.add(Dense(384))
        model.add(Activation("relu"))
        model.add(Dropout(0.5))

        # fc2
        model.add(Dense(384))
        model.add(Activation("relu"))
        model.add(Dropout(0.5))

        # softmax classifier
        model.add(Dense(classes))
        model.add(Activation("softmax"))
        
        # load weights if a weights path is supplied
        if weightsPath:
            model.load_weights(weightsPath)

        return model
