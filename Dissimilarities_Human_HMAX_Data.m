clear; close all
groupnames = {'R','IC','ISC','ISS','ISC\_ISS'};

humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
SEmeasured = [8.4; 0.75; 1.5; 3.35; 20.45];
SE = humanM - SEmeasured;
% figure;

% y = humanM;
% x = 1:length(y);
% 
% h = plot(x,y,'.');
% axis([0.5,5+0.5,0,25]);
% set(gca,'XTick',x,'XTickLabel',groupnames,'XTickLabelRotation',60)
% title('Original Figure from Paper (human)')
% grid on
% hold on
% 
% errorbar(x,y,SE,'.')
% hold off
%%
figure;
SEmeasuredHmax = [0.4721; 0.3532; 0.2846; 0.3613; 0.389;];
hmaxM = [0.42; 0.3268; 0.2625; 0.3196; 0.3406];
SE2 = SEmeasuredHmax - hmaxM;

y2 = hmaxM;
x2 = 1:length(y2);

h = plot(x2,y2,'.');
axis([0.5,5+0.5,0.2,0.5]);
set(gca,'XTick',x2,'XTickLabel',groupnames,'XTickLabelRotation',60)
title('Original Figure from Paper (hmax)')
% grid on
hold on

errorbar(x2,y2,SE2,'.')
hold off
%%
figure;
SEmeasuredPIXELS = [41.41; 44.78; 42.47; 41.49; 33.64;];
pixelsM = [38.38; 41.18; 38.91; 38.11; 31.18;];
SE3 = SEmeasuredPIXELS - pixelsM;

y3 = pixelsM;
x3 = 1:length(y3);

h = plot(x3,y3,'.');
axis([0.5,5+0.5,27,46]);
set(gca,'XTick',x3,'XTickLabel',groupnames,'XTickLabelRotation',60)
title('Original Figure from Paper (pixels)')
% grid on
hold on

errorbar(x3,y3,SE3,'.')
hold off