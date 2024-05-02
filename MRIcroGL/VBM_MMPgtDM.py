# Basic setup
import gl
import sys
print(sys.version)
print(gl.version())
gl.resetdefaults()
gl.linewidth(2)
gl.linecolor(255,255,255)

# Open background image
gl.loadimage('C:/Program Files/MRIcroGL/MRIcroGL_windows_20190902/Resources/standard/mni152.nii.gz')

# Set position
#gl.orthoviewmm(-27,-46,3)

# Set mosaic
gl.mosaic("A L+ H 0 -6 -2 2; 6 10 S X R 0");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(0)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/CAT12/stats/VBM_shooting-custom/Subtypes/x_MMPgtDM.nii')
gl.overlayload('P:/3024006.02/Analyses/CAT12/stats/VBM_shooting-custom/Subtypes/x_MMPgtDM_NULL.nii.gz')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"8redyell")
gl.minmax(1, 3.1, 5)
gl.opacity(1, 100)
gl.colorname(2,"5winter")
gl.minmax(2, 3.1, 5)
gl.opacity(2, 100)

# Set color bar options 
gl.colorbarposition(1)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
gl.shaderquality1to10(10)

# Save the image 
gl.savebmp('P:/3024006.02/Analyses/CAT12/stats/VBM_shooting-custom/Subtypes/VBM_MMPgtDM')