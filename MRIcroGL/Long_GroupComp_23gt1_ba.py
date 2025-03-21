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
gl.mosaic("A L- H 0.0 V 0.0 -20 0; 20 40; 60 S X R 0");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(1)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease/stats/con_combined_Group2_x_TimepointNr2_x_Type3_Z_TypeBA_FWEcorr-stat.nii')
gl.overlayload('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI/WholeBrain/3dLME_disease/stats/con_combined_Group2_x_TimepointNr2_x_Type3_Z_TypeBA_FWEcorr-stat.nii')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"4hot")
gl.minmax(1, 1.5, 24)
gl.opacity(1, 100)
gl.colorname(2,"6bluegrn")
gl.minmax(2, -16, -1.5)
gl.opacity(2, 100)

# Set color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('OverlaySurface')
#gl.shaderquality(10)

# Save the image 
gl.savebmp('M:/Visualization/R_LongitudinalComparisonFmri/AFNI/3dLME_GroupComp_23gt1_ba.png')
