%% script for removing selected areas from a DTM and reconstructing a realistic terrain surface
% Credits to John D'Errico (2012) for the inpaint_nan function and to
% Wolfgang Schwanghart for the amazing Topo-Toolbox set of tools

%% original surface
[Z,X,Y] = rasterread('input_dtm.txt'); % Refer to Topotoolbox functions for a nice DTM set of tools
Z(isnan(Z)==1) = 0;

[Z2,R] = arcgridread('input_dtm.txt'); % mask of the catchment with no holes and nodata only outside, to set correctly nodata at the end of the inpaint procedure 

% %% Artifacts to be removed (code = 1)
[A,F] = arcgridread('masked_areas.txt');
% 
% %% DTM plot without artifacts
% % setting NoData in the DTM over artifacts area
Z(A>=0) = NaN;

% Function to calculate with the sliding window, with nlfilter operations,
% but very slow, to be used only if the applied function cannot filt into
% convolution methods
fun_m = @(x) nanmean(x(:)); % ignoring nodata in calculation, thus avoiding toenlarge the holes in the dataset, but actually restricting the hole, same no correct

% Kernel / Window size
ker_size = 3;
%
kernel = ones(ker_size, ker_size) / (ker_size^2); % 3x3 mean kernel
Z_m = conv2(Z, kernel, 'same'); % Convolve keeping size of Z, applying the mean/average filter, extremely more efficient then neighborhhod operatio
Z_res = Z - Z_m; % Residual topography


% trying default matlab function stdfilt that implements convolution too, the other
% functions seem to have lot of problems with NoData
NHOOD = ones(ker_size, ker_size);
Z_s = stdfilt(Z_res, NHOOD); % st. dev. of residual topography, probably not going to use this


%% Interpolation for surface fitting over removed areas
D = inpaint_nans(Z,0); %0 = plate, 3 corrisponde a plate equation migliore...
..., avoid neighborhood average (options 5)
% other possible method
% D = inpaintn(Z,200); % specify number of iterations
D(isnan(Z2)==1) = NaN; % controllare che non faccia inpaint su nodata

%%
% Adding variability only to removed areas
% Approach: sampling variability outside the removed areas
% Function to calculate with the sliding window, with nlfilter operations,
% but very slow, to be used only if the applied function cannot filt into

Big_Window = 13; % window for looking around while operating ir removed areas, convolve operatin increases the voids, pay attention, nlfilter is slow in respect to conv2 but does not expands nodata oversize

n_samples = 3; % number of random samples to take and in case, to average

fun_random = @(x) median(datasample(x(isnan(x) == 0),n_samples)); % sample values not NaN (Maybe better to use with residual topography, not st. dev., ... later)

Z_window_random = nlfilter(Z_res,[Big_Window Big_Window],fun_random); % working on residual topography not on st. dev., random function

% mean sometimes behaves too smoothly
Z_window_random(isnan(A)==1) = 0;

% DTM reconstruction
Z_reconstruct = D + Z_window_random;


%% surface plot
% mapshow(Z_reconstruct,R,'DisplayType','surface')
% xlabel('x (easting in meters)')
% ylabel('y (northing in meters)')
% 
% axis normal
% view(3)
% %axis equal
% grid on
% zlabel('elevation in meters')

%% write ESRI ASCII raster
filename = 'outsurface_inpainted.txt';
rasterwrite(filename,X,Y,D)

filename2 = 'outsurface_inpainted_and_roughness.txt';
rasterwrite(filename2,X,Y,Z_reconstruct)
