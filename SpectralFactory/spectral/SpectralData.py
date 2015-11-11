import numpy

class SpectralData(object):

   def __init__(self):
      self._data = None
      self._metadata = {'sensorType': 'Unknown',
                        'serialNumber': None,
                        'bitDepth': None,
                        'bands': None,
                        'wavelength': None,
                        'fwhm': None,
                        'wavelengthUnits': 'Unknown',
                        'bandNames': None,
                        'defaultBands': None}

   @property
   def data(self):
      return self._data

   @data.setter
   def data(self, data):
      self._data = data

   @data.deleter
   def data(self):
      del self._data

   @property
   def metadata(self):
      return self._metadata

   @metadata.setter
   def metadata(self, metadata):
      self._metadata.update({'sensorType': metadata['sensorType']})
      self._metadata.update({'serialNumber': metadata['serialNumber']})
      self._metadata.update({'bitDepth': metadata['bitDepth']})
      self._metadata.update({'bands': metadata['bands']})
      self._metadata.update({'wavelength': metadata['wavelength']})
      self._metadata.update({'fwhm': metadata['fwhm']})
      self._metadata.update({'wavelengthUnits': metadata['wavelengthUnits']})
      self._metadata.update({'bandNames': metadata['bandNames']})
      self._metadata.update({'defaultBands': metadata['defaultBands']})

   @metadata.deleter
   def metadata(self):
      del self._metadata

   def toBGR(self, bands=None):
      if bands == None:
         bands = self._metadata['defaultBands']

      if len(bands) != 3:
         msg = 'The list of bands provided to extract must have 3 elements'
         raise ValueError(msg)

      bgr = numpy.zeros((self._data.shape[0], self._data.shape[1], 3),
                        dtype=self._data.dtype)
      i = 2
      for band in bands:
         bgr[:,:,i] = self._data[:,:,band]
         i -= 1

      return bgr

   def extract(self, band):
      return self._data[:,:,band]

