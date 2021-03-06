function varargout = LineDetection2(varargin)
%LINEDETECTION2 M-file for LineDetection2.fig
%      LINEDETECTION2, by itself, creates a new LINEDETECTION2 or raises the existing
%      singleton*.
%
%      H = LINEDETECTION2 returns the handle to a new LINEDETECTION2 or the handle to
%      the existing singleton*.
%
%      LINEDETECTION2('Property','Value',...) creates a new LINEDETECTION2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to LineDetection2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LINEDETECTION2('CALLBACK') and LINEDETECTION2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LINEDETECTION2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LineDetection2

% Last Modified by GUIDE v2.5 03-Aug-2016 08:42:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LineDetection2_OpeningFcn, ...
                   'gui_OutputFcn',  @LineDetection2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before LineDetection2 is made visible.
function LineDetection2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for LineDetection2
handles.output = hObject;

set(gcf, 'WindowButtonDownFcn', @getLocation);


cfig_file = strcat(pwd,'/SavedConfigurations2.txt');
cid = fopen(cfig_file,'wt');
fprintf(cid,'%20s    %10s    %5s    %11s    %9s    %13s    %50s\n','Image Name','Image Type','Sigma','P','Q','Profile Width','Notes');
fclose(cid);

handles.n = 0;
handles.p = [0; 0];
handles.q = [0; 0];
handles.oldp = [0; 0];
handles.oldq = [0; 0];

handles.i = 0;
set(handles.pushbutton9,'Enable','off')
handles.endofline = false;
handles.I = [];
handles.r1 = [];
handles.r2 = [];

handles.imagewidth = 256;
handles.imageheight = 256;

handles.lineselection = false;
handles.image_name = '';
handles.image_type = '';
handles.current_image = [];

handles.profilewidth = 17;
handles.sigma = 2.0;

handles.notes = '';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LineDetection2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LineDetection2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,FilterIndex] = uigetfile({'*.*'});
handles.image_name = strcat(PathName,FileName);
handles.current_image = imread(handles.image_name);
if ndims(handles.current_image)>2
    handles.image_type = 'RGB';
    guidata(hObject,handles);
    set(handles.radiobutton1,'Value',1);
    set(handles.radiobutton2,'Value',0);
else
    handles.image_type = 'Grayscale';
    
    guidata(hObject,handles);
    disp('done')
    set(handles.radiobutton2,'Value',1);
    set(handles.radiobutton1,'Value',0);
end
guidata(hObject,handles);
set(handles.pushbutton9,'Enable','off');
I = imresize(handles.current_image, [256 256]);
cla(handles.axes1,'reset');
axes(handles.axes1);
imshow(I);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.lineselection = true;
handles.oldp = handles.p;
handles.oldq = handles.q;
set(gcf, 'Pointer', 'crosshair');
guidata(hObject, handles);
return



