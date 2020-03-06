%% Lapsansky, Zatz, and Tobalske (2020)

% This script was used for computing kinematic parameters from raw,
% digitized data of alcids swimming perpendicular to camera view. 
% Additional processing occurred in Igor Pro.

%%
%import the trimmed data file and rename it c

%% ROTATES THE POINTS SO THAT X-DIRECTION IS PARALLEL WITH THE WATERLINE

figure(1) %first we plot the tail points to see what the overall path looks like
plot(c.tailx,c.taily, 'color','k')
hold on
plot(c.wristx,c.wristy,'color','r')
title('Euler Rotation')
xlim([0 1920])
ylim([0 1080])
hold on

if c.eyex(end)>c.eyex(1,1) %which means the bird is swimming right
    level_vector = [c.rightx(1,1)-c.leftx(1,1) c.righty(1,1)-c.lefty(1,1) 0]; %the level vector also points right
    unit_vector = [1 0 0];
    dunit_vector = [1 0];
    disp('Swimming right')
else
    level_vector = [c.leftx(1,1)-c.rightx(1,1) c.lefty(1,1)-c.righty(1,1) 0]; %the level vector points left
    unit_vector = [-1 0 0]; %the unit vector also points left
    dunit_vector = [-1 0];
    disp('Swimming left')
end 

adjusted_angle = atan2(norm(cross(level_vector,unit_vector)),dot(level_vector,unit_vector));
adjusted_angle*180/pi; %this computes the angle between horizontal and x for the camera

if c.eyex(end)>c.eyex(1,1)
    Mtheta = [cos(adjusted_angle) -sin(adjusted_angle); sin(adjusted_angle) cos(adjusted_angle)]; %counterclockwise rotation
    disp('Counterclockwise adjustment')
else 
    Mtheta = [cos(adjusted_angle) sin(adjusted_angle); -sin(adjusted_angle) cos(adjusted_angle)]; %clockwise rotation
    disp('Clockwise adjustment')
end
%Mtheta is the 2D rotation matrix

eye = [c.eyex c.eyey];
tail = [c.tailx c.taily];
wrist = [c.wristx c.wristy];

