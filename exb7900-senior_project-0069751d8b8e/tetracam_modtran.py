import numpy
import color
import numerical

def tetracam_modtran(tape7, reflectance, transmission1, transmission2, transmission3, transmission4, transmission5, transmission6):

    """
    ground reaching radiance from MODTRAN * reflectance from SVC, 
    integrate with 6 tetra cam curves, compute NDVI
    """

    #Read in tape7.scn
    f = open(tape7, 'r')
    wavelengths = []
    TOTAL_RAD = []

    i=0
    for line in f:
        if i < 11:
            pass
        elif i > 224:
            pass
        else:
            data = line.rstrip().split(' ')
            wavelengths.append(data[4])
            TOTAL_RAD.append(data[23])
        i += 1

    #Make gathered data into arrays that can be used for calculations
    TOTAL_RAD = numpy.asarray(TOTAL_RAD).astype(numpy.float64)
    wavelengths = numpy.asarray(wavelengths).astype(numpy.float64) * 1000 #get to [nm]

    #Read in reflectance spectra
    spectrum = color.SpectrumFactory.create_from_file(reflectance,
                          color.SAMPLE_REFLECTANCE)

    reflectance = spectrum.values
    refWavelengths = spectrum.wavelengths

    #Read in filter 1 transmission
    f3 = open(transmission1, 'r')
    t1Wavelengths = []
    t1Transmission = []
    lines = f3.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t1Wavelengths.append(d[0])
        t1Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t1Wavelengths = numpy.asarray(t1Wavelengths).astype(numpy.float64)
    t1Transmission = numpy.asarray(t1Transmission).astype(numpy.float64)

    #Read in filter 2 transmission
    f4 = open(transmission2, 'r')
    t2Wavelengths = []
    t2Transmission = []
    lines = f4.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t2Wavelengths.append(d[0])
        t2Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t2Wavelengths = numpy.asarray(t2Wavelengths).astype(numpy.float64)
    t2Transmission = numpy.asarray(t2Transmission).astype(numpy.float64)

    #Read in filter 3 transmission
    f5 = open(transmission3, 'r')
    t3Wavelengths = []
    t3Transmission = []
    lines = f5.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t3Wavelengths.append(d[0])
        t3Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t3Wavelengths = numpy.asarray(t3Wavelengths).astype(numpy.float64)
    t3Transmission = numpy.asarray(t3Transmission).astype(numpy.float64)

    #Read in filter 4 transmission
    f6 = open(transmission4, 'r')
    t4Wavelengths = []
    t4Transmission = []
    lines = f6.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t4Wavelengths.append(d[0])
        t4Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t4Wavelengths = numpy.asarray(t4Wavelengths).astype(numpy.float64)
    t4Transmission = numpy.asarray(t4Transmission).astype(numpy.float64)

    #Read in filter 5 transmission
    f7 = open(transmission5, 'r')
    t5Wavelengths = []
    t5Transmission = []
    lines = f7.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t5Wavelengths.append(d[0])
        t5Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t5Wavelengths = numpy.asarray(t5Wavelengths).astype(numpy.float64)
    t5Transmission = numpy.asarray(t5Transmission).astype(numpy.float64)

    #Read in filter 6 transmission
    f8 = open(transmission6, 'r')
    t6Wavelengths = []
    t6Transmission = []
    lines = f8.readlines()
    data = lines[0].rstrip().split('\r')
    for i in range(len(data)):
        d = data[i].rstrip().split(',')
        t6Wavelengths.append(d[0])
        t6Transmission.append(d[1])

    #Make gathered data into arrays that can be used for calculations
    t6Wavelengths = numpy.asarray(t6Wavelengths).astype(numpy.float64)
    t6Transmission = numpy.asarray(t6Transmission).astype(numpy.float64)

    masterWavelengths = numpy.arange(334.0, 2510.0, 0.1)

    TOTAL_RAD = numerical.interpolate.interp1(wavelengths,
                                            TOTAL_RAD,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=True)

    reflectance = numerical.interpolate.interp1(refWavelengths,
                                            reflectance,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=True)

    t1Transmission = numerical.interpolate.interp1(t1Wavelengths,
                                            t1Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    t2Transmission = numerical.interpolate.interp1(t2Wavelengths,
                                            t2Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    t3Transmission = numerical.interpolate.interp1(t3Wavelengths,
                                            t3Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    t4Transmission = numerical.interpolate.interp1(t4Wavelengths,
                                            t4Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    t5Transmission = numerical.interpolate.interp1(t5Wavelengths,
                                            t5Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    t6Transmission = numerical.interpolate.interp1(t6Wavelengths,
                                            t6Transmission,
                                            masterWavelengths,
                                            order=1,
                                            extrapolate=False)

    radiance = TOTAL_RAD * reflectance

    radiance1 = t1Transmission * radiance
    radiance2 = t2Transmission * radiance
    radiance3 = t3Transmission * radiance
    radiance4 = t4Transmission * radiance
    radiance5 = t5Transmission * radiance
    radiance6 = t6Transmission * radiance

    integratedRadiance1 = numpy.trapz(radiance1,x=masterWavelengths) #B
    integratedRadiance2 = numpy.trapz(radiance2,x=masterWavelengths) #G
    integratedRadiance3 = numpy.trapz(radiance3,x=masterWavelengths) #R
    integratedRadiance4 = numpy.trapz(radiance4,x=masterWavelengths) #IR 720
    integratedRadiance5 = numpy.trapz(radiance5,x=masterWavelengths) #IR 800
    integratedRadiance6 = numpy.trapz(radiance6,x=masterWavelengths) #IR 900

    ndvi = (integratedRadiance5 - integratedRadiance3) / \
           float(integratedRadiance5 + integratedRadiance3)

    print ndvi

    return masterWavelengths, TOTAL_RAD, reflectance, radiance, radiance1, \
           radiance2, radiance3, radiance4, radiance5, radiance6, \
           t1Transmission, t2Transmission, t3Transmission, t4Transmission, \
           t5Transmission, t6Transmission


if __name__ == '__main__':

    import matplotlib.pyplot

    #No Clouds
    tape7 = '/Users/elizabethbondi/src/python/modules/senior_project/modtran/no_clouds/tape7.scn'
    reflectance = '/Users/elizabethbondi/src/python/modules/senior_project/Maier_Farms_SVC_Data_07-11-15/gr071415_059.sig'
    transmission1 = '/Users/elizabethbondi/src/python/modules/senior_project/490FS10-25.csv'
    transmission2 = '/Users/elizabethbondi/src/python/modules/senior_project/550FS10-25.csv'
    transmission3 = '/Users/elizabethbondi/src/python/modules/senior_project/680FS10-25.csv'
    transmission4 = '/Users/elizabethbondi/src/python/modules/senior_project/720FS10-25.csv'
    transmission5 = '/Users/elizabethbondi/src/python/modules/senior_project/800FS20-25.csv'
    transmission6 = '/Users/elizabethbondi/src/python/modules/senior_project/900FS20-25.csv'

    #Call above function
    print 'no clouds'
    masterWavelengths, TOTAL_RAD, reflectance, radiance, radiance1, \
           radiance2, radiance3, radiance4, radiance5, radiance6, \
           t1Transmission, t2Transmission, t3Transmission, t4Transmission, \
           t5Transmission, t6Transmission = \
    tetracam_modtran(tape7, reflectance, transmission1, \
        transmission2, transmission3, transmission4, transmission5, \
        transmission6)

    
    #Plot
    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('MODTRAN Radiance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('MODTRAN Radiance')
    matplotlib.pyplot.plot(masterWavelengths, TOTAL_RAD, 'b')

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Reflectance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Reflectance')
    matplotlib.pyplot.plot(masterWavelengths, reflectance, 'b')
    
    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Ground Leaving Radiance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Ground Leaving Radiance')
    matplotlib.pyplot.plot(masterWavelengths, radiance, 'b')

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Filter * Radiances')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Filter * Radiances')
    matplotlib.pyplot.plot(masterWavelengths, radiance1)
    matplotlib.pyplot.plot(masterWavelengths, radiance2)
    matplotlib.pyplot.plot(masterWavelengths, radiance3)
    matplotlib.pyplot.plot(masterWavelengths, radiance4)
    matplotlib.pyplot.plot(masterWavelengths, radiance5)
    matplotlib.pyplot.plot(masterWavelengths, radiance6)

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Filters')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Filter Transmission')
    matplotlib.pyplot.plot(masterWavelengths, t1Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t2Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t3Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t4Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t5Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t6Transmission)

    matplotlib.pyplot.show()
    
    #Clouds
    tape7 = '/Users/elizabethbondi/src/python/modules/senior_project/modtran/clouds/tape7.scn'
    reflectance = '/Users/elizabethbondi/src/python/modules/senior_project/Maier_Farms_SVC_Data_07-11-15/gr071415_059.sig'
    transmission1 = '/Users/elizabethbondi/src/python/modules/senior_project/490FS10-25.csv'
    transmission2 = '/Users/elizabethbondi/src/python/modules/senior_project/550FS10-25.csv'
    transmission3 = '/Users/elizabethbondi/src/python/modules/senior_project/680FS10-25.csv'
    transmission4 = '/Users/elizabethbondi/src/python/modules/senior_project/720FS10-25.csv'
    transmission5 = '/Users/elizabethbondi/src/python/modules/senior_project/800FS20-25.csv'
    transmission6 = '/Users/elizabethbondi/src/python/modules/senior_project/900FS20-25.csv'

    #Call above function
    print 'clouds'
    masterWavelengths, TOTAL_RAD, reflectance, radiance, radiance1, \
           radiance2, radiance3, radiance4, radiance5, radiance6, \
           t1Transmission, t2Transmission, t3Transmission, t4Transmission, \
           t5Transmission, t6Transmission = \
    tetracam_modtran(tape7, reflectance, transmission1, \
        transmission2, transmission3, transmission4, transmission5, \
        transmission6)


    #Plot
    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('MODTRAN Radiance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('MODTRAN Radiance')
    matplotlib.pyplot.plot(masterWavelengths, TOTAL_RAD, 'b')

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Reflectance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Reflectance')
    matplotlib.pyplot.plot(masterWavelengths, reflectance, 'b')

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Ground Leaving Radiance')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Ground Leaving Radiance')
    matplotlib.pyplot.plot(masterWavelengths, radiance, 'b')

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Filter * Radiances')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Filter * Radiances')
    matplotlib.pyplot.plot(masterWavelengths, radiance1)
    matplotlib.pyplot.plot(masterWavelengths, radiance2)
    matplotlib.pyplot.plot(masterWavelengths, radiance3)
    matplotlib.pyplot.plot(masterWavelengths, radiance4)
    matplotlib.pyplot.plot(masterWavelengths, radiance5)
    matplotlib.pyplot.plot(masterWavelengths, radiance6)

    matplotlib.pyplot.figure()
    matplotlib.pyplot.title('Filters')
    matplotlib.pyplot.xlabel('Wavelength [nm]')
    matplotlib.pyplot.ylabel('Filter Transmission')
    matplotlib.pyplot.plot(masterWavelengths, t1Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t2Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t3Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t4Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t5Transmission)
    matplotlib.pyplot.plot(masterWavelengths, t6Transmission)

    matplotlib.pyplot.show()
