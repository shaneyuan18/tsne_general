% function [] = draw_tsne(mapped_x,group_id,color_data)
%
% DESC:
%   Display computed t-SNE results of the cells. This function works with
%   function t-sne_click.m, which visualize the selected data point.
%
% INPUTS:
%   mapped_x: X and Y coordinates of the t-SNE plot
%   group_id: labels for class 0 and 1 (1 = 'CLC' / 0 = 'WBC')
%   scan_id: slide ID of the t-SNE (for title display purposes)
%
% AUTHOR:
%   Shane Yuan shane.yuan@epicsciences.com
%

function [] = draw_tsne(mapped_x,group_id,color_data)


    [label,types] = grp2idx(group_id);

size_dot = 25;

hold on
for i = 1:length(types)
    mapped_x_sel = mapped_x(label == i,:);
    scatter(mapped_x_sel(:,1),mapped_x_sel(:,2),size_dot,color_data(i,:),'filled','MarkerEdgeColor',[0 0 0]);
end
hold off
axis equal

[tsne_legend,object_h,~,~] = legend(types,'AutoUpdate','off');
row_limit = 10;
if length(types) > row_limit
    num_col = ceil(length(types)/row_limit);
    num_row = ceil(length(types)/num_col);
    margin_y = object_h(length(types)).Position(2);
    dx = 1/num_col;
    for i = 1:length(types)
        if rem(i,num_row) == 0
            row = num_row;
        else
            row = mod(i,num_row);
        end
        object_h(i).Position(1) = floor((i-1)/num_row)*dx + object_h(i).Position(1)/num_col;
        object_h(i).Position(2) = margin_y*2 + (row-1)* (1-margin_y)/ceil(length(types)/num_col);
        object_h(i+length(types)).Children.XData = floor((i-1)/num_row)*dx + object_h(i+length(types)).Children.XData / num_col;
        object_h(i+length(types)).Children.YData = margin_y * 2 + (row-1)* (1-margin_y)/num_row;
    end
    pos = tsne_legend.Position;
    tsne_legend.FontSize = 1;
    tsne_legend.Position(4) = pos(4) /2;
    tsne_legend.Position(3) = pos(3) *2;
end
%tsne_legend.FontSize = 7.5;
curr_ax = gca;
boundary = curr_ax.Position;
boundary_legend = tsne_legend.Position;
boundary_legend(1) = boundary(1) - boundary_legend(3);
boundary_legend(2) = boundary(2);
set(curr_ax,'YAxisLocation','right');
set(tsne_legend,'Position',boundary_legend);
set(tsne_legend,'HitTest','off');
