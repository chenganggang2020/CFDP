function varargout = maingui(varargin)
% MAINGUI MATLAB code for maingui.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maingui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maingui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maingui

% Last Modified by GUIDE v2.5 24-May-2021 12:20:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @maingui_OpeningFcn, ...
    'gui_OutputFcn',  @maingui_OutputFcn, ...
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


% --- Executes just before maingui is made visible.
function maingui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maingui (see VARARGIN)

% Choose default command line output for maingui
handles.output = hObject;
global imCp result biresult
imCp=[];result=[];biresult=[];
% set(handles.popupmenu1,'Value',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maingui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = maingui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)

% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h T_nonfilter I F T_filter
Route1='.\PolSAR Data\';      %相对路径
myicon = imread('.\picture\错误.jpg');
Data_Case=get(handles.popupmenu1, 'value');
if Data_Case==1
    f = msgbox('请选择影像数据', '别搞了','custom',myicon);
else
switch Data_Case
        case 2
            FileName = 'Flevoland_15cls.mat';
        case 3
            FileName = 'San_Francisco_Lee3.mat';
        case 4
            [FileName,Route1]=uigetfile('.mat','请选择影像文件');
end
    load([Route1,FileName]); % 导入数据
    T11 = double(T11); T12 = double(T12); T13 = double(T13); % 转化为double，不然后续计算容易出错
    T22 = double(T22); T23 = double(T23); T33 = double(T33); % 转化为double，不然后续计算容易出错
    T_nonfilter={T11,T12,T13,T22,T23,T33};
    T3mat = cat(3,T11,real(T12),imag(T12),real(T13),imag(T13),T22,real(T23),imag(T23),T33);     %g构造三维数组
    Pauli_RGB = fPolRGBshow(T3mat,3); % 将极化数据表示为Pauli-RGB伪彩色图像
    load ([Route1,strtok(FileName,'.'),'_T3_filterdata.mat']);
    T3_filterdata = double(T3_filterdata); % 转化为double，不然后续计算容易出错
    T11 = T3_filterdata(:,:,1);
    T12 = T3_filterdata(:,:,2)+1i*T3_filterdata(:,:,3);
    T13 = T3_filterdata(:,:,4)+1i*T3_filterdata(:,:,5);
    T22 = T3_filterdata(:,:,6);
    T23 = T3_filterdata(:,:,7)+1i*T3_filterdata(:,:,8);
    T33 = T3_filterdata(:,:,9);
    T_filter={T11,T12,T13,T22,T23,T33};
    Pauli_RGB_GWLS_Filtered = fPolRGBshow(T3_filterdata,3);
    I=Pauli_RGB_GWLS_Filtered;%滤波后图像
    F=Pauli_RGB;%未滤波的图像
    axes(handles.axes1);
    image(F)
    [m,n]=size(T11);
    axis off;
    h=drawrectangle;%绘制矩形区域用来选取感兴趣区域
    h.Position(1)=max(h.Position(1),1);
    h.Position(2)=max(h.Position(2),1);
    h.Position(1)=min(h.Position(1),n);
    h.Position(2)=min(h.Position(2),m);
    h.Position(3)=min(h.Position(3),n-h.Position(1));
    h.Position(4)=min(h.Position(4),m-h.Position(2));
    h.Position=round(h.Position);
end



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global imCp T I T_nonfilter h result biresult k T_filter processbar
hda=[handles.axes3,handles.axes4,handles.axes5];
for i=1:3
    axes(hda(i));
    cla;
end
filtervalue=get(handles.radiobutton1,'value');%设置是否使用滤波数据聚类
if filtervalue==1
    T=T_filter;
else
    T=T_nonfilter;
end
kvalue=get(handles.popupmenu4,'value');%设置分类个数
sizevalue=get(handles.popupmenu5,'value');%设置超像素大小
k=kvalue+1;%分类个数
pixelsize=sizevalue+2;
mtest=get(handles.popupmenu1, 'value');
myicon = imread('.\picture\错误.jpg');
if(mtest==1)
    f = msgbox('请选择影像数据', '出错啦！','custom',myicon);
elseif(isempty(imCp)==1)
    f = msgbox('请选择需要识别区域', '出错啦！','custom',myicon);
