function varargout = TNZ_CENTROID(varargin)
% TNZ_CENTROID MATLAB code for TNZ_CENTROID.fig
%      TNZ_CENTROID, by itself, creates a new TNZ_CENTROID or raises the existing
%      singleton*.
%
%      H = TNZ_CENTROID returns the handle to a new TNZ_CENTROID or the handle to
%      the existing singleton*.
%
%      TNZ_CENTROID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TNZ_CENTROID.M with the given input arguments.
%
%      TNZ_CENTROID('Property','Value',...) creates a new TNZ_CENTROID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TNZ_CENTROID_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TNZ_CENTROID_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TNZ_CENTROID

% Last Modified by GUIDE v2.5 15-Dec-2016 09:09:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TNZ_CENTROID_OpeningFcn, ...
    'gui_OutputFcn',  @TNZ_CENTROID_OutputFcn, ...
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

% --- Executes just before TNZ_CENTROID is made visible.
function TNZ_CENTROID_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TNZ_CENTROID (see VARARGIN)

% Choose default command line output for TNZ_CENTROID
handles.output = hObject;
handles.data.UserUseHeatProduction = 0; %default
handles.data.UserUseBodyFatForSkinThickness = 1; %default
handles.data.UserUseCalculatedAlpha = 1; %default

handles.data.UserHeatProduction = 100; %default
handles.data.UserTemperatureMeanSkin = 33.3; %default
handles.data.UserTemperatureOperative = 21; %default


% Update handles structure
guidata(hObject, handles);
set(handles.figure1,'Name','Thermoneutralizer')
% UIWAIT makes TNZ_CENTROID wait for user response (see UIRESUME)
% uiwait(handles.figure1);
updateValues(handles);

function updateValues(handles)

age = get( handles.sliderAge,'Value');
height = get( handles.sliderHeight,'Value');
weight = get( handles.sliderWeight,'Value');
sex = get(handles.popupmenuSex, 'Value' );

fat = get( handles.sliderBodyfat,'Value');

sft = get( handles.sliderSkinfolds,'Value');
% % % % Veicsteinas data
% % bodyfat	mft	sft	shell
% % 8.8	1.1	2	3.1
% % 10.1	1.4	2	3.4
% % 10.6	1.5	2	3.5
% % 13.4	2.4	2	4.4
% % 13.5	2.5	2	4.5
% % 17.6	4.1	2	6.1
% % 18	4.3	2	6.3
% % 20.7	5.6	2	7.6
% % 27.2	9.6	2	11.6
if( handles.data.UserUseBodyFatForSkinThickness )
    sft = 1.6499 * exp( 0.073 * fat ); %veicsteinas relation r^2 = 0.997
end
sft = round(10*sft)/10;

clothing = get( handles.sliderClothing,'Value');
activity = get( handles.sliderActivity,'Value');
v_air = get( handles.sliderAirvelocity,'Value');
rh = get( handles.sliderRelativeHumidity,'Value');
w = get( handles.sliderSkinWettedness,'Value') / 100;
alpha = get( handles.sliderRespiratory,'Value') / 100;
if( handles.data.UserUseCalculatedAlpha )
    alpha = -1;
end

metrateSource = 'Harris & Benedict (1918)';
if( handles.data.UserUseHeatProduction )
    BMR = handles.data.UserHeatProduction;
    metrateSource = 'user defined';
else
    kcalday2watts = 4184/(24*60*60);
    
    BMR = 0;
    if( sex == 1 ) %male
        BMR = ( 13.397*weight + 4.799*height - 5.677*age + 88.362 ) * kcalday2watts;%( 13.75*weight + 5.003*height - 6.755*age + 66.5 ) * kcalday2watts;%
    elseif (sex == 2)%female
        BMR = ( 9.247*weight + 3.098*height - 4.330*age + 447.593 ) * kcalday2watts;%( 9.563*weight + 1.850*height - 4.676*age + 655.1 ) * kcalday2watts;%
%     elseif (sex == 3)%pirate
%         BMR = ( 9.247*weight + 3.098*height - 4.330*age + 447.593 ) * kcalday2watts;%( 9.563*weight + 1.850*height - 4.676*age + 655.1 ) * kcalday2watts;%
%         BMR = BMR + ( 13.397*weight + 4.799*height - 5.677*age + 88.362 ) * kcalday2watts;
%         BMR = BMR/2;
    end
end
A = 0.007184 * weight^0.425 * height^0.725; %Dubois
Icl =  clothing*0.155;

