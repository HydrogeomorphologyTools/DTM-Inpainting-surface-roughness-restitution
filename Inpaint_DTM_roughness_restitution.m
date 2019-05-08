%% script for removing selected areas from a DTM and trying to reconstruct...
... an hypothetic previous surface with inapint_nans by John D'Errico https://www.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans
%
% Stefano Crema (CNR-IRPI) Dec 8, 2019
%
% Copyright: This is published under GPL v3.0 Licence, more info at: https://www.gnu.org/licenses/gpl-3.0.en.html
%%
% usage example: Clone or dowload the repository: https://github.com/HydrogeomorphologyTools/DTM-Inpainting-surface-roughness-restitution ...
... and run the present script "as is" with the provided inputs and dependance files.

%%
clc
clear 
close all

%% original surface
[Z,X,Y] = rasterread('Input_DTM.txt'); % Topotoolbox function https://topotoolbox.wordpress.com/

% [Z2,R] = arcgridread('DTM_current_2.txt'); % This is needed only in case we'll use the MapCellReference (e.g., mapshow)

%% surface plot in case we want a first overview of the result
% mapshow(Z,R,'DisplayType','surface')
% xlabel('x (easting in meters)')
% ylabel('y (northing in meters)')
% demcmap(Z)
% 
% axis normal
% view(3)
% %axis equal
% grid on
% zlabel('elevation in meters')

%% Artifacts to be removed (code = 1 outside mask = NaN)
[A,F] = arcgridread('Input_mask.txt');

%% DTM plot without artifacts
% setting NoData in the DTM over artifacts area
% in case of NoData in the original DTM replace with 0 or another code to
% avoide inpaintnan working there
Z(isnan(Z))=0;
Z(A>=0) = NaN;


%% Interpolation for surface fitting over removed areas
D = inpaint_nans(Z,0); %0 = plate, 3 corrisponde a plate equation migliore...
..., avoid neighborhood average (options 5)
% restore original NaN
D(Z==0)=NaN;
%% in case you need only inpainted surface (much faster) comment this section

% Kernel / Window size for detrending surface
ker_size = 9;
% 
% 
kernel = ones(ker_size, ker_size) / (ker_size^2); % 3x3 mean kernel
Z_m = conv2(Z, kernel, 'same'); % Convolve keeping size of Z, applying the mean/average filter, extremely more efficient then neighborhhod operatio
Z_res = Z - Z_m; % Residual topography

% trying default matlab function stdfilt that implements convolution too, the other
% functions seem to have lot of problems with NoData
% NHOOD = ones(ker_size, ker_size);
% Z_s = stdfilt(Z_res, NHOOD); % st. dev. of residual topography, not going to use this

% Adding variability only to removed areas
% Approach: sampling variability outside the removed areas
% Function to calculate with the sliding window, with nlfilter operations,
% but very slow, to be used only if the applied function cannot filt into

Big_Window = 41; % window of size [Big_Window Big_Window] for looking around while operating in removed areas, some errors in code execution might be related to the window not ...
...large enough to sample at least one value
n_samples = 1; % number of random samples to take and in case, to median sample
fun_random = @(x) median(datasample(x(isnan(x) == 0),n_samples)); % sample values not NaN (Maybe better to use with residual topography, not st. dev., ... later)
%
Z_window_random = nlfilter(Z_res,[Big_Window Big_Window],fun_random); % working on residual topography, random function

% mean behaves too smoothly, probably better random
Z_window_random(isnan(A)==1) = 0;

% DTM reconstruction
Z_reconstruct = D + Z_window_random;

%restore original NaN
Z_reconstruct(Z==0)=NaN;


% %% surface plot in case we want an overview of the final result
% mapshow(Z_reconstruct,R,'DisplayType','surface')
% xlabel('x (easting in meters)')
% ylabel('y (northing in meters)')
% 
% axis normal
% view(3)
% %axis equal
% grid on
% zlabel('elevation in meters')

%% write ESRI ASCII raster using topoToolbox rasterwrite

% Inpainting only
 filename = 'Reconstr_0.txt';
 rasterwrite(filename,X,Y,D)

% Inpainting + roughness
 filename2 = 'Reconstr_0_rough_ker_9_win_41_n1.txt'; % I usually put in filenames INp scheme, Kernel size for detrending, moving window size for randomly picking residual topography, and how many picks 
 rasterwrite(filename2,X,Y,Z_reconstruct)
