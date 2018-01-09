function varargout = tsne_general_main(varargin)
% DESC:
%   Display computed t-sne results in a more user-friendly setting.
%
% VERSION:
%   0.5 : The first release version. 
%
% AUTHORS:
%   Shane Yuan shane.yuan@epicsciences.com
% Edit the above text to modify the response to help tsne_general_main

% Last Modified by GUIDE v2.5 24-Jul-2017 13:12:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ... 
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tsne_general_main_OpeningFcn, ...
                   'gui_OutputFcn',  @tsne_general_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tsne_general_main is made visible.
function tsne_general_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tsne_general_main (see VARARGIN)

% clearing global variables
clearvars -global;

global ghandles_general;
global load_base_dir;
global coi_size;
global icon;

ghandles_general = handles;
%DECLARE variables
coi_size  = 78; %pixel length and width for cell images
% folder for loading files
load_base_dir = pwd;
ver = 0.5;

icon_zoom = convert_icon(imread(fullfile('icon','zoom.jpg')));
icon_show = convert_icon(imread(fullfile('icon','show.jpg')));
icon_pan = convert_icon(imread(fullfile('icon','pan.jpg')));
icon_cancel = convert_icon(imread(fullfile('icon','cancel.jpg')));
icon = containers.Map({'zoom','pan','show','cancel'},{icon_zoom,icon_pan,icon_show,icon_cancel});
set(handles.pushbutton_zoomin,'CData',icon_zoom);
set(handles.pushbutton_showall,'CData',icon_show);
set(handles.pushbutton_pan,'CData',icon_pan);


set(handles.text_csv_status,'String','');
set(hObject,'Name',sprintf('t-SNE Viewer ver%.1f [RUO]',ver));
restore_default();
% Choose default command line output for tsne_general_main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set_path_local


% UIWAIT makes tsne_general_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tsne_general_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function restore_default()
global ghandles_general;

set(ghandles_general.pushbutton_zoomin,'Enable','off');
set(ghandles_general.pushbutton_showall,'Enable','off');
set(ghandles_general.pushbutton_pan,'Enable','off');

axes(ghandles_general.ax_tsne);
zoom out
zoom off
title('');
axis off;
cla;
axes(ghandles_general.ax_img);
title('');
axis off;
cla;
tsne_legend = findobj(ghandles_general.uipanel_tsne.Children,'type','Legend');
delete(tsne_legend);
set(ghandles_general.pushbutton_zoomin,'UserData',0);
set(ghandles_general.pushbutton_pan,'UserData',0);


function [icon] = convert_icon(icon)
icon = imresize(icon,[30,30]);

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global train_data;
global load_base_dir;

%check if the train_data already exist
[file_name,path_name] = uigetfile(sprintf('%s\\*.mat',load_base_dir),'Load t-SNE Data');
if file_name == 0
    return
end
dlg = waitbar(0.5,{'Please wait...' 'Loading Cell Data'},'Name','Loading');
data = load(fullfile(path_name,file_name));
%check if load data is correct
if ~isfield(data,'train_X')
    restore_default();
    errordlg('Not a cell data file!','Loading Error');
    if ishghandle(dlg)
        delete(dlg)
    end
    return
end
train_data = data.train_X;
clear data;
if ishghandle(dlg)
    waitbar(1,dlg);
end

set(handles.text_csv_status,'String',sprintf('%s Loaded',file_name));

if ishghandle(dlg)
    delete(dlg)
end

% --- Executes on button press in pushbutton_tsne.
function pushbutton_tsne_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_tsne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global load_base_dir;
global coi_size;
global train_data;
global mapped_x;
global label;
global color_data;

% items = allchild(handles.uipanel_tsne);
% delete(items);
%if no train_data is loaded, ask user to load first
if isempty(train_data)
    errordlg('Please load t-SNE data first','Error');
    return
end

[file_name,path_name] = uigetfile(sprintf('%s\\*.mat',load_base_dir),'Load t-SNE');
if file_name == 0
    return
end
data = load(fullfile(path_name,file_name));

% %check if tsne file is valid
% field_names = {'mapped_x','label','label_vector'};
% missing_field = false(length(field_names),1);
% for j = 1:length(field_names)
%     if ~isfield(data,field_names{j})
%         missing_field(j) = true;
%     end
% end
% error = any(missing_field);
% missing_field = field_names(missing_field);
% if error
%     for i = 1:length(missing_field)
%         if i == 1
%             msg = sprintf('%s',missing_field{i});
%         else
%             msg = sprintf('%s, %s',msg,missing_field{i});
%         end
%     end
%     restore_default();
%     errordlg({'Not a valid t-SNE file',sprintf('%s',msg),'variables are missing'},'File Error');
%     return;
% end

