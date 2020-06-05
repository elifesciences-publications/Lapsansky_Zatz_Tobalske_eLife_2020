%% Lapsansky, Zatz, & Tobalske (2020) eLife

%this MatLab script is used to creating the figures included in the
%above-mentioned manuscript. Note that it relies on a 'Gramm' Toolbox
%created by Pierre Morel (https://doi.org/10.21105/joss.00568). You will
%need to download that toolbox at add it to your working directory for
%these plots to function properly.

%% Figure 2

% Plots  aerial and aquatic strouhal data - Figure 2

% Uses file named 'Figure 2 - Source Data' 

% Note: you have to change the column labeled 'tag' to categorical upon
% importing or you get an error from the gramm toolbox.

% NOTE: Some visual aspects of the figure were edited in Adobe Illustrator 
% to enhance readability. Read the methods section for details on
% calculating strouhal number during aerial flight based on both ground
% velocity and estimated fluid velocity.

% Change the name of the imported file to "Figure2"

clear h  %  clear figure in case it already exists

figure(2)   

%set up the initial plot
h=gramm('x',Figure2.tag,'y',Figure2.strouhal,'ymin',Figure2.st_lowerBound,'ymax',Figure2.st_upperBound,'color', Figure2.type, 'lightness',Figure2.velocityReference)

% Note: you have to change the column labeled 'tag' to categorical upon
% importing or you get an error from the gramm toolbox.

h.geom_point();
h.axe_property('YLim',[0 0.75]);
h.axe_property('XTickLabels',[]);
h.geom_interval('geom','errorbar');
h.axe_property('XTickLabelRotation',90); 
h.geom_polygon('y',{[0.2 0.4]},'color',[0.5 0.5 0.5]);
h.geom_vline('xintercept',14.5, 'style', 'k:')
h.geom_vline('xintercept',27.5, 'style', 'k:')
h.geom_vline('xintercept',40.5 ,'style', 'k:')
h.geom_polygon('y',{[0.12 0.47]},'color',[0.35 0.35 0.35]);
h.set_names('x','','y','Strouhal Number')

h.draw()

text(-33,1,'Common murre','FontSize',16);
text(-24.5,1,'Horned puffin','FontSize',16);
text(-17,1,'Pigeon guillemot','FontSize',16);
text(-8,1,'Tufted puffin','FontSize',16);


%% Figure 3

% Plots stroke velocity from the file named "Figure 3 - Source Data"
% Also compute statistical tests for stroke velocity.

%blue color =0.00,0.45,0.74
%red color= 1.00,0.37,0.41

clear a
figure(3)

a(1,1)=gramm('x', Figure3.Species,'y', Figure3.upstrokeVelocity, 'color', Figure3.Fluid, 'subset', Figure3.Species~='')
a(1,1).stat_boxplot()
a(1,1).set_names('x','','y','Angular Velocity (deg s^{-1})')
a(1,1).axe_property('XTickLabel','')
a(1,1).set_title('Upstroke Velocity','FontSize',12)
a(2,1)=gramm('x', Figure3.Species,'y', Figure3.downstrokeVelocity, 'color', Figure3.Fluid, 'subset', Figure3.Species~='')
a(2,1).stat_boxplot()
a(2,1).set_names('x','','y','Angular Velocity (deg s^{-1})')
a(2,1).set_title('Downstroke Velocity','FontSize',12)
a.axe_property('YLim',[0 2500]);
a.draw()
set(0,'ShowHiddenHandles','on') 
set(findobj(gcf,'Type','text'),'Interpreter','tex')


%% Figure 5

% this section is for plotting stroke angle using the file
% 'Figure 5 - Source Data'


clear e
figure(5)

e(1,1)=gramm('x',Figure5.descentAngle,'y', Figure5.strokeAngle, 'subset', Figure5.fluid=='air', 'color', Figure5.Species)
e(1,1).geom_jitter()
e(1,1).set_names('x','Aerial flight','y','Chord Angle (deg)')
e(1,1).axe_property('YLim',[60 120], 'XLim', [-1 1]);
e(1,1).set_layout_options('legend',false)

e(1,2)=gramm('x',Figure5.descentAngle,'y', Figure5.strokeAngle, 'subset', Figure5.fluid=='water', 'color', Figure5.Species)
e(1,2).geom_point()
e(1,2).set_names('x','Aquatic flight descent angle (deg)','y','Chord Angle (deg)')
e(1,2).axe_property('YLim',[60 120], 'XLim', [-10 60]);
e.set_point_options('base_size',7.5)
e.draw()


%% Figure 6

% plots the chord angle data from the file named "Figure 6 - Source Data"

%green color = 0.03,0.71,0.29
%blue color =0.00,0.45,0.74

clear c
figure(6)

c(1,1)=gramm('x',Figure6.descentAngle,'y',Figure6.upstrokeChordAngle, 'color', Figure6.Species)
c(1,1).geom_jitter('dodge', 3)
c(1,1).set_names('x','Descent angle (deg)','y','Angle of incidence (deg)')
c(1,1).set_title('Upstroke','FontSize',12)
c(2,1)=gramm('x',Figure6.descentAngle,'y',Figure6.downstrokeChordAngle, 'color', Figure6.Species)
c(2,1).geom_jitter('dodge', 3)
c(2,1).set_names('x','Descent angle (deg)','y','Angle of incidence (deg)')
c(2,1).set_title('Downstroke','FontSize',12)
c.set_point_options('base_size',7.5)
c.axe_property('YLim',[0 60]);
c.draw()

