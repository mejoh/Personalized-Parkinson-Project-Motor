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
gl.mosaic("A L- H 0 -18 -6 2; 6 62 S X R 0");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(0)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtMMP_Mean.nii')
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtIM_Mean.nii')
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcSubtypes_x_ExtInt2Int3Catch_NoOutliers/x_HCgtDM_Mean.nii')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"2green")
gl.minmax(1, 3.1, 5)
gl.opacity(1, 100)
gl.colorname(2,"3blue")
gl.minmax(2, 3.1, 5)
gl.opacity(2, 100)
gl.colorname(3,"1red")
gl.minmax(3, 3.1, 5)
gl.opacity(3, 100)

# Set color bar options 
gl.colorbarposition(1)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
gl.shaderquality1to10(10)

# Save the image 
gl.savebmp('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HCgtSubtypes_Mean.nii')