%kingma parameters
N = 300;
Ta = linspace(5,40,N);
Ts = linspace(20,42,N);
TcMax = 38;
TcMin = 36;
IbMax = 0.027 * sft + 0.004; %=veicsteinas : default = 0.112 = 4mm (2mm fat + 2mm skin);

%budd et al. : Journal of Applied Physiology Published 1 December 1991 Vol. 71 no. 6, 2387-2393 DOI: 
%within age = 26:52 => sft = sft(age=26) - 1/(3.5* ( age- 26) )
% if( handles.data.UserUseAgeTissueInsulation )
%     age_ibody = max(26, min( age, 52) ) - 26; %(min and max between 26 and 52 years), offset by 26.
%     sft_age_ibody = sft - 0.5* (1/3.5)*age_ibody;
%     IbMax = 0.027 * sft_age_ibody + 0.004;
% end

IbMin = 0.032;
if( handles.data.UserUseHeatProduction )
    M = [BMR-2, BMR+2];
else
    MET = (5/4)*BMR;
    M = [(activity*MET)-2, (activity*MET)+2];
end
static_data = TNZ_static_simple(Ta, Ts, v_air, rh/100, A, Icl, M, TcMax, TcMin, IbMax, IbMin, alpha, w );

pointsize = 4;

[isk,iai] = find(~isnan(static_data.Tsw));
plot(static_data.Ta(iai),static_data.Ts(isk),'o','Color',[1,0,0],'MarkerFaceColor',[1,0,0],'MarkerSize', pointsize);
hold on;
[isk,iai] = find(~isnan(static_data.Tcit));
plot(static_data.Ta(iai),static_data.Ts(isk),'o','Color',[0,0,1],'MarkerFaceColor',[0,0,1],'MarkerSize', pointsize);
[isk,iai] = find(~isnan(static_data.Tb));
plot(static_data.Ta(iai),static_data.Ts(isk),'o','Color',[0,1,0],'MarkerFaceColor',[0,1,0],'MarkerSize', pointsize);



xlabel('Operative temperature (^{\circ}C)')
ylabel('Mean skin temperature (^{\circ}C)')
axis([min(Ta) max(Ta) min(Ts) max(Ts)]);
%tnz temperature centroid
Top_centroid = round(10*mean(static_data.Ta(iai)))/10;
Top_min = round(10*min(static_data.Ta(iai)))/10;
Top_max = round(10*max(static_data.Ta(iai)))/10;

Tsk_centroid = round(10*mean(static_data.Ts(isk)))/10;
Tsk_min = round(10*min(static_data.Ts(isk)))/10;
Tsk_max = round(10*max(static_data.Ts(isk)))/10;



linewidth = 2;
if( ~isnan( Top_centroid)  )
    line( [Top_centroid, Top_centroid], [min(Ts) Tsk_centroid], 'LineWidth', linewidth, 'Color',[0,0,0]);
    line( [min(Ta) Top_centroid], [Tsk_centroid, Tsk_centroid],  'LineWidth', linewidth, 'Color',[0,0,0]);
    
    line( [Top_min, Top_min], [min(Ts) Tsk_min], 'LineWidth', linewidth, 'Color',[0.5,0.5,1]);
    line( [min(Ta) Top_min], [Tsk_min, Tsk_min],  'LineWidth', linewidth, 'Color',[0.5,0.5,1]);
    line( [Top_max, Top_max], [min(Ts) Tsk_max], 'LineWidth', linewidth, 'Color',[1,0.5,0.5]);
    line( [min(Ta) Top_max], [Tsk_max, Tsk_max],  'LineWidth', linewidth, 'Color',[1,0.5,0.5]);
    text( 6,  Tsk_max + 0.2, 'minimum tissue insulation','BackgroundColor',[1 1 1 ], 'FontSize', 12 );
    text( 6,  Tsk_min + 0.2, 'maximum tissue insulation','BackgroundColor',[1 1 1] , 'FontSize', 12 );
end
%plot(Top_centroid, Tsk_centroid,'s','Color',[0,0,0],'MarkerFaceColor',[1,1,1],'MarkerSize',7);

Tsk_user = handles.data.UserTemperatureMeanSkin;
Top_user = handles.data.UserTemperatureOperative;

plot(Top_user, Tsk_user,'o','Color',[0,0,0],'MarkerFaceColor',[1,1,1],'MarkerSize',7);

hold off;
set( handles.editAge,'String', age);
set( handles.editHeight,'String', height);
set( handles.editWeight,'String', weight);
set( handles.editSkinfolds,'String', sft);
set( handles.editBodyfat,'String', fat);

