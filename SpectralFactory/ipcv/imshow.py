import cv2
import hardware
import ipcv
import matplotlib.backends.backend_agg
import matplotlib.cm
import matplotlib.pyplot
import numpy

def imshow(im, windowName='Image', histogram=False, bitDepth=8, dpi=128.5):

   # Determine the numnber of grey levels
   numberLevels = 2**bitDepth

   # Normalize the image so that it falls in the range [0, 1]
   normalizedImage = (im / float(numberLevels-1)).astype(numpy.float32)

   # Reverse the channel order (BGR to RGB) for color images (assumption is
   # that OpenCV-style color images are provided)
   if len(im.shape) == 3:
      normalizedImage = cv2.cvtColor(normalizedImage, cv2.COLOR_BGR2RGB)

   # Determine the current screen size and set the figure size appropriately
   scale = 0.85
   screenSize = hardware.get_screen_size(dpi=dpi)
   if histogram:
      figureSize = [screenSize[3]*scale, screenSize[2]*scale]
   else:
      figureSize = [screenSize[2]*scale, screenSize[2]*scale]

   # Create a Matplotlib figure with the given title and a canvas to contain
   # this figure
   figure = matplotlib.pyplot.figure(windowName,
                                     figsize=[figureSize[0], 
                                              figureSize[1]])
   canvas = matplotlib.backends.backend_agg.FigureCanvasAgg(figure)

   # Add one or two subplot axes to the figure depending on whether or not
   # the histogram is to be displayed
   if histogram:
      figureRows = 2
      figureCols = 1
      axes1 = figure.add_subplot(figureRows, figureCols, 1)
      axes2 = figure.add_subplot(figureRows, figureCols, 2)
   else:
      figureRows = 1
      figureCols = 1
      axes1 = figure.add_subplot(figureRows, figureCols, 1)

   # Add the image and the histogram (if requested) to the figure
   if len(im.shape) == 2:
      axes1.imshow(normalizedImage, cmap=matplotlib.cm.Greys_r)
   else:
      axes1.imshow(normalizedImage)
   axes1.axis('off')

   if histogram:
      h, pdf, cdf = ipcv.histogram(im, maxCount=numberLevels-1)
      axes2.set_xlim([0, numberLevels-1])
      axes2.set_xlabel('DC')
      axes2.set_ylabel('PDF')
      if len(h) == 1:
         axes2.plot(range(numberLevels), pdf[0], 'k')
      else:
         for band in range(len(h)):
            axes2.plot(range(numberLevels), pdf[band])

   # Display the figure to the screen
   matplotlib.pyplot.show()


if __name__ == '__main__':
   import cv2
   import ipcv
   import os

   filename = 'data/lenna.tif'
   im = cv2.imread(filename, cv2.IMREAD_UNCHANGED)

   ipcv.imshow(im, windowName=os.path.basename(filename), histogram=True)

