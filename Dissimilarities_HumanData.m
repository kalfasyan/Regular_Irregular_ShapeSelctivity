clear;
figure;
groupnames = {'R','IC','ISC','ISS','ISC\_ISS'};

humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
SEmeasured = [8.4; 0.75; 1.5; 3.35; 20.45];
SE = humanM - SEmeasured;

y = humanM;
x = 1:length(y);

h = plot(x,y,'.');
axis([0.5,5+0.5,0,25]);
set(gca,'XTick',x,'XTickLabel',groupnames,'XTickLabelRotation',60)
title('Original Figure from Paper')
grid on
hold on

errorbar(x,y,SE,'.')
hold off