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
gl.mosaic("A L+ H 0 -2 36 54; 62 70 S X R 0");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(0)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Select3_T0_NoOutliers/Int3gtExt/x_Pos_3gt1.nii')
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr-BA_Select3_T0_NoOutliers/Int3gtExt/x_Neg_3gt1.nii')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"8redyell")
gl.minmax(1, 3.1, 9)
gl.opacity(1, 100)
gl.colorname(2,"5winter")
gl.minmax(2, 3.1, 9)
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
gl.savebmp('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ClinCorr_RT_3gt1.nii')