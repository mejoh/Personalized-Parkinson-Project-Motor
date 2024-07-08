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
gl.mosaic("A L- H 0 V -0.2 -20 -0 40; 50 60 70");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(1)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/Masks/bi_full_clincorr_bg_mask_cropped.nii')

gl.colorname(1,"x_rain")
gl.minmax(1, 0, 1)
gl.opacity(1, 50)

# Set color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
#gl.shaderquality(10)

# Save the image 
gl.savebmp('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/vis/mask_cortex.png')
