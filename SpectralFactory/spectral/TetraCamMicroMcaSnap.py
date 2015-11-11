import gdal
import gdalconst
import numpy
import spectral

class TetraCamMicroMcaSnap(spectral.SpectralData):

   def __init__(self, filename):
      spectral.SpectralData.__init__(self)
      self.__reader(filename)

      self._metadata.update({'sensorType': 'TetraCAM micro-MCA SNAP'})
      self._metadata.update({'bitDepth': 10})

   def __reader(self, filename):
      d = gdal.Open(filename, gdalconst.GA_ReadOnly)
      data = numpy.array([gdal.Open(name, gdalconst.GA_ReadOnly).ReadAsArray()
                          for name, description in d.GetSubDatasets()])

      data = data[:,1,:,:].astype(numpy.uint16)*4 + \
                (data[:,1,:,:].astype(numpy.uint16) - \
                 data[:,2,:,:].astype(numpy.uint16))

      self._data = numpy.zeros((data.shape[1], data.shape[2], data.shape[0]),
                               dtype=numpy.uint16)
      for band in range(data.shape[0]):
         self._data[:,:,band] = data[band,:,:]