% --- Executes on mouse press over axes background.
function getLocation(src, event)
handles = guidata(src);
if handles.lineselection==true
    cursorPoint = get(handles.axes1,'CurrentPoint');
    if handles.n==0
        handles.p(2) = round(cursorPoint(1,1));
        set(handles.edit1, 'string', num2str(handles.p(2)));

        handles.p(1) = round(cursorPoint(1,2));
        set(handles.edit2, 'string', num2str(handles.p(1)));

        handles.n = 1;
        guidata(src, handles);
    else 
        handles.q(2) = round(cursorPoint(1,1));
        set(handles.edit3, 'string', num2str(handles.q(2)));

        handles.q(1) = round(cursorPoint(1,2));
        set(handles.edit4, 'string', num2str(handles.q(1)));

        handles.pushbutton2.Value = 0;
        handles.n = 0;
        handles.lineselection = false;
        set(gcf, 'Pointer', 'arrow');
        
        handles.i = 0;
        handles.I = [];
        handles.r1 = [];
        handles.r2 = [];
        handles.endofline = false;
        
        % Save the handles structure.
        guidata(src,handles)

        axes(handles.axes1);
        imshow(imresize(handles.current_image, [256 256]));
        hold on
        plot([handles.p(2),handles.q(2)],[handles.p(1),handles.q(1)],':r*','LineWidth',1)
        text(handles.p(2),handles.p(1),['P (' num2str(handles.p(2)) ',' num2str(handles.p(1)) ')'], 'Color', [1 1 1]);
        text(handles.q(2),handles.q(1),['Q (' num2str(handles.q(2)) ',' num2str(handles.q(1)) ')'], 'Color', [1 1 1]);
    end
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
handles.image_type = 'RGB';
set(handles.radiobutton2,'Value',0);
guidata(hObject,handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
handles.image_type = 'Grayscale';
set(handles.radiobutton1,'Value',0);
guidata(hObject,handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.image_type
    case 'RGB'
        I0 = double(handles.current_image)/255;
        I0 = rgb2gray(I0);.../255
        I0 = imresize(I0, [256 256]);
        %I0 = imgaussfilt(I0,5.0);
    case 'Grayscale'
        %I0 = double(handles.current_image)/255;
        %I0 = imgaussfilt(imresize(I0, [256 256]),2);
        I0 = handles.current_image/255;
        I0 = double(imgaussfilt(imresize(I0, [256 256]),2));
end

d = norm(handles.q-handles.p);
v = (handles.q-handles.p)/d;

I = repmat(I0,[1 1 3]);
handles.imagewidth = 256;
handles.imageheight = 256;
start = -fix((handles.profilewidth)/2);
finish = fix((handles.profilewidth - 1)/2);
i = 0;
while true
    if i<4
        d = norm(handles.q-handles.p);
        uv = (handles.q-handles.p)/d;
        r0 = handles.p+i*uv;
        r = round(r0);
        I(r(1),r(2),1) = 1;
        I(r(1),r(2),2:3) = 0;
        if i==0
            r1 = r;
        end
    else
        direction = r2 - r1;
        distance = norm(direction);
        if distance==0
            break;
        end
        uv = direction/distance;
        r0 = r2 + 2*uv;
        r = round(r0);
        if r(1)>handles.imagewidth
            r(1) = handles.imagewidth;
        end
        if r(2)>handles.imageheight
            r(2) = handles.imageheight;
        end
        if r(1)<1
            r(1) = 1;
        end
        %disp(r)
        I(r(1),r(2),1) = 1;
        I(r(1),r(2),2:3) = 0;
    end
    m = [];
    S = {};
    u = 1;
    for j = start:finish
        s0 = r0+j*[-uv(2); uv(1)];
        s = round(s0);
        if s(1)>handles.imagewidth
                s(1) = handles.imagewidth;
        end
        if s(2)>handles.imageheight
            s(2) = handles.imageheight;
        end
        if s(1)<1
            s(1) = 1;
        end
        if s(2)<1
            s(2) = 1;
        end
        S{u} = s;
        I(s(1),s(2),1) = 1;
        I(s(1),s(2),2:3) = 0;
        m = [m I0(s(1),s(2))];
        u = u + 1; 
    end

    m = smoothts(m, 'g', 5, 0.65);
    mConv = conv(m,fspecial('log',[1 4],handles.sigma),'same');
    smConv = sign(mConv);
    %disp(i)
    %disp(mConv)
    count = 0;
%     disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
%     for q=2:size(mConv,2)-1
%         if smConv(q-1)~=0 && smConv(q-1)==-smConv(q+1) && smConv(q)==0
%             index = q;
%             if i==0
%                 r1 = S{index};
%             elseif i==2
%                 r2 = S{index};
%             else
%                 r1 = r2;
%                 r2 = S{index};
%             end
%             break;
%         end
%     end
%     for q=2:size(mConv,2)-1
%         if mConv(q-1)~=0 && round(mConv(q-1),3)==-round(mConv(q+1),3) && mConv(q)==0
%             count = count + 1;
%             if i==0
%                 r1 = S{q};
%             elseif i==2
%                 r2 = S{q};
%             else
%                 r1 = r2;
%                 r2 = S{q};
%             end
%         end
%     end

    [mx ix] = max(mConv(4:end-3));
    [mn in] = min(mConv(4:end-3));
    if size(ix,2)>1 || size(in,2)>1
        disp('end1')
        break;
    end
    
    if mx~=0 && sign(mx)==-sign(mn) && (in(1)<=ix(1)+2 && in(1)>=ix(1)-2)
        count = 1;
        q = round(((ix(1)+in(1))/2)+3);
        if i==0
            r1 = S{q};
        elseif i==2
            r2 = S{q};
        else
            r1 = r2;
           r2 = S{q};
        end
    end

    if count~=1
        disp('end')
        guidata(hObject,handles);
        break;
    end
%     [pks,lcs] = findpeaks(mConv);
%     if length(pks)~=2
%         break
%     end 
    i = i + 2;
end
handles.endofline=true;
guidata(hObject,handles);
axes(handles.axes1);
imshow(I);
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.endofline==true
    handles.i = 0;
    set(handles.pushbutton9,'Enable','off')
    handles.I = [];
    handles.r1 = [];
    handles.r2 = [];
    handles.endofline = false;
    guidata(hObject,handles);
end
if handles.i==2
    set(handles.pushbutton9,'Enable','on')
end
set(handles.text13,'String',num2str(handles.i));
switch handles.image_type
    case 'RGB'
        I0 = double(handles.current_image)/255;
        I0 = rgb2gray(I0);.../255
        I0 = imresize(I0, [256 256]);
        %I0 = imgaussfilt(I0,5.0);
    case 'Grayscale'
        %I0 = double(handles.current_image)/255;
        %I0 = imgaussfilt(imresize(I0, [256 256]),2);
        I0 = handles.current_image/255;
        I0 = double(imgaussfilt(imresize(I0, [256 256]),2));
end

d = norm(handles.q-handles.p);
v = (handles.q-handles.p)/d;

if handles.i==0
    handles.I = repmat(I0,[1 1 3]);
end
handles.imagewidth = 256;
handles.imageheight = 256;
%%while true
disp(handles.i)
if handles.i<4
    d = norm(handles.q-handles.p);
    uv = (handles.q-handles.p)/d;
    r0 = handles.p+handles.i*uv;
    r = round(r0);
    handles.I(r(1),r(2),1) = 1;
    handles.I(r(1),r(2),2:3) = 0;
    if handles.i==0
        handles.r1 = r;
    end
else
    direction = handles.r2 - handles.r1;
    distance = norm(direction);
    if distance==0
        handles.endofline = true;
        guidata(hObject,handles);
        return
    end
    uv = direction/distance;
    r0 = handles.r2 + 2*uv;
    r = round(r0);
    if r(1)>handles.imagewidth
        r(1) = handles.imagewidth;
    end
    if r(2)>handles.imageheight
        r(2) = handles.imageheight;
    end
    if r(1)<1
        r(1) = 1;
    end
    %disp(r)
    handles.I(r(1),r(2),1) = 1;
    handles.I(r(1),r(2),2:3) = 0;
end
m = [];
S = {};
u = 1;
start = -fix((handles.profilewidth)/2);
finish = fix((handles.profilewidth - 1)/2);
for j = start:finish
    s0 = r0+j*[-uv(2); uv(1)];
    s = round(s0);
    if s(1)>handles.imagewidth
        s(1) = handles.imagewidth;
    end
    if s(2)>handles.imageheight
        s(2) = handles.imageheight;
    end
    if s(1)<1
        s(1) = 1;
    end
    if s(2)<1
        s(2) = 1;
    end
    S{u} = s;
    handles.I(s(1),s(2),1) = 1;
    handles.I(s(1),s(2),2:3) = 0;
    m = [m I0(s(1),s(2))];
    u = u + 1; 
end
axes(handles.axes2);
m = smoothts(m, 'g', 5, 0.65);
plot(m);
%plot(smoothts(m, 'g', 5, 0.65));
title('Base Profile')
mConv = conv(m,fspecial('log',[1 4],handles.sigma),'same');
axes(handles.axes3);
%plot(smoothts(mConv, 'g', 5, 0.65));
plot(mConv)
hold on
line([4 4],[min(mConv) max(mConv)],'Color','r');
hold on
line([size(mConv,2)-3 size(mConv,2)-3], [min(mConv) max(mConv)],'Color','r');
hold off
title('Laplacian of Gaussian')
smConv = sign(mConv);
%disp(handles.i)
%disp(mConv)
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
count = 0;
%for q=4:size(mConv,2)-3
%     if mConv(q-1)~=0 && round(mConv(q-1),3)==-round(mConv(q+1),3) && mConv(q)==0
%         count = count + 1;
%         if handles.i==0
%             handles.r1 = S{q};
%         elseif handles.i==2
%             handles.r2 = S{q};
%         else
%             handles.r1 = handles.r2;
%             handles.r2 = S{q};
%         end
%     end
%end
%smoothts(mConv(4:end-3), 'g', 5, 0.65)
%[mx ix] = max(smoothts(mConv(4:end-3), 'g', 5, 0.65));
%[mn in] = min(smoothts(mConv(4:end-3), 'g', 5, 0.65));

[mx ix] = max(mConv(4:end-3));
[mn in] = min(mConv(4:end-3));
if size(ix,2)>1 || size(in,2)>1
    handles.endofline = true;
    disp('end1')
    guidata(hObject,handles);
    return
end
if mx~=0 && sign(mx)==-sign(mn) && (in(1)<=ix(1)+2 && in(1)>=ix(1)-2)
    count = 1;
    q = round(((ix(1)+in(1))/2)+3);
    if handles.i==0
        handles.r1 = S{q};
    elseif handles.i==2
        handles.r2 = S{q};
    else
        handles.r1 = handles.r2;
        handles.r2 = S{q};
    end
end


if count~=1
    handles.endofline = true;
    disp('end2')
    guidata(hObject,handles);
    return
end
handles.i = handles.i + 2;
guidata(hObject,handles);
%%end

axes(handles.axes1);
imshow(handles.I);
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
handles.profilewidth = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
handles.sigma = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_folder = pwd;
cfig_file = strcat(pwd,'/SavedConfigurations2.txt');
cid = fopen(cfig_file,'at');
initial = strcat(num2str(handles.p(2)),',',num2str(handles.p(1)));
final = strcat(num2str(handles.q(2)),',',num2str(handles.q(1)));
fprintf(cid,'%20s    %10s    %5.2f    %11s    %9s    %13d    %50s\n',handles.image_name,handles.image_type,handles.sigma,initial,final,handles.profilewidth,handles.notes);
fclose(cid);


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.notes = get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.notes = get(hObject,'String');
guidata(hObject,handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop = handles.i - 4;
r1 = [];
r2 = [];
if stop==0
    set(handles.pushbutton9,'Enable','off');
end
switch handles.image_type
    case 'RGB'
        I0 = double(handles.current_image)/255;
        I0 = rgb2gray(I0);.../255
        I0 = imresize(I0, [256 256]);
        %I0 = imgaussfilt(I0,5.0);
    case 'Grayscale'
        %I0 = double(handles.current_image)/255;
        %I0 = imgaussfilt(imresize(I0, [256 256]),2);
        I0 = handles.current_image/255;
        I0 = double(imgaussfilt(imresize(I0, [256 256]),2));
end

d = norm(handles.q-handles.p);
v = (handles.q-handles.p)/d;

I = repmat(I0,[1 1 3]);
handles.imagewidth = 256;
handles.imageheight = 256;
start = -fix((handles.profilewidth)/2);
finish = fix((handles.profilewidth - 1)/2);
i = 0;
while i<=stop
    if i<4
        d = norm(handles.q-handles.p);
        uv = (handles.q-handles.p)/d;
        r0 = handles.p+i*uv;
        r = round(r0);
        I(r(1),r(2),1) = 1;
        I(r(1),r(2),2:3) = 0;
        if i==0
            r1 = r;
        end
    else
        direction = r2 - r1;
        distance = norm(direction);
        if distance==0
            break;
        end
        uv = direction/distance;
        r0 = r2 + 2*uv;
        r = round(r0);
        if r(1)>handles.imagewidth
            r(1) = handles.imagewidth;
        end
        if r(2)>handles.imageheight
            r(2) = handles.imageheight;
        end
        if r(1)<1
            r(1) = 1;
        end
        %disp(r)
        I(r(1),r(2),1) = 1;
        I(r(1),r(2),2:3) = 0;
    end
    m = [];
    S = {};
    u = 1;
    for j = start:finish
        s0 = r0+j*[-uv(2); uv(1)];
        s = round(s0);
        if s(1)>handles.imagewidth
                s(1) = handles.imagewidth;
        end
        if s(2)>handles.imageheight
            s(2) = handles.imageheight;
        end
        if s(1)<1
            s(1) = 1;
        end
        if s(2)<1
            s(2) = 1;
        end
        S{u} = s;
        I(s(1),s(2),1) = 1;
        I(s(1),s(2),2:3) = 0;
        m = [m I0(s(1),s(2))];
        u = u + 1; 
    end

    m = smoothts(m, 'g', 5, 0.65);
    mConv = conv(m,fspecial('log',[1 4],handles.sigma),'same');
    smConv = sign(mConv);
    %disp(i)
    %disp(mConv)
    count = 0;

    [mx ix] = max(mConv(4:end-3));
    [mn in] = min(mConv(4:end-3));
    if size(ix,2)>1 || size(in,2)>1
        disp('end1')
        break;
    end
    
    if mx~=0 && sign(mx)==-sign(mn) && (in(1)<=ix(1)+2 && in(1)>=ix(1)-2)
        q = round(((ix(1)+in(1))/2)+3);
        if i==0
            r1 = S{q};
        elseif i==2
            r2 = S{q};
        else
            r1 = r2;
           r2 = S{q};
        end
    end

    i = i + 2;
end
handles.I = I;
handles.r1 = r1;
handles.r2 = r2;
handles.i = i;
set(handles.text13,'String',num2str(i-2));
guidata(hObject,handles);

axes(handles.axes1);
imshow(I);
axes(handles.axes2);
plot(m);
title('Base Profile')
axes(handles.axes3);
plot(mConv)
hold on
line([4 4],[min(mConv) max(mConv)],'Color','r');
hold on
line([size(mConv,2)-3 size(mConv,2)-3], [min(mConv) max(mConv)],'Color','r');
hold off
title('Laplacian of Gaussian')
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