set( handles.editClothing,'String', clothing );
set( handles.editActivity,'String', activity);
set( handles.editAirvelocity,'String', v_air);
set( handles.editRelativeHumidity,'String', rh);
set( handles.editSkinWettedness,'String', round(100*w));
if( alpha > 0 )
    set( handles.editRespiratory,'String', round(100*alpha));
else
     %v_alpha =round( 100 * nanmean(nanmean( static_data.alphas(isk, iai) ) ) );
     set( handles.editRespiratory,'String', '-');
end    

set(handles.editToperative,'String', [ num2str(Top_centroid) ' [', num2str(Top_min),'-',num2str(Top_max), ']']);
set(handles.editTskin,'String', [ num2str(Tsk_centroid) ' [', num2str(Tsk_min),'-',num2str(Tsk_max), ']']);
set(handles.editMetabolic,'String',  [ num2str( round(10*mean(M/A))/10) ' [', num2str( round(10*min(M/A))/10),'-',num2str( round(10*max(M/A))/10), ']'] );
set(handles.editSurface,'String', round( 100*A)/100 );
set(handles.editInsulation,'String',  [ num2str( round(1000*mean([IbMin,IbMax]))/1000) ' [', num2str( round(1000 * IbMin )/1000),'-',num2str( round(1000 * IbMax )/1000), ']'] );
set(handles.textMetabolicRate,'String', metrateSource );

if (activity > 1 )
    set(handles.editComment,'String', 'Does the activity increase air velocity? e.g. walking?' );
    set(handles.editComment,'BackgroundColor', [0.9, 0.7, 0.5] );
elseif (w > 20 )
    set(handles.editComment,'String', 'Skin wettedness may be unrealistic. default = 6%' );
    set(handles.editComment,'BackgroundColor', [0.9, 0.5, 0.5] );
elseif (alpha > 15 )
    set(handles.editComment,'String', 'Respiratory heat loss may be unrealistic. default = 8%' );
    set(handles.editComment,'BackgroundColor', [0.9, 0.5, 0.5] );
else
    set(handles.editComment,'String', 'Status: ok' );
    set(handles.editComment,'BackgroundColor', [0.9, 0.9, 0.9] );
end
set(handles.editComment,'ForegroundColor', [0, 0, 0] );

% if( sex == 3)
%     set(handles.editComment,'String', 'Ye Pirate ye! Arrrrgh, where be me coffee!' );
%     set(handles.editComment,'ForegroundColor', [1, 1, 1] );
%     set(handles.editComment,'BackgroundColor', [0, 0, 0] );
% end



% --- Outputs from this function are returned to the command line.
function varargout = TNZ_CENTROID_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function sliderAge_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderAge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderHeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderWeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function sliderClothing_Callback(hObject, eventdata, handles)
% hObject    handle to sliderClothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(100*get(hObject,'Value'))/100;
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderClothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderClothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderActivity_Callback(hObject, eventdata, handles)
% hObject    handle to sliderActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(10*get(hObject,'Value'))/10;
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderActivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderAirvelocity_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAirvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(100*get(hObject,'Value'))/100;
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderAirvelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAirvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderRelativeHumidity_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRelativeHumidity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderRelativeHumidity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRelativeHumidity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editToperative_Callback(hObject, eventdata, handles)
% hObject    handle to editToperative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editToperative as text
%        str2double(get(hObject,'String')) returns contents of editToperative as a double


% --- Executes during object creation, after setting all properties.
function editToperative_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editToperative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTskin_Callback(hObject, eventdata, handles)
% hObject    handle to editTskin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTskin as text
%        str2double(get(hObject,'String')) returns contents of editTskin as a double


% --- Executes during object creation, after setting all properties.
function editTskin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTskin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAge_Callback(hObject, eventdata, handles)
% hObject    handle to editAge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAge as text
%        str2double(get(hObject,'String')) returns contents of editAge as a double


% --- Executes during object creation, after setting all properties.
function editAge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHeight_Callback(hObject, eventdata, handles)
% hObject    handle to editHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHeight as text
%        str2double(get(hObject,'String')) returns contents of editHeight as a double


% --- Executes during object creation, after setting all properties.
function editHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWeight_Callback(hObject, eventdata, handles)
% hObject    handle to editWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWeight as text
%        str2double(get(hObject,'String')) returns contents of editWeight as a double


