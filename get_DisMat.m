function [M] = get_DisMat(network, laychoice)
addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions/
addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions/export_fig

stimchoice = 'regularIrregular';%'regularIrregularSmall2x';%
distType = 'euclidean';

layer = getLayersFromNetwork(network)';
load([network '_D_' stimchoice '_' distType '.mat']);

idx = find(~cellfun(@isempty,strfind(layer,laychoice)));
M = D{idx};

[~, vv] = sort(M(:));
[~, vv] = sort(vv);
[~, jj, kk] = unique(M(:), 'first');
M = reshape(vv(jj(kk)), size(M));

imagesc(M);
M_no0 = M(:); M_no0(M_no0==1) = [];
caxis([min(M_no0) max(M_no0)]);

title(laychoice);
set(gca,'XTick',[]);
set(gca,'XTickLabel',[]);
set(gca,'YTick',[]);
set(gca,'YTickLabel',[])
color = get(gcf,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out');
set(gca,'Visible','off');

% export_fig test.eps -native
export_fig(['/media/yannis/HGST_4TB/Ubudirs/Figures_Regireg/' network '_' laychoice '.eps'])
close
% saveas(gcf,['/media/yannis/HGST_4TB/Ubudirs/Figures_Regireg/' network '_' laychoice '.svg'])
end

% M = get_DisMat('alexnet','fc8')
% /media/yannis/HGST_4TB/Ubudirs/Figures_Regireg