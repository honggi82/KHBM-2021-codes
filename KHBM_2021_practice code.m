clear all; close all; clc;
addpath(genpath('E:\조선대\발표자료\Summer_School\2021\Summer_School_Codes')) % set path

%====================== 1. Parameter setting ======================
sf = 250; % sampling frequency
ch_n = 22; % number of channels
wnd_size=[-1 2]; % window size
baseline=[-1 0]; % baseline
f_scale=1; % frequency interval of time-frequency analysis
freq_band=[0.1 100]; % frequency interval of time-frequency analysis
normal=1; % normalization by baseline
fullscreen=get(0,'ScreenSize'); % size of monitor screen
[position]=EEG_22ch_layout; % EEG channel position

%====================== 2. Data load ======================
[data, h] = sload(['A01T.gdf']); % loading training data
EEG = data(:,1:ch_n)';
EOG = data(:,ch_n+1:end)';
clear data

figure;
for ch=1:ch_n
	plot(EEG(ch, :)-ch*100); hold on;
end

%====================== 3. Rereferencing (CAR)======================
EEG = EEG-repmat(mean(EEG,1), ch_n,1);

%====================== 4. Extract events ======================
events{1} = h.EVENT.POS(find(h.EVENT.TYP==769)); % left hand
events{2} = h.EVENT.POS(find(h.EVENT.TYP==770)); % right hand
events{3} = h.EVENT.POS(find(h.EVENT.TYP==771)); % foot
events{4} = h.EVENT.POS(find(h.EVENT.TYP==772)); % tongue
n_task = length(events); % number of event types

% =================== 5. epoching data =================== 
for i = 1 : n_task
    for j = 1 : length(events{i})
        e_EEG{i}(:,:,j) = EEG(:,round(events{i}(j)+(wnd_size(1)*sf)):round(events{i}(j)+(wnd_size(2)*sf)));
        e_EOG{i}(:,:,j) = EOG(:,round(events{i}(j)+(wnd_size(1)*sf)):round(events{i}(j)+(wnd_size(2)*sf)));
    end
end

% =================== 6. plotting EOG =================== 
for i = 1 : n_task
    figure('Position',[0 0 fullscreen(3) fullscreen(4)]); % new window
    for j = 1 : length(events{i})
        subplot(8,10,j); % plotting the figure at j-th on 8*10 matrix 
        plot(e_EOG{i}(:,:,j)'); % plotting EOG of j-th trial and j-th task
        ylim([-100 100]); % limitation of y-axis
        title(['Trial: ', num2str(j)]); % title of the figure
    end
end

% =================== 7. Artifact removal =================== 
rem{1}=[3,24,25,40,47,52,55,60,68,72]; % artifact trials of task 1
rem{2}=[11,12,14,31,34,47,51,52,57,70]; % artifact trials of task 2
rem{3}=[5,9,18,21,27,29,31,46,47,52,54,55,56,57,60,66,68]; % artifact trials of task 3
rem{4}=[5,9,10,11,19,23,24,34,36,39,44,48,49,50,55,56,58,70]; % artifact trials of task 4

for i = 1 : n_task
    e_EEG{i}(:,:,rem{i})=[]; % removal of artifact trials
    e_EOG{i}(:,:,rem{i})=[];
end

% =================== 8. ERP =================== 
ch=10; % channel selection
for i = 1 : n_task
    m_EEG(:,:,i)=squeeze(mean(e_EEG{i},3)); % averaging by trials
end
t=wnd_size(1):1/sf:wnd_size(2); % time points generation
figure; plot(t,squeeze(m_EEG(ch,:,:))); hold on; % plotting ERP
x=[0 0]; y=[-5 5]; line(x,y,'Color','red', 'LineWidth', 1); % line for Onset time
legend('Left hand', 'Right hand', 'Both feet', 'Tongue'); 

% =================== 9. Powerspectrm =================== 
ch=10; % channel selection
for i = 1 : n_task
    for tr=1:size(e_EEG{i},3)
        PS{i}(:,tr)=abs(fft(e_EEG{i}(ch, :, tr))); % Fast Fourier Transform
    end
    m_PS(i,:)=mean(PS{i},2); % averaging by trials
end

L=size(m_PS,2);
f=sf*(0:L/2)/L;
figure; 
plot(f,log(m_PS(:,1:ceil(L/2)))); % plotting power spectrum on a log scale
legend('Left hand', 'Right hand', 'Both feet', 'Tongue'); 

% =================== 10. time-frequency =================== 
for i = 1 : n_task
    for ch=1:size(e_EEG{i},1)
        for tr=1:size(e_EEG{i},3)
            TF{i}(ch,:,:,tr) = timefreq_anal(e_EEG{i}(ch,:,tr), sf, wnd_size, baseline,f_scale,freq_band, normal);
        end
    end
    fprintf(['Calculation of TF of task ', num2str(i), ' is finished\n']);
end

for i = 1 : n_task
    m_TF(:,:,:,i)=squeeze(mean(TF{i},4));
end

ch=11; % channel
i=1; % task
t=linspace(wnd_size(1),wnd_size(2),size(m_TF,3)); % time
fr=linspace(freq_band(1), freq_band(2),size(m_TF,2)); % frequency
figure; pcolor(t,fr,squeeze(m_TF(ch,:,:,i))); %  plotting Time-Frequency Analysis on channel ‘ch’
shading 'interp'; caxis([-0.5 0.5]);
x=[0 0]; y=[0 100]; line(x,y,'Color','red', 'LineWidth', 1); % line for Onset time

% =================== 11. whole channel time-frequency =================== 
figure('Position',[0 0 fullscreen(3) fullscreen(4)]);
for ch=1:size(e_EEG{i},1)
    subplot('Position', position(ch,:));
    pcolor(t,fr,squeeze(m_TF(ch,:,:,i))); 
    shading 'interp'; caxis([-0.5 0.5]); 
    x1=[0 0]; y1=freq_band; line(x1,y1,'Color','red', 'LineWidth', 1); % line for Onset time
end

% =================== 12. topography=================== 
band=[22 33]; % 22~33Hz
time=([0 2]-wnd_size(1))*sf;
for i = 1 : n_task
    TP(:,i)=mean(mean(m_TF(:,band(1):band(2),time(1):time(2),i),3),2);
end

figure;
for i = 1 : n_task
    subplot(1,4,i);topoplot(TP(:,i), 'Standard-10-20-Cap22.locs','style','map', 'maplimits', [-0.3 0.3], 'whitebk','on', 'plotrad',0.548, 'headrad',0.5, 'shading','interp');
end
