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
gl.mosaic("A L+ H -0.1 V -0.1 -66 -62 -56 -52 -48 -42 -38 -34; -28 -24 -18 -14 -10 -4 0 6; 10 14 20 24 30 34 38 44; 48 54 58 62 68 72 76 82");

# Smooth interpolation of overlay 
gl.overlayloadsmooth(0)

# Sharpen
gl.sharpen()

# Open overlay
gl.overlayload('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/HcOn_x_ExtInt2Int3Catch_NoOutliers/EffectsOfChoice/z_Catch.nii')

# Set overlay display parameters; 1 indicates 1st overlay
gl.colorname(1,"8redyell")
gl.minmax(1, 3.1, 30)
gl.opacity(1, 100)

# Set color bar options 
gl.colorbarposition(1)
gl.colorbarsize(0.05)

# Set background color
gl.backcolor(255, 255, 255)

# Set shader
gl.shadername('Standard')
#gl.shaderquality(10)

# Save the image 
gl.savebmp('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Baseline/ME_Choice_Catch.png')