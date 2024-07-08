# Basic setup
import gl
import sys
print(sys.version)
print(gl.version())
gl.resetdefaults()
gl.linewidth(2)
gl.linecolor(255,255,255)
 
# Open background image
gl.loadimage('P:/3024006.02/Analyses/MJF_FreeWater/data/n2_dipy_b0_50HC50PD/dipy-b0mean_norm_avg_ALL.nii.gz')

# Set position
#gl.orthoviewmm(-27,-46,3)

# Set mosaic
# gl.mosaic("A L+ H -0.2 V -0.1 -8 -10; -12 -14");
gl.mosaic("A L- H -0.2 V -0.1 -10");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(0)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/MJF_FreeWater/ROIs/n2_ROIs_HCP1065_1mm.nii.gz')

gl.colorname(1,"linspecer")
gl.minmax(1, 0, 4)
gl.opacity(1, 100)

# Set color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
#gl.shaderquality(10)

# Save the image 
gl.savebmp('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/vis/mask_SN.png')