# DTM-Inpainting-surface-roughness-restitution
Matlab script to carry out heat diffusion based inpainting over missing data area and to render back on top of the interpolation a realistic surface roughnes/testure
Credits to John D'Errico (2012) for the inpaint_nans function (https://www.mathworks.com/matlabcentral/fileexchange/4551-inpaint-nans) and to
Wolfgang Schwanghart for the amazing Topo-Toolbox set of tools (https://www.mathworks.com/matlabcentral/fileexchange/50124-topotoolbox) (here I'm using rasterread and rasterwrite functions)


Usage example: clone or dowload the repository: https://github.com/HydrogeomorphologyTools/DTM-Inpainting-surface-roughness-restitution 

Then run the main script (Inpaint_DTM_roughness_restitution.m) "as is" with the provided inputs and dependance files. 

Tested with Matlab R2018a

Feel free to test and vary parameterization, investigation is still needed on DTM-related performance.

Enjoy!