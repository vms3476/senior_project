import spectral

class SpectralDataFactory(object):

   @staticmethod
   def create_from_file(filename, sensor='generic'):
      if sensor.lower() == 'generic':
         return spectral.GenericFormat(filename)
      elif sensor.lower() == 'tetracam_micromca_snap':
         return spectral.TetraCamMicroMcaSnap(filename)
      else:
         msg = 'Provided sensor is not supported: %r' % sensor
         raise ValueError(msg)


if __name__ == '__main__':
   import cv2
   import ipcv
   import spectral

   displayHistogram = True

   filename = 'data/TTC00014.tif'
   spectralImage = \
      spectral.SpectralDataFactory.create_from_file(filename,
                                                    sensor= \
                                                       'tetracam_micromca_snap')

   spectralImage.metadata['serialNumber'] = 250132
   spectralImage.metadata['bands'] = 6
   spectralImage.metadata['wavelength'] = [800, 490, 550, 680, 720, 900]
   spectralImage.metadata['fwhm'] = [10, 10, 10, 10, 10, 20]
   spectralImage.metadata['wavelengthUnits'] = 'nm'
   spectralImage.metadata['bandNames'] = ['MASTER', 'SLAVE 1', 'SLAVE 2',    
                                          'SLAVE 3', 'SLAVE 4', 'SLAVE 5']
   spectralImage.metadata['defaultBands'] = [0, 3, 2]

   for i in range(spectralImage.data.shape[2]):
      windowName = '%s (Serial #%d) %s (%d/%d %s)' % \
                   (spectralImage.metadata['sensorType'],
                    spectralImage.metadata['serialNumber'],
                    spectralImage.metadata['bandNames'][i],
                    spectralImage.metadata['wavelength'][i],
                    spectralImage.metadata['fwhm'][i],
                    spectralImage.metadata['wavelengthUnits'])
      ipcv.imshow(spectralImage.extract(i),
                  windowName=windowName,
                  histogram=displayHistogram,
                  bitDepth=spectralImage.metadata['bitDepth'])

   windowName = '%s (Serial #%d) (Bands %d, %d, %d)' % \
                (spectralImage.metadata['sensorType'],
                 spectralImage.metadata['serialNumber'],
                 spectralImage.metadata['defaultBands'][0],
                 spectralImage.metadata['defaultBands'][1],
                 spectralImage.metadata['defaultBands'][2])
   ipcv.imshow(spectralImage.toBGR(),
               windowName=windowName,
               histogram=displayHistogram,
               bitDepth=spectralImage.metadata['bitDepth'])

   bands = [3, 2, 1]
   windowName = '%s (Serial #%d) (Bands %d, %d, %d)' % \
                (spectralImage.metadata['sensorType'],
                 spectralImage.metadata['serialNumber'],
                 bands[0],
                 bands[1],
                 bands[2])
   ipcv.imshow(spectralImage.toBGR(bands),
               windowName=windowName,
               histogram=displayHistogram,
               bitDepth=spectralImage.metadata['bitDepth'])

