
# import the necessary packages
from keras.models import Model
from keras.layers import Flatten, Dense, Input, BatchNormalization,\
    merge, Convolution2D, MaxPooling2D, AveragePooling2D


def conv2d_bn(x, nb_filter, nb_row, nb_col,
              border_mode='same', subsample=(1, 1),
              name=None):
    '''Utility function to apply conv + BN.
    '''
    if name is not None:
        bn_name = name + '_bn'
        conv_name = name + '_conv'
    else:
        bn_name = None
        conv_name = None
    bn_axis = 3
    x = Convolution2D(nb_filter, nb_row, nb_col,
                      subsample=subsample,
                      activation='relu',
                      border_mode=border_mode,
                      name=conv_name)(x)
    x = BatchNormalization(axis=bn_axis, name=bn_name)(x)
    return x

class Inception:
    @staticmethod
    def build(ciliaWidth, ciliaHeight, depth,
              classes, weightsPath='None', includeTop=True):
        # default input is 299x299
        inputShape = (ciliaWidth, ciliaHeight, depth)
        ciliaInput = Input(inputShape)
        channelAxis = 3

        x = conv2d_bn(ciliaInput, 32, 3, 3, subsample=(1, 1), border_mode='valid')
        x = conv2d_bn(x, 32, 3, 3, border_mode='valid')
        x = conv2d_bn(x, 64, 3, 3)
        x = MaxPooling2D((3, 3), strides=(1, 1))(x)

        x = conv2d_bn(x, 40, 1, 1, border_mode='valid')  # 80
        x = conv2d_bn(x, 96, 3, 3, border_mode='valid') # 192
        x = MaxPooling2D((3, 3), strides=(2, 2))(x)

        # mixed 0, 1, 2: 35 x 35 x 256
        for i in range(3):
            branch1x1 = conv2d_bn(x, 32, 1, 1) # 64

            branch5x5 = conv2d_bn(x, 24, 1, 1) # 24
            branch5x5 = conv2d_bn(branch5x5, 32, 5, 5) # 64

            branch3x3dbl = conv2d_bn(x, 32, 1, 1) # 64
            branch3x3dbl = conv2d_bn(branch3x3dbl, 48, 3, 3) # 48
            branch3x3dbl = conv2d_bn(branch3x3dbl, 48, 3, 3) # 48

            branch_pool = AveragePooling2D(
                (3, 3), strides=(1, 1), border_mode='same')(x)
            branch_pool = conv2d_bn(branch_pool, 32, 1, 1) # 32
            x = merge([branch1x1, branch5x5, branch3x3dbl, branch_pool],
                      mode='concat', concat_axis=channelAxis,
                      name='mixed' + str(i))

        # mixed 3: 17 x 17 x 768
        branch3x3 = conv2d_bn(x, 192, 3, 3, subsample=(2, 2), border_mode='valid') # 384

        branch3x3dbl = conv2d_bn(x, 32, 1, 1) # 64
        branch3x3dbl = conv2d_bn(branch3x3dbl, 48, 3, 3) # 96
        branch3x3dbl = conv2d_bn(branch3x3dbl, 48, 3, 3, # 48
                                 subsample=(2, 2), border_mode='valid')

        branch_pool = MaxPooling2D((3, 3), strides=(2, 2))(x)
        x = merge([branch3x3, branch3x3dbl, branch_pool],
                  mode='concat', concat_axis=channelAxis,
                  name='mixed3')

        # mixed 4: 17 x 17 x 768
        branch1x1 = conv2d_bn(x, 96, 1, 1) # 96

        branch7x7 = conv2d_bn(x, 64, 1, 1) # 128
        branch7x7 = conv2d_bn(branch7x7, 64, 1, 7) # 128
        branch7x7 = conv2d_bn(branch7x7, 96, 7, 1) # 96

        branch7x7dbl = conv2d_bn(x, 64, 1, 1) # 128
        branch7x7dbl = conv2d_bn(branch7x7dbl, 64, 7, 1) # 128
        branch7x7dbl = conv2d_bn(branch7x7dbl, 64, 1, 7) # 128
        branch7x7dbl = conv2d_bn(branch7x7dbl, 64, 7, 1) # 128
        branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 1, 7) # 192

        branch_pool = AveragePooling2D((3, 3), strides=(1, 1), border_mode='same')(x)
        branch_pool = conv2d_bn(branch_pool, 96, 1, 1) # 192
        x = merge([branch1x1, branch7x7, branch7x7dbl, branch_pool],
                  mode='concat', concat_axis=channelAxis,
                  name='mixed4')

        # mixed 5, 6: 17 x 17 x 768
        for i in range(2):
            branch1x1 = conv2d_bn(x, 96, 1, 1) # 192

            branch7x7 = conv2d_bn(x, 80, 1, 1) # 160
            branch7x7 = conv2d_bn(branch7x7, 80, 1, 7) # 160
            branch7x7 = conv2d_bn(branch7x7, 96, 7, 1) # 192

            branch7x7dbl = conv2d_bn(x, 80, 1, 1) # 160
            branch7x7dbl = conv2d_bn(branch7x7dbl, 80, 7, 1) # 160
            branch7x7dbl = conv2d_bn(branch7x7dbl, 80, 1, 7) # 160
            branch7x7dbl = conv2d_bn(branch7x7dbl, 80, 7, 1) # 160
            branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 1, 7) # 192

            branch_pool = AveragePooling2D(
                (3, 3), strides=(1, 1), border_mode='same')(x)
            branch_pool = conv2d_bn(branch_pool, 96, 1, 1) # 192
            x = merge([branch1x1, branch7x7, branch7x7dbl, branch_pool],
                      mode='concat', concat_axis=channelAxis,
                      name='mixed' + str(5 + i))

        # mixed 7: 17 x 17 x 768
        branch1x1 = conv2d_bn(x, 96, 1, 1) # 192

        branch7x7 = conv2d_bn(x, 96, 1, 1) # 192
        branch7x7 = conv2d_bn(branch7x7, 96, 1, 7) # 192
        branch7x7 = conv2d_bn(branch7x7, 96, 7, 1) # 192

        branch7x7dbl = conv2d_bn(x, 80, 1, 1) # 160
        branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 7, 1) # 192
        branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 1, 7) # 192
        branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 7, 1) # 192
        branch7x7dbl = conv2d_bn(branch7x7dbl, 96, 1, 7) # 192

        branch_pool = AveragePooling2D((3, 3), strides=(1, 1), border_mode='same')(x)
        branch_pool = conv2d_bn(branch_pool, 96, 1, 1) # 192
        x = merge([branch1x1, branch7x7, branch7x7dbl, branch_pool],
                  mode='concat', concat_axis=channelAxis,
                  name='mixed7')

        # mixed 8: 8 x 8 x 1280
        branch3x3 = conv2d_bn(x, 96, 1, 1) # 192
        branch3x3 = conv2d_bn(branch3x3, 160, 3, 3, # 320
                              subsample=(2, 2), border_mode='valid')

        branch7x7x3 = conv2d_bn(x, 96, 1, 1) # 192
        branch7x7x3 = conv2d_bn(branch7x7x3, 96, 1, 7) # 192
        branch7x7x3 = conv2d_bn(branch7x7x3, 96, 7, 1) # 192
        branch7x7x3 = conv2d_bn(branch7x7x3, 96, 3, 3, # 192
                                subsample=(2, 2), border_mode='valid')

        branch_pool = AveragePooling2D((3, 3), strides=(2, 2))(x)
        x = merge([branch3x3, branch7x7x3, branch_pool],
                  mode='concat', concat_axis=channelAxis,
                  name='mixed8')

        # mixed 9: 8 x 8 x 2048
        for i in range(2):
            branch1x1 = conv2d_bn(x, 160, 1, 1) # 160

            branch3x3 = conv2d_bn(x, 192, 1, 1) # 384
            branch3x3_1 = conv2d_bn(branch3x3, 192, 1, 3) # 384
            branch3x3_2 = conv2d_bn(branch3x3, 192, 3, 1) # 384
            branch3x3 = merge([branch3x3_1, branch3x3_2],
                              mode='concat', concat_axis=channelAxis,
                              name='mixed9_' + str(i))

            branch3x3dbl = conv2d_bn(x, 224, 1, 1) # 448
            branch3x3dbl = conv2d_bn(branch3x3dbl, 192, 3, 3) # 384
            branch3x3dbl_1 = conv2d_bn(branch3x3dbl, 192, 1, 3) # 384
            branch3x3dbl_2 = conv2d_bn(branch3x3dbl, 192, 3, 1) # 384
            branch3x3dbl = merge([branch3x3dbl_1, branch3x3dbl_2],
                                 mode='concat', concat_axis=channelAxis)

            branch_pool = AveragePooling2D(
                (3, 3), strides=(1, 1), border_mode='same')(x)
            branch_pool = conv2d_bn(branch_pool, 96, 1, 1) # 192
            x = merge([branch1x1, branch3x3, branch3x3dbl, branch_pool],
                      mode='concat', concat_axis=channelAxis,
                      name='mixed' + str(9 + i))

        if includeTop:
            # Classification block
            x = AveragePooling2D((8, 8), strides=(8, 8), name='avg_pool')(x)
            x = Flatten(name='flatten')(x)
            x = Dense(classes, activation='softmax', name='predictions')(x)

        # Create model
        model = Model(ciliaInput, x)

        # load weights if a weights path is supplied
        if weightsPath:
            model.load_weights(weightsPath)

        return model