% --- Executes during object creation, after setting all properties.
function editWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editClothing_Callback(hObject, eventdata, handles)
% hObject    handle to editClothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editClothing as text
%        str2double(get(hObject,'String')) returns contents of editClothing as a double


% --- Executes during object creation, after setting all properties.
function editClothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editClothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editActivity_Callback(hObject, eventdata, handles)
% hObject    handle to editActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editActivity as text
%        str2double(get(hObject,'String')) returns contents of editActivity as a double


% --- Executes during object creation, after setting all properties.
function editActivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editActivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAirvelocity_Callback(hObject, eventdata, handles)
% hObject    handle to editAirvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAirvelocity as text
%        str2double(get(hObject,'String')) returns contents of editAirvelocity as a double


% --- Executes during object creation, after setting all properties.
function editAirvelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAirvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRelativeHumidity_Callback(hObject, eventdata, handles)
% hObject    handle to editRelativeHumidity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRelativeHumidity as text
%        str2double(get(hObject,'String')) returns contents of editRelativeHumidity as a double


% --- Executes during object creation, after setting all properties.
function editRelativeHumidity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRelativeHumidity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuSex.
function popupmenuSex_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuSex contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuSex
strings = get(hObject,'String');
if( ~strcmp( strings( get(hObject,'Value') ), 'Male' ) )
    handles.data.UserUseBodyFatForSkinThickness = 0;
    set(handles.checkboxUseBodyFatForSkinShell, 'Value', 0 );
    set(handles.checkboxUseBodyFatForSkinShell, 'Enable', 'off' );
    set(handles.sliderSkinfolds, 'Enable', 'on' );
else
    set(handles.checkboxUseBodyFatForSkinShell, 'Enable', 'on' );
    if(  handles.data.UserUseBodyFatForSkinThickness )
        set(handles.sliderSkinfolds, 'Enable', 'off' );
    end
end
guidata(hObject, handles);

updateValues(handles);
% if( strcmp( strings( get(hObject,'Value') ), 'Pirate' ) )
%     set( handles.textAge,'String', 'Hangoverrrs' );
%     set( handles.textHeight,'String', 'Depth');
%     set( handles.textWeight,'String', 'Rumbottles');
%     set( handles.textSex,'String', 'Ya feels ya');
%     
%     set( handles.textClothing,'String', 'Wrappings' );
%     set( handles.textActivity,'String', 'Doings');
%     set( handles.textAirvelocity,'String', 'Windyness');
%     set( handles.textRelativeHumidity,'String', 'Foggyness');
%     set( handles.textSkinWettedness,'String', 'Me skin be like a frog');
%     set( handles.textRespiratory,'String', 'Me breath be like a dragon');
%     
%     set(handles.textToperative,'String', 'Outside' );
%     set(handles.textTskin,'String', 'Nearrby' );
%     set(handles.textMetabolic,'String', 'Fiestyness');
%     set(handles.textSurface,'String', 'Sails' ); 
% else
%     set( handles.textAge,'String', 'Age (yr)' );
%     set( handles.textHeight,'String', 'Height (cm)');
%     set( handles.textWeight,'String', 'Weight (kg)');
%     
%     set( handles.textSex,'String', 'Sex');
%     
%     set( handles.textClothing,'String', 'Clothing (clo)' );
%     set( handles.textActivity,'String', 'Activity (met)');
%     set( handles.textAirvelocity,'String', 'Air velocity (m/s)');
%     set( handles.textRelativeHumidity,'String', 'Relative humidity (%)');
%     set( handles.textSkinWettedness,'String', 'Skin wettedness (%)');
%     set( handles.textRespiratory,'String', 'Respiratory heat loss (%)');
%     
%     set(handles.textToperative,'String', 'TNZop (C)' );
%     set(handles.textTskin,'String', 'TNZsk (C)' );
%     set(handles.textMetabolic,'String', 'Metabolic rate (W/m2)');
%     set(handles.textSurface,'String', 'Surface area (m2)' );  
% end

% --- Executes during object creation, after setting all properties.
function popupmenuSex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuSex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSurface_Callback(hObject, eventdata, handles)
% hObject    handle to editSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSurface as text
%        str2double(get(hObject,'String')) returns contents of editSurface as a double


% --- Executes during object creation, after setting all properties.
function editSurface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMetabolic_Callback(hObject, eventdata, handles)
% hObject    handle to editMetabolic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMetabolic as text
%        str2double(get(hObject,'String')) returns contents of editMetabolic as a double


