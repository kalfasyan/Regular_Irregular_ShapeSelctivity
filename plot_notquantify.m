function plot_notquantify(N,dim1,qq,SE, layerchoice, layer)

% barplots showing the dissimilarities for each of the
% groups.
y = mean(N);
x = 1:length(y);

subplot(dim1,dim1+1,qq);
h = plot(x,y,'.');
axis([0.5,6.5,min(mean(N))-max(SE)*1.2,max(mean(N))+max(SE)*1.2]);
set(gca,'XTick',x, 'box', 'off');
title(layerchoice);
hold on
errorbar(x,y,SE,'.')
hold off
% if qq == numel(layer)                    
%     saveas(gcf,['/home/luna.kuleuven.be/u0107087/Desktop/' network '_neural.bmp'])
% end
end