else
    processbar=waitbar(0,'准备中，请稍候！');
    methodtype=get(handles.popupmenu3, 'value');
    switch methodtype
        case 1
            T1=crop_T(T,h.Position);
            result=kmean(T1,k);
        case 2
            Temp={I};
            tem=crop_T(Temp,h.Position);
            T1=cell2mat(tem(1));
            result=kmean(T1,k,0,'Euclidean');
        case 3
            T1=crop_T(T,h.Position);
            Resultcell=SLIC(T1,pixelsize);%调用超像素聚类函数
            superpixel_result=Resultcell{1};
            result=CFDP(Resultcell{2},Resultcell{3},0.5,k);%调用密度聚类函数
            axes(handles.axes5);
            imshow(linear1(superpixel_result));
    end
    waitbar(1,processbar,'即将完成，请稍等...');
    biresult=binaryzation(result(:,:,1));
    axes(handles.axes3);
    imshow(linear1(result));
    axes(handles.axes4);
    imshow(linear1(biresult));
    myicon = imread('.\picture\成功.jpg');
    delete(processbar)
    f = msgbox('运行成功!','Success','custom',myicon);
end
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global imCp biresult result
myicon = imread('.\picture\错误.jpg');
if (isempty(imCp)==1||isempty(result)==1||isempty(biresult)==1)
    f = msgbox('别急！一步一步来', '出错啦！','custom',myicon);
else
    culturetype=get(handles.popupmenu2, 'value');
    str = datestr(now,'yyyy-mm-dd HH_MM_SS');
    binarystr='二值化';
    clusterstr='聚类';
    switch culturetype
        case 1
            mkdir '森林'
            imwrite(imCp,['.\森林\',str ,'.jpg']);
            imwrite(result,['.\森林\',str,clusterstr ,'.jpg']);
            imwrite(biresult,['.\森林\',str,binarystr ,'.jpg']);
        case 2
            mkdir '水体'
            imwrite(imCp,['.\水体\',str ,'.jpg']);
            imwrite(result,['.\水体\',str,clusterstr ,'.jpg']);
            imwrite(biresult,['.\水体\',str,binarystr ,'.jpg']);
        case 3
            mkdir '住宅区'
            imwrite(imCp,['.\住宅区\',str ,'.jpg']);
            imwrite(result,['.\住宅区\',str ,clusterstr,'.jpg']);
            imwrite(biresult,['.\住宅区\',str,binarystr ,'.jpg']);
        case 4
            mkdir '农田'
            imwrite(imCp,['.\农田\',str ,'.jpg']);
            imwrite(result,['.\农田\',str,clusterstr ,'.jpg']);
            imwrite(biresult,['.\农田\',str,binarystr ,'.jpg']);
        case 5
            mkdir '机场'
            imwrite(imCp,['.\机场\',str ,'.jpg']);
            imwrite(result,['.\机场\',str,clusterstr ,'.jpg']);
            imwrite(biresult,['.\机场\',str,binarystr ,'.jpg']);
        case 6
            mkdir '公路'
            imwrite(imCp,['.\公路\',str ,'.jpg']);
            imwrite(result,['.\公路\',str,clusterstr ,'.jpg']);
            imwrite(biresult,['.\公路\',str,binarystr ,'.jpg']);
    end
    myicon = imread('.\picture\成功.jpg');
    f=msgbox('保存成功！快去看看吧！','sucess','custom',myicon);
end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(maingui)

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)

% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% global  imCp
% imCp=[];
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2



function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global h F imCp I
if strcmp(get(gcf,'SelectionType'),'alt')
    pos=h.Position;
    myicon = imread('.\picture\001.jpg');
    if(pos(1,3)<=1||pos(1,4)<=10)
        f = msgbox('你再画小点！','不要搞啊！','custom',myicon);
    else
        %未滤波图像显示
        imCp = imcrop( F, pos );
        axes(handles.axes2)
        imshow(imCp);
        %滤波后图像显示
        imCpI = imcrop( I, pos );
        axes(handles.axes6)
        imshow(imCpI);
    end
end
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
value=get(handles.popupmenu3, 'value');
if value==3
    set(handles.popupmenu5,'Visible','on')
    set(handles.text9,'Visible','on')
    set(handles.text1,'Visible','on')
    set(handles.axes5,'Visible','on')
else
    set(handles.popupmenu5,'Visible','off')
    set(handles.text9,'Visible','off')
    set(handles.text1,'Visible','off')
    set(handles.axes5,'Visible','off')
    axes(handles.axes5);
    cla;
end
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global biresult
biresult=1-linear1(biresult);
    axes(handles.axes4);
    imshow(biresult);
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
