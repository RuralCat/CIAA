from keras.models import Sequential, Model
from keras.layers import Flatten, Dense, Dropout, Reshape, Permute, Activation, \
    Input, merge
from keras.layers.convolutional import Convolution2D, MaxPooling2D, ZeroPadding2D
from keras.layers.normalization import BatchNormalization
from keras.regularizers import l2

BatchNorm = True
w_reg = 0.2

class DualAlexNet:
    @staticmethod
    def build(ciliaWidth, ciliaHeight, imageWidth, imageHeight,
              depth, classes, weightsPath = None):
        # init input
        ciliaInput = Input(shape=(ciliaHeight, ciliaWidth, depth),
                           name='ciliaInput')
        imageInput = Input(shape=(imageHeight, imageWidth, depth),
                           name='imageInput')
        # conv1 - cilia
        ciliaConv1 = Convolution2D(48, 11, 11, 
                                   W_regularizer=l2(w_reg))(ciliaInput)
        if BatchNorm:
            ciliaConv1 = BatchNormalization(axis=3)(ciliaConv1)
        ciliaConv1 = Activation("relu")(ciliaConv1)
        ciliaConv1 = MaxPooling2D(pool_size=(3,3), strides=(2,2))(ciliaConv1)
        
        # conv2 - cilia
        ciliaConv2 = ZeroPadding2D((2,2), dim_ordering='tf')(ciliaConv1)
        ciliaConv2 = Convolution2D(64, 5, 5, W_regularizer=l2(w_reg))(ciliaConv2)
        if BatchNorm:
            ciliaConv2 = BatchNormalization(axis=3)(ciliaConv2)
        ciliaConv2 = Activation("relu")(ciliaConv2)
        ciliaConv2 = MaxPooling2D(pool_size=(3, 3), strides=(2, 2))(ciliaConv2)

        # conv1 - image
        imageConv1 = Convolution2D(48, 11, 11, subsample=(2,2),
                                   W_regularizer=l2(w_reg))(imageInput)
        if BatchNorm:
            imageConv1 = BatchNormalization(axis=3)(imageConv1)
        imageConv1 = Activation('relu')(imageConv1)
        imageConv1 = MaxPooling2D(pool_size=(3,3), strides=(2,2))(imageConv1)
        
        # conv2 - image
        imageConv2 = ZeroPadding2D((2, 2), dim_ordering='tf')(imageConv1)
        imageConv2 = Convolution2D(64, 5, 5, W_regularizer=l2(w_reg))(imageConv2)
        if BatchNorm:
            imageConv2 = BatchNormalization(axis=3)(imageConv2)
        imageConv2 = Activation("relu")(imageConv2)
        imageConv2 = MaxPooling2D(pool_size=(3, 3), strides=(2, 2))(imageConv2)

        # merge conv3
        conv3 = merge([ciliaConv2, imageConv2], mode='concat', concat_axis=3)
        conv3 = ZeroPadding2D((1,1), dim_ordering='tf')(conv3)
        conv3 = Convolution2D(96, 3, 3, W_regularizer=l2(w_reg))(conv3)
        if BatchNorm:
            conv3 = BatchNormalization(axis=3)(conv3)
        conv3 = Activation('relu')(conv3)
        
        # conv4
        conv4 = ZeroPadding2D((1, 1), dim_ordering='tf')(conv3)
        conv4 = Convolution2D(96, 3, 3, W_regularizer=l2(w_reg))(conv4)
        if BatchNorm:
            conv4 = BatchNormalization(axis=3)(conv4)
        conv4 = Activation('relu')(conv4)
        
        # conv5
        conv5 = ZeroPadding2D((1, 1), dim_ordering='tf')(conv4)
        conv5 = Convolution2D(64, 3, 3, W_regularizer=l2(w_reg))(conv5)
        if BatchNorm:
            conv5 = BatchNormalization(axis=3)(conv5)
        conv5 = Activation('relu')(conv5)
        conv5 = MaxPooling2D(pool_size=(3,3), strides=(1,1))(conv5)

        # fc1
        fc1 = Flatten()(conv5)
        fc1 = Dense(384,activation='relu')(fc1)
        fc1 = Dropout(0.5)(fc1)

        # fc2
        fc2 = Dense(384, activation='relu')(fc1)
        fc2 = Dropout(0.5)(fc2)

        # softmax classifier
        output = Dense(classes, activation='softmax', name='ciliaOutput')(fc2)

        # create model
        model = Model([ciliaInput, imageInput], output)

        # load weights if a weights path is supplied
        if weightsPath:
            model.load_weights(weightsPath)

        return model
        