mapped_x = data.mappedX;
label = data.train_labels;
clear data;
% else %Case 2 user choose to compute new results
%     if isempty(train_data)
%         msgbox('Please load data with compile csv first','Data not found','error');
%         return
%     else
%         confirm = false;
%         while ~confirm
%             allow user input column numbers for feature selections
%             feature_choice = [];
%             while isempty(feature_choice)
%                 prompt = {'Enter column numbers for selected features: eg. 9 10 11 12 13 14 or 9:14',...
%                     'Enter column number for data grouping:'};
%                 dlg_title = 'Feature selections (seperate by space or colon)';
%                 num_lines = [1 80];
%                 defaultans = {'9 10 11 12 13 14','8'};
%                 feature_choice = inputdlg(prompt,dlg_title,num_lines,defaultans);
%             end
%             group_select = str2double(feature_choice{2});
%             feature_choice = str2num(feature_choice{1});
%             headers = fieldnames(train_data{1});
%             feature_choice = headers(feature_choice);
%             group_select = headers(group_select);
%             
%             Allow user to check their inputs
%             confirm = questdlg({'Is this correct?' 'Input Features:' char(feature_choice) '' 'Group Label:' group_select{1}}, ...
%                 'Feature select', ...
%                 'Yes','No redo','No redo');
%             confirm = strcmp(confirm,'Yes');
%         end
%         testing_instance_matrix = extract_features(train_data,feature_choice);
%         label = cellfun(@(x) (x.(group_select{1})),train_data,'UniformOutput', false);
%         Set parameters
%         no_dims = 2;
%         initial_dims = min(50,length(feature_choice));
%         perplexity = 30;
%         Run t-SNE
%         mapped_x = tsne(testing_instance_matrix, [], no_dims, initial_dims, perplexity);
%         
%         choice = [];
%         ask to save tsne
%         while isempty(choice)
%             choice = questdlg({'Do you want to save t-SNE mapped results?'}, ...
%                 'Save Options', ...
%                 'Yes','No','No');
%         end
%         
%         if strcmp(choice,'Yes')
%             default_name = sprintf('tsne.mat');
%             default_path = fullfile(load_base_dir,default_name);
%             [file_name,path_name] = uiputfile(default_path,'Save as');
%             if file_name ~= 0
%                 save(fullfile(path_name,file_name),'mapped_x','label');
%             end
%         end
%     end
% end

%hard code coloring CellTypeK as red
[~,types] = grp2idx(label);
color_data = [1,0,0; 1,0,1; 0,1,0;1,1,0;0,0,1;0,1,1];
if length(types) > size(color_data,1)
    color_data = [distinguishable_colors(length(types))];
else
    color_data = color_data(1:length(types),:);
end

% axes('Parent',handles.uipanel_tsne);
% subplot(2,4,[1,2,5,6])
restore_default()
axes(handles.ax_tsne);
set(handles.ax_tsne,'Visible','on');
draw_tsne(mapped_x,label,color_data);
zoom off
zoom reset
% tsne_plot = findobj(handles.uipanel_tsne.Children,'type','Axes');
tsne_plot = handles.ax_tsne;

for i = 1:length(tsne_plot.Children)
    set(tsne_plot.Children(i), 'buttondownfcn', {@tsne_click,mapped_x,label,train_data,coi_size,...
        handles.ax_img}); 
end
set(handles.pushbutton_zoomin,'Enable','on');
set(handles.pushbutton_showall,'Enable','on');
set(handles.pushbutton_pan,'Enable','on');


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global load_base_dir;
global train_data;
global mapped_x;
global label;
global color_data;

