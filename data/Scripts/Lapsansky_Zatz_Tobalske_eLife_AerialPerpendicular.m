%% Lapsansky, Zatz, and Tobalske (2020)

% This script was used for computing kinematic parameters from raw,
% digitized data of alcids flying in the air perpendicular to camera view. 
% Computations of stroke angle were performed in the excel file for ease.

%%
% Import the trimmed data file and rename it "t"
% All columns should be of type "Numerical" otherwise it will through
% errors

%% DRAW AND SMOOTH THE DATA

% The answers to the questions are in the names of the files. For example,
% the file named "Dz91_014_7_tuftedpuffin_27 in 93_29.97" mean that there
% were 27 wingbeats in 93 frames and 29.97 frames per second. 

prompt = 'What is the frame rate of the video?'
frame_rate = input(prompt);
timestep = 1/frame_rate;

prompt = 'How many complete wingbeats occured?'
number_wingbeats = input(prompt);

prompt = 'In how many frames?'
frames = input(prompt);

frequency = (number_wingbeats/frames)*(frame_rate)

eye = [t.eyex t.eyey];
tail = [t.tailx t.taily];
up = [t.upx t.upy];
down = [t.downx t.downy];


colNames = {'x','y'};

eye=array2table(eye, 'VariableNames',colNames);
tail=array2table(tail,'VariableNames',colNames);
up=array2table(up,'VariableNames',colNames);
down=array2table(down,'VariableNames',colNames);


count = (1 : length (tail.x));
count = count';
fiteyex = fit(count,eye.x,'smoothingspline','SmoothingParam',0.01);
fiteyey = fit(count,eye.y,'smoothingspline','SmoothingParam',0.01);
fittailx = fit(count,tail.x,'smoothingspline','SmoothingParam',0.01);
fittaily = fit(count,tail.y,'smoothingspline','SmoothingParam',0.01);

eyesm.x = fiteyex(count);
eyesm.y = fiteyey(count);
tailsm.x = fittailx(count);
tailsm.y = fittaily(count);


%% COMPUTE SCALING FACTOR BASED ON BODY LENGTH

bodylength = sqrt((t.eyex-t.tailx).^2+(t.eyey-t.taily).^2);

figure(1)
plot(bodylength)
title('Body length')
hold on

%smooth that body length data using an aggressive smoothing parameter to
%remove the affect of head bobbing
countlength = (1:size(bodylength))';
calibfit = fit(countlength,bodylength,'smoothingspline','SmoothingParam', 0.0001);

%and compute the pixel to body length transformation factor
q = size(bodylength);
count = (1:(q-1))';
calib = calibfit(count);
calib1=calibfit(countlength);

figure(1)
plot(calib)

%% COMPUTE WINGBEAT AMPLITUDE IN BODY LENGTHS

ampup = (up.y-(tailsm.y+eyesm.y)/2)./calib1;
ampdown = (down.y-(tailsm.y+eyesm.y)/2)./calib1;
ampup = rmmissing(ampup);
ampdown = rmmissing(ampdown);
amplitude = ampup-ampdown;

amp_ave = mean(amplitude)
amp_sd = std(amplitude)

%% COMPUTE VELOCITY BASED ON FIXED CAMERA POSITION (PIGEON GUILLEMOT) or STATIONARY OBJECT (everything else)

% ------------------------------------------------------------------------

% This option calculates the velocity for pigeon guillemot flights only!
% Because the camera did not move, we can use it as a reference for
% station.

% Commment out when not in use.
% 
% for j=1: size(t)-1
%     vel(j,:)=((tailsm.x(j+1)-tailsm.x(j))/timestep);
% end
% 
% velocity = abs(mean(vel./calib)); % Units are in body lengths per second
% disp('Pigeon Guillemot, right?')
%-------------------------------------------------------------------------

% This option calculates the velocity for murre + puffin flights only!
% Commment out when not in use.

station = [t.stationx t.stationy];
station = array2table(station,'VariableNames',colNames);

% Compute the relative position of the bird
relative_position = station.x./calib1 - tailsm.x./calib1;
relative_position = rmmissing(relative_position);

 % Initialize the matrix for the loop
for j=1: size(relative_position)-1
    vel(j,:)=abs(((relative_position(j+1)-relative_position(j))/timestep));
end

velocity = mean(vel) % Units are in body lengths per second
disp('Common murre, tufted puffin, or horned puffin, right?')

%% COMPUTE STROUHAL NUMBER
% this computes the strouhal number for the flight and the error based on
% variance based on the variance in wingbeat amplitude

Strouhal = frequency*amp_ave/velocity;
Strouhal_SD = amp_sd/amp_ave*Strouhal;

%% COMPILE STROKE ANGLE DATA 
% this compiled the stroke angle data already in the excel file.
strokeAngle = mean(rmmissing(t.SA));

AAA = [velocity amp_ave amp_sd frequency Strouhal Strouhal_SD strokeAngle length(rmmissing(t.SA))]