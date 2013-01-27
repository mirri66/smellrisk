% findTrigs - finds breath triggers in physio data
% ---------
% variables:
% - subjName: array of subject folder
% - runTRs: number of TRs in the run you are processing, excluding the lead in
% - runName: name of run. For smellrisk, SKEW_1, SKEW_2, or VARIANCE
% run respparser first, to get raw timeseries files! Respparser makes physio data aligned to end of scan data, as
% recommended by Gary Glover
function findTrigs(subjName, runTRs, runName)

samplingRate = 25; % how many timepoints per sec is resp collected?
TR=2;

% start
path.scripts = pwd;
cd ..
path.main = pwd;
cd(path.scripts);

[pathstr,curr_dir,ext,versn] = fileparts(pwd);
if ~strcmp(curr_dir,'scripts')
    error('You must start the experiment from the scripts directory. Go there and try again.\n');
end

cd(path.main)


    % find folder for the run you are currently processing
    physioFolder = [subjName '/physio'];
    cd(physioFolder);
  %  physRunFolder = dir(['00*' runName]);
    
    %%%% get physio data
   % cd(physioFolder)
    % runphysname = ['subj' num2str(subjNo) 'run' num2str(runNo) '_phys.1D'];
    runrawname = [subjName '_' runName '_physraw.1D'];
    runsdata=dlmread(runrawname);
    
   % plot(runsdata)
    plot(runsdata(1:1000))
    
    %%%% lowpass filter to remove heartbeat
    
    %n = 100;
    n=500;
    
    t_max = size(runsdata)/samplingRate; % number of seconds and frequency
    t = [0:.04:t_max];
    
    fd = fft(runsdata);
    
    fd2 = fd;
    fd2(n+1:numel(fd2)-n) = 0;
    
    denoised = ifft(fd2);
    denoised = abs(denoised);
    
    hold on;
    plot(denoised(1:1000), 'r');
    %plot(denoised, 'r');
    
    % find extrema
    
    % d = diff(tmp);
    % plot((d*20+2400),'g')
    %
    % x=fzero(d,1)
    
    [zmax,imax,zmin,imin]= extrema(denoised); % zmax = amplitude, imax= position in time
    
            % plot maxima
     [zmaxplot,imaxplot,zminplot,iminplot]= extrema(denoised(1:1000));
            x=imaxplot;
            ylim=get(gca,'ylim');
            line([x,x],ylim.',...
                'linewidth',1, 'color', 'r');
    
    sigMean = mean(denoised); % to use this method, might wanna check if there are linear trends in data, and remove those.
    
    idxmax = find(zmax>0.67*sigMean); % get rid of local extrema that are probably within breath variations
    idxmin = find(zmin<1.67*sigMean);  %% IMPT: for subj 56, used 0.67/1.67 cut off to account for wide swings in chest vol due to inhale / exhale depth
    zmax2=zmax(idxmax);
    zmin2=zmin(idxmin);
    imax2=imax(idxmax);
    imin2=imin(idxmin);
    
    
    % for plottinh
    
    idxmaxplot = find(zmaxplot>0.67*sigMean); % get rid of local extrema that are probably within breath variations
    idxminplot = find(zminplot<1.67*sigMean);  %% IMPT: for subj 56, used 0.67/1.67 cut off to account for wide swings in chest vol due to inhale / exhale depth
    zmax2plot=zmaxplot(idxmaxplot);
    zmin2plot=zminplot(idxminplot);
    imax2plot=imaxplot(idxmaxplot);
    imin2plot=iminplot(idxminplot);
    
    %%%% find trigs
    trig=[];
    
    for i = 1:length(imin2)
        idx=max(imax2(imax2<imin2(i))); % this is the exhale peak just before the inhale, i.e. when the exhale is starting to become an inhale
        trig=[trig;idx];
        
    end
    
            % plot triggers
            
              trigplot=[];
    
    for i = 1:length(imin2plot)
        idx=max(imax2plot(imax2plot<imin2plot(i))); % this is the exhale peak just before the inhale, i.e. when the exhale is starting to become an inhale
        trigplot=[trigplot;idx];
        
    end
            x1=trigplot;
            ylim=get(gca,'ylim');
            line([x1,x1],ylim.',...
                'linewidth',1,...
                'color','k');
    
    
    %save trigs
    filename=[subjName '_' runName '_inhaleTrig.1D'];
    dlmwrite(filename, trig);
    
    
    %%%%%%% btwn inflections %%%%%%%
    % Sam suggests finding point between inflections, peak exhale to
    % peak inhale
    
    %%%% for each trig, find the peak inhale right after
    trig2= []; % the inhale minima after the exhale maxima (trig)
    for i = 1:length(trig)
        idx = min(imin2(imin2>trig(i)));
        trig2=[trig2;idx];
        
    end
    
    % for plotting
        trig2plot= []; % the inhale minima after the exhale maxima (trig)
    for i = 1:length(trigplot)
        idx = min(imin2plot(imin2plot>trigplot(i)));
        trig2plot=[trig2plot;idx];
        
    end
    
    
    % plot inhales
    x2=trig2plot;
    ylim=get(gca,'ylim');
    line([x2,x2],ylim.',...
        'linewidth',1,...
        'color','g');
    
    %%%% find half inflection
    tmp = [trig, trig2];
    trig3 = [];
    for i = 1:length(tmp)
        halfinfl=trig(i)+0.5*(trig2(i)-trig(i));
        trig3 = [trig3; halfinfl];
        
    end
    
    %plot half inflection trigs
        tmp = [trigplot, trig2plot];
    trig3plot = [];
    for i = 1:length(tmp)
        halfinflplot=trigplot(i)+0.5*(trig2plot(i)-trigplot(i));
        trig3plot = [trig3plot; halfinflplot];
        
    end
    x3=trig3plot;
    ylim=get(gca,'ylim');
    line([x3,x3],ylim.',...
        'linewidth',1,...
        'color','c');
    
    
    %save trigs
    filename2=[subjName '_' runName '_halfInflxTrig.1D'];
    dlmwrite(filename2, trig3);
    
    
    

end