% --- Executes during object creation, after setting all properties.
function editMetabolic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMetabolic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderSkinWettedness_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSkinWettedness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
guidata(hObject, handles);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderSkinWettedness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSkinWettedness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editSkinWettedness_Callback(hObject, eventdata, handles)
% hObject    handle to editSkinWettedness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSkinWettedness as text
%        str2double(get(hObject,'String')) returns contents of editSkinWettedness as a double


% --- Executes during object creation, after setting all properties.
function editSkinWettedness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSkinWettedness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderRespiratory_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRespiratory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
guidata(hObject, handles);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderRespiratory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRespiratory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editRespiratory_Callback(hObject, eventdata, handles)
% hObject    handle to editRespiratory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRespiratory as text
%        str2double(get(hObject,'String')) returns contents of editRespiratory as a double


% --- Executes during object creation, after setting all properties.
function editRespiratory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRespiratory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editComment_Callback(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComment as text
%        str2double(get(hObject,'String')) returns contents of editComment as a double


% --- Executes during object creation, after setting all properties.
function editComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxUseMeasured.
function checkboxUseMeasured_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUseMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxUseMeasured
handles.data.UserUseHeatProduction = get(hObject,'Value');
guidata(hObject, handles);
updateValues(handles);

function editHeatProduction_Callback(hObject, eventdata, handles)
% hObject    handle to editHeatProduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHeatProduction as text
%        str2double(get(hObject,'String')) returns contents of editHeatProduction as a double
handles.data.UserHeatProduction = getValueFromEditText( get(hObject,'String') );
guidata(hObject, handles);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function editHeatProduction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHeatProduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMeanSkin_Callback(hObject, eventdata, handles)
% hObject    handle to editMeanSkin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMeanSkin as text
%        str2double(get(hObject,'String')) returns contents of editMeanSkin as a double
handles.data.UserTemperatureMeanSkin = getValueFromEditText( get(hObject,'String') );
guidata(hObject, handles);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function editMeanSkin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMeanSkin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editOperative_Callback(hObject, eventdata, handles)
% hObject    handle to editOperative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editOperative as text
%        str2double(get(hObject,'String')) returns contents of editOperative as a double


handles.data.UserTemperatureOperative = getValueFromEditText( get(hObject,'String') );
guidata(hObject, handles);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function editOperative_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOperative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [value] = getValueFromEditText(str)
value = NaN;
try
    value = str2double(str);
catch
end



function editInsulation_Callback(hObject, eventdata, handles)
% hObject    handle to editInsulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editInsulation as text
%        str2double(get(hObject,'String')) returns contents of editInsulation as a double


% --- Executes during object creation, after setting all properties.
function editInsulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInsulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderSkinfolds_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSkinfolds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(10*get(hObject,'Value'))/10;
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderSkinfolds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSkinfolds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editSkinfolds_Callback(hObject, eventdata, handles)
% hObject    handle to editSkinfolds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSkinfolds as text
%        str2double(get(hObject,'String')) returns contents of editSkinfolds as a double


% --- Executes during object creation, after setting all properties.
function editSkinfolds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSkinfolds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkboxUseBodyFatForSkinShell.
function checkboxUseBodyFatForSkinShell_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUseBodyFatForSkinShell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxUseBodyFatForSkinShell
handles.data.UserUseBodyFatForSkinThickness = get(hObject,'Value');
if( ~get(hObject,'Value') )
    set(handles.sliderSkinfolds,'Enable','on');
else
    set(handles.sliderSkinfolds,'Enable','off');
end
guidata(hObject, handles);
updateValues(handles);


% --- Executes on slider movement.
function sliderBodyfat_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBodyfat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val=round(get(hObject,'Value'));
set( hObject, 'Value', val);
updateValues(handles);

% --- Executes during object creation, after setting all properties.
function sliderBodyfat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBodyfat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editBodyfat_Callback(hObject, eventdata, ~)
% hObject    handle to editBodyfat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBodyfat as text
%        str2double(get(hObject,'String')) returns contents of editBodyfat as a double


% --- Executes during object creation, after setting all properties.
function editBodyfat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBodyfat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxUseCalculatedAlpha.
function checkboxUseCalculatedAlpha_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUseCalculatedAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxUseCalculatedAlpha
handles.data.UserUseCalculatedAlpha = get(hObject,'Value');
if( ~get(hObject,'Value') )
    set(handles.sliderRespiratory,'Enable','on');
else
    set(handles.sliderRespiratory,'Enable','off');
end
guidata(hObject, handles);
updateValues(handles);
