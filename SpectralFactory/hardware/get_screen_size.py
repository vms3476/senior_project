import Tkinter

def get_screen_size(dpi=80):
   root = Tkinter.Tk()
   root.withdraw()

   screenPixelWidth = root.winfo_screenwidth()
   screenPixelHeight = root.winfo_screenheight()
   screenWidth = screenPixelWidth / float(dpi)
   screenHeight = screenPixelHeight / float(dpi)

   return screenPixelWidth, screenPixelHeight, screenWidth, screenHeight


if __name__ == '__main__':

   import hardware

   dpi = 110   # Early 2011 MacBook Pro
   dims = hardware.get_screen_size(dpi)
   print 'Screen size (width, height) [pixels]: (%d, %d)' % \
         (dims[0], dims[1])
   print 'Screen size (width, height) [inches]: (%.2f, %.2f) @ %d dpi' % \
         (dims[2], dims[3], dpi)

