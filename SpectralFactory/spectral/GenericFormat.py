import cv2
import spectral

class GenericFormat(spectral.SpectralData):

   def __init__(self, filename):
      spectral.SpectralData.__init__(self)
      self.__reader(filename)

      self._metadata.update({'sensorType': 'Generic'})
      if self._data.dtype == 'uint8' or self._data.dtype == 'int8':
         self._metadata.update({'bitDepth': 8})
      elif self._data.dtype == 'uint16' or self._data.dtype == 'int16':
         self._metadata.update({'bitDepth': 16})
      else:
         self._metadata.update({'bitDepth': None})

   def __reader(self, filename):
      self._data = cv2.imread(filename, cv2.IMREAD_UNCHANGED)

      isGreyscale = len((self._data).shape) == 2
      if isGreyscale:
         shape = self._data.shape
         self._data = (self._data).reshape((shape[0], shape[1], 1))
