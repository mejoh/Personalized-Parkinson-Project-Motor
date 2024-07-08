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
gl.overlayload('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/stats/con_0007/by_session/ses-Visit2/vals/rand_fu_clincorr_all_tfce_corrp_tstat2_stats_full_t.nii.gz')
gl.overlayload('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/stats/con_0007/by_session/ses-Visit2/vals/rand_fu_clincorr_all_tfce_corrp_tstat2_stats_mask_t.nii.gz')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"6bluegrn")
gl.minmax(1, 3000, 13000)
gl.opacity(1, 40)
gl.colorname(2,"7cool")
gl.minmax(2, 3000, 13000)
gl.opacity(2, 100)

# Set color bar options 
gl.colorbarposition(0)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
#gl.shaderquality(10)

# Save the image 
gl.savebmp('M:/Visualization/R_LongitudinalComparisonFmri/FSL/rand_fu_clincorr_brady_tstat2.png')