%here, we rotate all of the pairs of points around that angle so that the x
%direction is horizontal
eye = (Mtheta*eye')';
tail = (Mtheta*tail')';
wrist = (Mtheta*wrist')';

%% SMOOTHS POINTS FOR LATER USE

colNames = {'x','y'};

eye=array2table(eye, 'VariableNames',colNames);
tail=array2table(tail,'VariableNames',colNames);
wrist=array2table(wrist,'VariableNames',colNames);

%replot the points to confirm the rotation
figure(1)
plot(tail.x,tail.y, 'color', 'b')
plot(wrist.x,wrist.y,'color','g')


figure (2)
plot(tail.x,tail.y, 'color', 'k') % plots the rotated, but unsmoothed data for comparison
hold on
plot(wrist.x,wrist.y,'color','r')
title('Smoothing confirmation')

count = (1 : length (tail.x));
count = count';
fiteyex = fit(count,eye.x,'smoothingspline','SmoothingParam',0.01);
fiteyey = fit(count,eye.y,'smoothingspline','SmoothingParam',0.01);
fittailx = fit(count,tail.x,'smoothingspline','SmoothingParam',0.01);
fittaily = fit(count,tail.y,'smoothingspline','SmoothingParam',0.01);
fitwristx = fit(count,wrist.x,'smoothingspline','SmoothingParam',0.01);
fitwristy = fit(count,wrist.y,'smoothingspline','SmoothingParam',0.01);

eye.x = fiteyex(count);
eye.y = fiteyey(count);
tail.x = fittailx(count);
tail.y = fittaily(count);
wrist.x = fitwristx(count);
wrist.y = fitwristy(count);

figure(2)
plot(tail.x,tail.y,'color','b') %this confirms that the smoothing and initial rotation procedures worked
hold on
plot(wrist.x,wrist.y,'color','g')

%% DESCENDING ONLY! ROTATES POINTS TO LOCAL FRAME OF REFRENCE.
% This step should only be used for descending aquatic flights.
% For level aquatic flights, it should be commented out because it will
% rotate the data the wrong way if the bird is moving toward the surface
% even a tiny bit! (acos function is always positive)

% % The following step rotates the points by the mean trajectory
% 
%         path_vector = [tail.x(length(tail.x),1)-tail.x(1,1), tail.y(length(tail.y),1)-tail.y(1,1)]; %computers the vector
%         %between the first tail point and the last tail point
% 
%         descentangle = acos(dot(dunit_vector,path_vector)/(norm(dunit_vector)*norm(path_vector)));
%         descentangle*180/pi
% if descentangle*180/pi>5
%     
%         if c.eyex(end)>c.eyex(1,1)%meaning the bird is moving to the right
%             Mtheta2 = [cos(descentangle) -sin(descentangle); sin(descentangle) cos(descentangle)]; %counterclockwise rotation
%             disp('Counterclockwise rotation')
%         else 
%             Mtheta2 = [cos(descentangle) sin(descentangle); -sin(descentangle) cos(descentangle)]; %clockwise rotation
%             disp('Clockwise rotation')
%         end
% 
%         eye = table2array(eye);
%         tail = table2array(tail);
%         wrist = table2array(wrist);
%         
%         eye = (Mtheta2*eye')';
%         tail = (Mtheta2*tail')';
%         wrist = (Mtheta2*wrist')';
% 
%     eye=array2table(eye, 'VariableNames',colNames);
%     tail=array2table(tail,'VariableNames',colNames);
%     wrist=array2table(wrist,'VariableNames',colNames);
% 
% end
figure(1)
plot(tail.x,tail.y, 'color', 'b')
plot(wrist.x,wrist.y,'color','r')

%% COMPUTES RELATIVE POSITION OF THE WRIST
% Compute the center of the body and reflects the relative position of the
% wrist based on the direction of travel.

%then compute the center of the body
center = [(eye.x+tail.x)/2,(eye.y+tail.y)/2];
center=array2table(center, 'VariableNames',colNames);

%then we find the wrist position relative to the center of the body
wrist_rel = [wrist.x-center.x wrist.y-center.y];
wrist_rel=array2table(wrist_rel, 'VariableNames',colNames);

if c.eyex(end)>c.eyex(1,1) %which means the bird is swimming right
    %do nothing
  
else %the bird is swimming left
    wrist_rel.x=wrist_rel.x*-1;
    disp("The bird is swimming left - Reflecting")
end


%% COMPUTES STROKE ANGLE BASED ON RELATIVE POSITION OF THE WRIST

% This chunk is for extracting the stroke angle from all strokes.
% We do this first because the data do not need to be scaled by body length

[pkstop, loctop] = findpeaks(wrist_rel.y); %finds the top of downstroke and location
top = [wrist_rel.x(loctop) pkstop]; %outputs x and y coordinates of the top of downstroke

[pksbot, locbot] = findpeaks(-wrist_rel.y) %finds the bottom of downstroke
bottom = [wrist_rel.x(locbot) -pksbot]; %finds the x and y coordinates of the bottom of downstroke

%this loop corrects for vectors of differnt lengths, starting with the
%first complete downstroke

if loctop(1,1)<locbot(1,1)%i.e. the top of the stroke appears first
    disp('Top first')
    if length(loctop)>length(locbot)
        disp('Extra top')
        top=top(1:(length(loctop)-1),:); % get rid of last top
    else
        disp('Same length...Nice')
    end
else %i.e. the bottom of the stroke appears first
    disp('Bottom first')
    bottom = bottom(2:length(locbot),:); %delete the first cell of bottoms
    if length(bottom)<length(top)
       disp('Extra top after trimming')
       top=top(1:(length(loctop)-1),:);
    else
        disp('Same length...Nice')
    end
end

%creates the vector pointing from the top of the stroke to the bottom
stroke_direction = [bottom - top];

%creates some zeros to make that vector 3d
z = zeros(length(stroke_direction),1);
stroke_direction3d = [stroke_direction z];

%initializes the vectors
stroke_angle = (1:size(stroke_direction))';
cros = [z, z, z];

vector = [1 0 0];

%a for loop for computing the stroke angle
for i=1:length(stroke_direction)
    cros(i,:) = cross(vector,stroke_direction3d(i,:));
    stroke_angle(i)=180/pi*atan2(norm(cros(i,:)),dot(vector,stroke_direction3d(i,:)));
end

stroke_angle

% This requires visual inspection to confirm that everything circled is
% actually the top and bottom of a stroke! Sometimes, the findpeaks
% function will pull out weird points due to subtle movements of the wing
% or digitization error. Only points confirmed to be the top and bottom of
% the stroke were used in calculating the average stroke angle for the run.

figure(3)
plot(wrist_rel.x,wrist_rel.y,'color','k')
hold on
scatter(wrist_rel.x(loctop),pkstop)
scatter(wrist_rel.x(locbot),-pksbot)
axis equal
title('Wrist relative to body center')

%% FINDS THE BODY-LENGTH SCALING FACTOR 

% For further analyses, we need to find the body length for scaling the
% data. This actually have minimal effect on the calculated Strouhal
% number, but was used when generated the shared data used in this paper
% and the paper published in JEB - Lapsansky & Tobalske et al. (2019).

%compute body length
bodylength = sqrt((c.eyex-c.tailx).^2+(c.eyey-c.taily).^2);

figure(4)
plot(bodylength)
title('Body length calculation and smoothing')
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

plot(calib)
hold off

%% COMPUTES WINGBEAT AMPLITUDE (BODY-LENGTHS) AND VELOCITY (BODY-LENGTHS/SEC)

% Now we need to calculate wingbeat amplitude based on the position of the
% wrist and the translational velocity.

% In order to remove the pitch from our calculation of velocity, we need to
% calculate velocity as occuring parallel to the long axis of the body.
% Thus, it's requires some geometry.

% The explanation for this computation can be found in Lapsansky & Tobalske
% (2019) in JEB. The effect on Strouhal number is likely small, but it has
% some appreciable effect on the calculated acceleration.

% First, we calculate the angle between the body line and the horizontal.

if c.eyex(end)>c.eyex(1,1)
    unit_vector = [ones(length(c.eyex),1) zeros(length(c.eyex),1) zeros(length(c.eyex),1)];
else 
    unit_vector = [-1*ones(length(c.eyex),1) zeros(length(c.eyex),1) zeros(length(c.eyex),1)];
end

body_vector =[eye.x-tail.x eye.y-tail.y zeros(length(c.eyex),1)]; % describes a vector pointing from the tail to the eye

crosspr = cross(unit_vector,body_vector);%this computes the cross production of the two vectors
crosspr = crosspr(:,3); %we ditch the parts that are zero.

% Initiate this vector/matrix so that the loop feeds them properly
pitch_angle= (1:size (c))'; 

% calculate how much the body pitches between each frame.
for i=1: size(c)
    pitch_angle(i) = atan2((crosspr(i)),dot(body_vector(i),unit_vector(i)));%this computes the pitch angle using a formula which reports even tiny angles
    %the cos version of this process does not report tiny angles
end

pitch_angle = pitch_angle';
figure(5)
plot(pitch_angle*180/pi);
title('Pitch Angle')

% Initiate these vectors/matrices so that the loop feeds them properly
dxpitch = (1:size (c)-1)';
deltax = (1:size (c)-1)';
deltaxhead = (1:size (c)-1)';
velx= (1:size (c)-1)';
velxhead= (1:size (c)-1)';

l = 0.5; %we assume that the center of rotation is halfway up the body, so at 1/2 bodylengths.

% calculate the velocity due to pitching
for j=1: size(c)-1
    dxpitch(j) = l*cos(pitch_angle(j+1))-l*cos(pitch_angle(j));
    deltaxhead(j) = (eye.x(j+1)-eye.x(j));
    deltax(j) = (tail.x(j+1)-tail.x(j));
    velx(j) = deltax(j)/0.008342;
    velxhead(j) = deltaxhead(j)/0.008342;
end

velx = velx./calib; %calculates velocity in terms of body lengths
velxhead = velxhead./calib; %calculates velocity bsed on the head in terms 
%of body lengths. Not used in this paper due to head bobbing - see
%Lapsansky & Tobalske et al. (2019)

pitchxvel = dxpitch./0.008342; % computes velocity due to pitching

% correct velocity for direction of travel
if mean(velx) < 0
    velx = velx*(-1);
end 
if mean(velxhead) < 0
    velxhead = velxhead*(-1);
end 

%remove velocity due to pitching
velxCorrected = velx+pitchxvel;
velxheadCorrected = velxhead-pitchxvel;
wristy=(wrist.y-(tail.y+eye.y)/2)./calib1;

figure(6)
plot(velx, 'color',  'r')
hold on
plot(velxCorrected, 'color', 'k')
title('Corrected velocity (black) versus uncorrected (red)')

AAAsummary = [wristy [velxCorrected; NaN] ]; %named so that it ends up at the top

% copy paste this data into Igor Pro to computing the wingbeat amplitude
% and velocity of each wingbeat. Then compute the average Strouhal number 
% for that run.

