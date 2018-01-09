% function tsne_click(hObject,event_obj,mapped_x,cell_id,frame_id,cell_id_data,frame_id_data,clc_result,scan_id,coi_size)
%
% DESC:
%   Display 4 channels (DAPI, CD45, Ck, M1) of the selected cell on the 
%   t-SNE plot. This function pairs with function draw_tsne.m, which
%   display the t-SNE plot.
%
% INPUTS:
%   hObject: default MATLAB input for plot handle (NOT USED)
%   event_obj: MATLAB output for clicking action done on plot (use this to
%   determine, which cell is clicked)
%   cell_id: cell_id of the clicked cell
%   frame_id: frame_id of the clicked cell
%   cell_id_data: vectors of cell_id extracted from clc_result use this to
%   compare to cell_id
%   frame_id_data: vectors of frame_id extracted from clc_result use this
%   to compare to frame_id
%   clc_result: cell data that is used to display images
%   scan_id: slide ID of the t-SNE (for title display purposes)
%   coi_size: number of pixels for display image (length and width)
%
% AUTHOR:
%   Shane Yuan shane.yuan@epicsciences.com
%
% NOTE:
%   It may be redundant to have to additional inputs (cell_id_data and
%   frame_id_data), since they are straight up extract from clc_result.
%   They are included to reduce the need to run cellfun each time. Can be
%   taken out in future version
%

function tsne_click(hObject,event_obj,mapped_x,label,data,coi_size,ax_img)
global highlight_tsne;
%delete previous pop up
if ~isempty(highlight_tsne)
    delete(highlight_tsne)
end

%mouse position
x = event_obj.IntersectionPoint(1);
y = event_obj.IntersectionPoint(2);

%look for closest data point to mouse pos
distance = (mapped_x(:,1)-x).^2 + (mapped_x(:,2)-y).^2;
[~, index] = min(distance);

%index targets cell_data
size_dot = 25;
hold on
highlight_tsne = scatter(mapped_x(index,1),mapped_x(index,2),size_dot,'or','LineWidth',2);
hold off

t = title(sprintf('Label: %s',num2str(label(index)))); 
%TODO this part I hard coded so the text does not cross the panel border
set(t,'FontSize',10);

if ~isempty(data{index}) %if image data exists
    % display each channel
    axes(ax_img);
    imshow(data{index});
    title('Composite')
    axis image;
    axis off;
else %clear axis
    axes(ax_img);
    title('');
    axis off;
    cla;
end