import color
import graphics
import numerical
import glob
import numpy
import scipy

filenames = glob.glob('../senior_project/Maier_Farms_SVC_Data_07-11-15/*.sig')
counter = 0
spectrum = []
for filename in filenames:
    if counter == 0:
        pass
    else:
        spectrum.append(color.SpectrumFactory.create_from_file(filename,
                                                     color.SAMPLE_REFLECTANCE))
    counter += 1


for i in range(len(spectrum)):
    filterWavelengths = numpy.arange(300,2000,10)
    sigma = numpy.std(filterWavelengths)
    mu = 550
    gFilter = 1/(sigma * numpy.sqrt(2 * numpy.pi)) * \
              numpy.exp( - (filterWavelengths - mu)**2 / (2 * sigma**2) )
    mu = 700
    rFilter = 1/(sigma * numpy.sqrt(2 * numpy.pi)) * \
              numpy.exp( - (filterWavelengths - mu)**2 / (2 * sigma**2) )
    mu = 400
    bFilter = 1/(sigma * numpy.sqrt(2 * numpy.pi)) * \
              numpy.exp( - (filterWavelengths - mu)**2 / (2 * sigma**2) )
    mu = 1500
    irFilter = 1/(sigma * numpy.sqrt(2 * numpy.pi)) * \
              numpy.exp( - (filterWavelengths - mu)**2 / (2 * sigma**2) )

    gFilter *= 1e8
    rFilter *= 1e8
    bFilter *= 1e8
    irFilter *= 1e8

    gFilter = numerical.interpolate.interp1(filterWavelengths, 
                                            gFilter, 
                                            spectrum[i].wavelengths, 
                                            order=1, 
                                            extrapolate=True)

    rFilter = numerical.interpolate.interp1(filterWavelengths, 
                                            rFilter, 
                                            spectrum[i].wavelengths, 
                                            order=1, 
                                            extrapolate=True)

    bFilter = numerical.interpolate.interp1(filterWavelengths, 
                                            bFilter, 
                                            spectrum[i].wavelengths, 
                                            order=1, 
                                            extrapolate=True)

    irFilter = numerical.interpolate.interp1(filterWavelengths, 
                                             irFilter, 
                                             spectrum[i].wavelengths, 
                                             order=1, 
                                             extrapolate=True)


    gRadiance = gFilter * spectrum[i].values
    rRadiance = rFilter * spectrum[i].values
    bRadiance = bFilter * spectrum[i].values
    irRadiance = irFilter * spectrum[i].values

    gIntegratedRadiance = numpy.trapz(gRadiance,x=spectrum[i].wavelengths)
    rIntegratedRadiance = numpy.trapz(rRadiance,x=spectrum[i].wavelengths)
    bIntegratedRadiance = numpy.trapz(bRadiance,x=spectrum[i].wavelengths)
    irIntegratedRadiance = numpy.trapz(irRadiance,x=spectrum[i].wavelengths)

    ndvi = (irIntegratedRadiance - rIntegratedRadiance) / \
           float(irIntegratedRadiance + rIntegratedRadiance)

    print ndvi


#graphics.plot([spectrum.wavelengths]*4,
#              [spectrum.values, gFilter, rFilter, bFilter],
#              xlabel='Wavelength [nm]',
#              ylabel='Reflectance',
#              xlim=[300,2600])
#             #ylim=[0,100])

#graphics.plot([spectrum.wavelengths]*3,
#              [gRadiance, rRadiance, bRadiance],
#              xlabel='Wavelength [nm]',
#              ylabel='Reflectance',
#              xlim=[300,2600])