if ~isempty(mapped_x)
    choice = [];
    %ask to save tsne
    while isempty(choice)
        choice = questdlg({'Do you want to save t-SNE mapped results?'}, ...
            'Save Options', ...
            'Yes','No','No');
    end

    if strcmp(choice,'Yes')
        default_name = sprintf('tsne.mat');
        default_path = fullfile(load_base_dir,default_name);
        [file_name,path_name] = uiputfile(default_path,'Save as');
        if file_name ~= 0
            save(fullfile(path_name,file_name),'mapped_x','label');
        end
    end

    choice = [];
    %ask to save tsne figure
    while isempty(choice)
        choice = questdlg({'Do you want to save t-SNE figure?'}, ...
            'Save Options', ...
            'Yes','No','No');
    end
    choice = strcmp(choice,'Yes');

    if choice
        file_name = sprintf('tsne.png');
        full_path = fullfile(load_base_dir,file_name);
        [file_name,path_name] = uiputfile(full_path,'Save as');
        if file_name ~= 0
        	dlg = msgbox('Save operation in progress...');
            full_path = fullfile(path_name,file_name);
            tsne_fig = figure('color','w','units','normalized','outerposition',[0 0 1 1],'Visible', 'off');
            draw_tsne(mapped_x,label,color_data);
            hgexport(tsne_fig, full_path, hgexport('factorystyle'),'Format','png');
            delete(tsne_fig);
            if ishghandle(dlg)
                delete(dlg);
            end
        end
    end
end


if ~isempty(train_data)
    choice = [];
    %ask to save cell data
    while isempty(choice)
        choice = questdlg({'Do you want to save compiled cell data?'}, ...
            'Save Options', ...
            'Yes','No','No');
    end

    if strcmp(choice,'Yes')
        default_name = sprintf('train_data.mat');
        default_path = fullfile(load_base_dir,default_name);
        [file_name,path_name] = uiputfile(default_path,'Save as');
        if file_name ~= 0
            save(fullfile(path_name,file_name),'train_data');
        end
    end
end
    


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global mapped_x;
% global label;
% global color_data;
% global train_data;
% global coi_size;
% 
% axes(handles.ax_tsne);
% draw_tsne(mapped_x,label,color_data);
% 
% % tsne_plot = findobj(handles.uipanel_tsne.Children,'type','Axes');
% tsne_plot = handles.ax_tsne;
% 
% for i = 1:length(tsne_plot.Children)
%     set(tsne_plot.Children(i), 'buttondownfcn', {@tsne_click,mapped_x,label,train_data,coi_size,...
%         handles.ax_dapi,handles.ax_cd45,handles.ax_ck,handles.ax_cd45,handles.ax_composite}); 
% end



% --- Executes on button press in pushbutton_zoomin.
function pushbutton_zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global icon;

if hObject.UserData == 0
    axes(handles.ax_tsne)
    zoom on
%     hFig = gcf;
%     hManager = uigetmodemanager(hFig);
%     try
%         set(hManager.WindowListenerHandles, 'Enable', 'off');  % HG1
%     catch
%         [hManager.WindowListenerHandles.Enabled] = deal(false);  % HG2
%     end
%     set(hFig, 'WindowKeyPressFcn', {@figure1_WindowButtonDownFcn,hObject, eventdata, handles});
%     set(hFig, 'KeyPressFcn',@myKeyPressCallback);
    set(hObject,'ToolTip','End Zoom');
    set(hObject,'UserData',1);
    set(handles.pushbutton_zoomin,'CData',icon('cancel'));
    set(handles.pushbutton_pan,'CData',icon('pan'));
    set(handles.pushbutton_pan,'UserData',0);
    set(handles.pushbutton_pan,'ToolTip','Pan On');

else
    axes(handles.ax_tsne)
    zoom off
    set(hObject,'ToolTip','Zoom In');
    set(hObject,'UserData',0);
    set(handles.pushbutton_zoomin,'CData',icon('zoom'));
end

% --- Executes on button press in pushbutton_showall.
function pushbutton_showall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_showall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.ax_tsne)
zoom out


% --- Executes on button press in pushbutton_pan.
function pushbutton_pan_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global icon;

if hObject.UserData == 0
    axes(handles.ax_tsne)
    pan on
    set(hObject,'UserData',1);
    set(handles.pushbutton_pan,'CData',icon('cancel'));
    set(handles.pushbutton_zoomin,'CData',icon('zoom'));
    set(handles.pushbutton_zoomin,'UserData',0);
    set(handles.pushbutton_zoomin,'ToolTip','Zoom In');
    set(hObject,'ToolTip','Pan Off');
else
    axes(handles.ax_tsne)
    pan off
    set(hObject,'UserData',0);
    set(hObject,'ToolTip','Pan On');
    set(handles.pushbutton_pan,'CData',icon('pan'));
end
