function varargout=diva_targets(option,varargin)
% diva_targets
% internal function: manages target info/files
% 
% to fully define a target:                 target = diva_targets('format', target)
%   where target is a structure with some of the following fields:
%           name            : target name
%           length          : total duration (in ms)
%           interpolation   : interpolation type 'linear' or 'none'
%           sampling        : temporal sampling type 'sparse' (one target per control-point) or 'fixed rate' (one target per time-point)
%       for each <var> = F0|F1|F2|F3|pressure|voicing|PA_pharyngeal|PA_uvular|PA_velar|PA_palatal|PA_alveolardental|PA_labial|ART_Jaw|ART_Lip_opening|Art_Lip_protrusion|ART_Soft_palate|ART_Larynx_height|ART_Tongue_#|ART_Tension|ART_Pressure|ART_Voicing (see diva_vocaltract for complete list of <var> parameters) 
%           <var>_control             : list of control-points or time-points (in ms)
%           <var>_min                 : minimum value of target <var> parameter
%           <var>_max                 : maximum value of target <var> parameter
%       for each <segment> = gestures | phonemes | syllables | words
%           <segment>_duration        : list of target segment durations 
%                                        for <segment> = gestures, durations are specified in ms units (note: if unspecified gestures_length = diff(union([<var>_control]))) 
%                                        for <segment> = phonemes, durations are specified in number of control points 
%                                        for <segment> = syllables, durations are specified in number of phonemes
%                                        for <segment> = words, durations are specified in number of syllables 
%           <segment>_name            : list of target segment names
%           <segment>_durationfixed   : list of 1/0 values indicating whether the duration of this segment is fixed irrespective of production speed 
%
% to edit an existing target:               target = diva_targets('edit', target, field1, value1, ..., fieldn, valuen)
%
% to read production data from target:      [production, time] = diva_targets('timeseries', target, 'header')
%   where production is a structure with fields:
%           Aud_min         : [Ntime, Nparamsaud] matrix of auditory target minimum values
%           Aud_max         : [Ntime, Nparamsaud] matrix of auditory target maximum values
%           Som_min         : [Ntime, Nparamssom] matrix of somatosensory target minimum values
%           Som_max         : [Ntime, Nparamssom] matrix of somatosensory target maximum values
%           Art             : [Ntime, Nparamsart] matrix of motor production values         
%           time            : [Ntime, 1] vector of timepoints (in ms)
%
% to create a new empty target:             target = diva_targets('new','txt')
%
% to create a new empty production:         production = diva_targets('new','mat')
%
% to create a new random target:            target = diva_targets('random','txt')
%
% to create a new random production:        target = diva_targets('random','mat')
%
% to load existing target:                  target = diva_targets('load','txt',targetname)
%
% to load existing production:              target = diva_targets('load','mat',targetname)
%
% to save new target:                       diva_targets('save',fileformat,targetname,target [,overwrite])
%
% to delete a target:                       diva_targets('delete',targetname) 
%
% to list current targets:                  targetnames = diva_targets('list')
%
% to combine two targets:                   target = diva_targets('combine', target1, target2, duration_transition, duration2 [, production1, production2])
%
% to temporally resample a target:          target = diva_targets('resampletime', target, time1, time2)
%

global DIVA_x;
if ~isfield(DIVA_x,'model'), DIVA_x.model='diva'; end

switch(lower(option))
    case 'list' % target files in diva_targets folder
        filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'.csv']);
        [production_ids,production_labels]=diva_targets_readcsvfile(filename);
        varargout{1}=production_labels;
        varargout{2}=production_ids;
    case 'delete'
        filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'.csv']);
        [production_ids,production_labels]=diva_targets_readcsvfile(filename);
        production=varargin{1};
        idx=strmatch(production,production_labels,'exact');
        if ~isempty(idx),
            idx=idx(1);
            if isnan(production_ids(idx)), 
                filename_mat1=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_targets'],production_labels{idx});
                filename_mat2=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_targets'],['bak_',production_labels{idx}]);
                if ~isdir(fileparts(filename_mat1)), [nill,nill]=mkdir(fileparts(filename_mat1)); end
            else 
                filename_mat1=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_',num2str(production_ids(idx),'%06d')]);
                filename_mat2=fullfile(fileparts(which(DIVA_x.model)),['bak_',DIVA_x.model,'_',num2str(production_ids(idx),'%06d')]);
            end
            production_ids=production_ids([1:idx-1,idx+1:numel(production_ids)]);
            production_labels=production_labels([1:idx-1,idx+1:numel(production_labels)]);
            diva_targets_writecsvfile(filename,production_ids,production_labels);
            if isunix
                [nill,ok]=system(['mv ',filename_mat1,'.mat ',filename_mat2,'.mat']); if nill,disp(ok); end
                [nill,ok]=system(['mv ',filename_mat1,'.txt ',filename_mat2,'.txt']); if nill,disp(ok); end
                fprintf('Target %s deleted (backup stored as %s)\n',filename_mat1,filename_mat2);

            else
                [nill,ok]=system(['move ',filename_mat1,'.mat ',filename_mat2,'.mat']); if nill,disp(ok); end
                [nill,ok]=system(['move ',filename_mat1,'.txt ',filename_mat2,'.txt']); if nill,disp(ok); end
                fprintf('Target %s deleted (backup stored as %s)\n',filename_mat1,filename_mat2);
            end
        else
            disp(['warning: no match for production ',production,' in ',filename]);
        end
    case 'new'
        filetype=varargin{1};
        switch(lower(filetype))
            case 'txt'
                varargout{1}=diva_targets_initstruct;
            case 'mat'
                production_info=diva_targets_initstruct;
                varargout{1}=diva_targets('timeseries',production_info,'header');
        end
    case 'random'
        filetype=varargin{1};
        switch(lower(filetype))
            case 'txt'
                varargout{1}=diva_targets_initstruct(3);
            case 'mat'
                production_info=diva_targets_initstruct(3);
                varargout{1}=diva_targets('timeseries',production_info,'header');
        end
    case 'format'
        production_info=diva_targets_format(varargin{:});
        varargout{1}=production_info;
    case 'edit',
        production_info=varargin{1};
        for nfield=2:2:numel(varargin)-1
            if ~isfield(production_info,varargin{nfield}), fprintf('warning: field %s does not exist. Disregarding\n',varargin{nfield});
            else 
                if isequal(varargin{nfield},'gestures_duration') % note: change *_control values from gestures_duration
                    oldx0=[];
                    newx0=[0 cumsum(varargin{nfield+1})];
                    params=diva_vocaltract;
                    for n0=1:numel(params.Output), for n1=1:numel(params.Output(n0).Plots_dim), if numel(params.Output(n0).Plots_dim{n1})==1&&isfield(production_info, [params.Output(n0).Plots_label{n1},'_control']),
                                x0=production_info.([params.Output(n0).Plots_label{n1},'_control']);
                                oldx0=union(oldx0,x0);
                    end; end; end
                    assert(numel(oldx0)==numel(newx0),'incorrect size of field ''gestures_duration''');
                    for n0=1:numel(params.Output), for n1=1:numel(params.Output(n0).Plots_dim), if numel(params.Output(n0).Plots_dim{n1})==1&&isfield(production_info, [params.Output(n0).Plots_label{n1},'_control']),
                                x0=production_info.([params.Output(n0).Plots_label{n1},'_control']);
                                [nill,idx]=ismember(x0,oldx0);
                                production_info.([params.Output(n0).Plots_label{n1},'_control'])=newx0(idx);
                    end; end; end
                    production_info.length=newx0(end);
                end
                production_info.(varargin{nfield})=varargin{nfield+1}; 
            end
        end
        production_info=diva_targets_format(production_info);
        varargout{1}=production_info;
    case 'resampletime',
        production_info=diva_targets_resampletime(varargin{:});
        varargout{1}=production_info;
    case 'load'
        filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'.csv']);
        [production_ids,production_labels]=diva_targets_readcsvfile(filename);
        filetype=varargin{1};
        production=varargin{2};
        idx=strmatch(production,production_labels,'exact');
        if ~isempty(idx)
            if numel(idx)>1, disp(['warning: multiple entries matching ',production,' in ',filename]); idx=idx(1); end
            if isnan(production_ids(idx)),
                filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_targets'],production_labels{idx});
                if ~isdir(fileparts(filename)), [nill,nill]=mkdir(fileparts(filename)); end
           else
                filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_',num2str(production_ids(idx),'%06d')]);
            end
            switch(lower(filetype))
                case 'txt'
                    filename=[filename,'.txt'];
                    if ~isempty(dir(filename))
                        varargout{1}=diva_targets_txt2struct(filename);
                    else
                        varargout{1}=[];
                    end
                case 'mat'
                    filename=[filename,'.mat'];
                    if ~isempty(dir(filename))
                        load(filename,'timeseries');
                        varargout{1}=timeseries;
                    else
                        production_info=diva_targets_txt2struct(filename);
                        timeseries=diva_targets('timeseries',production_info,'header');
                        varargout{1}=timeseries;
                    end
            end
        else
            disp(['warning: no entry matching ',production,' in ',filename]); 
            varargout{1}=[];
        end
    case 'reset'
        production_info=varargin{1};
        varargout={diva_targets('timeseries',production_info,'header')};
    case 'save'
        filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'.csv']);
        [production_ids,production_labels]=diva_targets_readcsvfile(filename);
        filetype=varargin{1};
        production=varargin{2};
        production_info=varargin{3};
        if nargin<5, overwrite=-1; else overwrite=varargin{4}; end
        idx=strmatch(production,production_labels,'exact');
        if numel(idx)>1, disp(['warning: multiple entries matching ',production,' in ',filename]); idx=idx(1); end
        if isempty(idx)
            %if isempty(production_ids), production_ids=1; else production_ids(end+1)=max(production_ids)+1; end
            if isempty(production_ids), production_ids=nan; else production_ids(end+1)=nan; end % note: default new targets in diva_targets
            production_labels(end+1)={production};
            diva_targets_writecsvfile(filename,production_ids,production_labels);
            idx=numel(production_ids);
        end
        if isnan(production_ids(idx)),
            filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_targets'],production_labels{idx});
            if ~isdir(fileparts(filename)), [nill,nill]=mkdir(fileparts(filename)); end
        else
            filename=fullfile(fileparts(which(DIVA_x.model)),[DIVA_x.model,'_',num2str(production_ids(idx),'%06d')]);
        end
        
        switch(lower(filetype))
            case 'txt'
                production_info.name=production;
                filename=[filename,'.txt'];
                diva_targets_struct2txt(production_info,filename);
            case 'matoverwrite'
                filename=[filename,'.mat'];
                timeseries=production_info;
                save(filename,'timeseries');
            case 'mat'
                production_info.name=production;
                filename=[filename,'.mat'];
                timeseries=diva_targets('timeseries',production_info,'header');
                if ~isempty(dir(filename)) && overwrite~=1
                    old=load(filename,'-mat');
                    if ~overwrite
                        if size(old.timeseries.Art,1)==size(timeseries.Art,1), 
                            timeseries.Art=old.timeseries.Art;
                        else
                            disp('warning: incorrect length of learned Feedforward timeseries. overwriting');
                        end
                    elseif size(old.timeseries.Art,1)==size(timeseries.Art,1), 
                        ok=questdlg('Overwrite existing Articulatory sequence?','','Yes', 'No', 'No');
                        if strcmp(ok,'No')
                            timeseries.Art=old.timeseries.Art;
                        end
                    end
                end
                save(filename,'timeseries');
            case 'art'
                filename=[filename, '.mat'];
                if ~isempty(dir(filename))
                    load(filename,'timeseries');
                    try, timeseries.Art=production_info(1:numel(timeseries.time),:);
                    catch
                        timeseries=diva_targets('timeseries',varargin{4},'header');
                        timeseries.Art=production_info(1:numel(timeseries.time),:);
                    end
                    save(filename,'timeseries');
                elseif numel(varargin)>=4
                    timeseries=diva_targets('timeseries',varargin{4},'header');
                    timeseries.Art=production_info(1:numel(timeseries.time),:);
                    save(filename,'timeseries');
                else
                    disp(['warning: file ',filename,' not found']);
                end
        end
    case 'timeseries'
        production_info=varargin{1};
        if nargin<3, doheader=0; else doheader=strcmpi(varargin{2},'header'); end
        params=diva_vocaltract;
        [Aud_min,Aud_max,Som_min,Som_max,Time]=diva_targets_timeseriesconvert(production_info,params.Output(1:2));
        %[Aud_min,Aud_max,Time]=diva_targets_timeseriesconvert(production_info,params.Output(1));
        %[Som_min,Som_max,Time]=diva_targets_timeseriesconvert(production_info,params.Output(2));
        Art=repmat(mean(params.Input.Default,2)',[size(Aud_min,1),1]);
        N_samplesperheader=0;
        if doheader&&N_samplesperheader>0
            k0=1-(1-linspace(0,1,N_samplesperheader)').^2;
            Aud_min=cat(1,k0*Aud_min(1,:)+(1-k0)*params.Output(1).Default(:,1)', Aud_min, flipud(k0)*Aud_min(end,:)+(1-flipud(k0))*params.Output(1).Default(:,1)');
            Aud_max=cat(1,k0*Aud_max(1,:)+(1-k0)*params.Output(1).Default(:,2)', Aud_max, flipud(k0)*Aud_max(end,:)+(1-flipud(k0))*params.Output(1).Default(:,2)');
            Som_min=cat(1,k0*Som_min(1,:)+(1-k0)*params.Output(2).Default(:,1)', Som_min, flipud(k0)*Som_min(end,:)+(1-flipud(k0))*params.Output(2).Default(:,1)');
            Som_max=cat(1,k0*Som_max(1,:)+(1-k0)*params.Output(2).Default(:,2)', Som_max, flipud(k0)*Som_max(end,:)+(1-flipud(k0))*params.Output(2).Default(:,2)');
            Art=cat(1,Art(1+zeros(N_samplesperheader,1),:),Art,Art(end+zeros(N_samplesperheader,1),:));
            dt=min(diff(Time));
            Time=cat(1,dt*(0:N_samplesperheader-1)',dt*N_samplesperheader+Time,dt*N_samplesperheader+Time(end)+dt*(1:N_samplesperheader)');
        end
        varargout{1}=struct('Aud_min',Aud_min,'Aud_max',Aud_max,'Som_min',Som_min,'Som_max',Som_max,'Art',Art,'time',Time);
        varargout{2}=Time;
    case 'combine' % target = diva_targets('combine', target1, target2, duration_transition, duration2 [, production1, production2, segmentID])
        production_info1=varargin{1};
        production_info2=varargin{2};
        if numel(varargin)<3, duration_transition=40; else duration_transition=varargin{3}; end
        if numel(varargin)<4, duration2=[]; else duration2=varargin{4}; end
        if numel(varargin)<5, timeseries1=[]; else timeseries1=varargin{5}; end
        if numel(varargin)<6, timeseries2=[]; else timeseries2=varargin{6}; end
        if numel(varargin)<7, segmentID='gestures'; else segmentID=varargin{7}; end
        %production_info <- production_info1 & production_info2;
        production_info.name='';
        if ~isempty(duration2), production_info2.length=duration2; end
        production_info.length=production_info1.length+duration_transition+production_info2.length;
        production_info.wrapper=0;
        production_info.interpolation='linear';
        if ~isequal(production_info1.interpolation,'linear'), fprintf('warning: interpolation methods changed from %s to linear\n',production_info1.interpolation); end
        if ~isequal(production_info2.interpolation,'linear'), fprintf('warning: interpolation methods changed from %s to linear\n',production_info2.interpolation); end
        if ~isfield(production_info1,'sampling'), production_info1.sampling='sparse'; end
        if ~isfield(production_info2,'sampling'), production_info2.sampling='sparse'; end
        %if ~isfield(production_info1,'segment_lengths'), production_info1.segment_lengths=production_info1.length; end
        %if ~isfield(production_info2,'segment_lengths'), production_info2.segment_lengths=production_info2.length; end
        %if ~isfield(production_info1,'segment_names'), production_info1.segment_names=arrayfun(@(n)sprintf('segment #%d',n),1:numel(production_info1.segment_lengths),'uni',0); end
        %if ~isfield(production_info2,'segment_names'), production_info2.segment_names=arrayfun(@(n)sprintf('segment #%d',n),1:numel(production_info2.segment_lengths),'uni',0); end
        if ~isequal(production_info1.sampling,production_info2.sampling), fprintf('warning: sampling methods changed to ''sparse''\n'); production_info.sampling='sparse'; 
        else production_info.sampling=production_info1.sampling;
        end
        params=diva_vocaltract;
        for n0=1:numel(params.Output),
            for n1=1:numel(params.Output(n0).Plots_dim)
                if numel(params.Output(n0).Plots_dim{n1})==1
                    idx=params.Output(n0).Plots_dim{n1};
                    x0=production_info1.([params.Output(n0).Plots_label{n1},'_control']);
                    x1=production_info1.([params.Output(n0).Plots_label{n1},'_min']);
                    x2=production_info1.([params.Output(n0).Plots_label{n1},'_max']);
                    if ~any(x0<=0), x0=[0 x0]; x1=[x1(1) x1]; x2=[x2(1) x2]; end
                    if ~any(x0>=production_info1.length), x0=[x0 production_info1.length]; x1=[x1 x1(end)]; x2=[x2 x2(end)]; end
                    if any(x0>production_info1.length), x1=x1(x0<=production_info1.length); x2=x2(x0<=production_info1.length); x0=x0(x0<=production_info1.length); end
                    %if isequal(x1,'X'), x1=params.Output(n0).DefaultSound(idx,1); end
                    %if isequal(x2,'X'), x2=params.Output(n0).DefaultSound(idx,2); end
                    if any(isnan(x1)), x1(isnan(x1))=params.Output(n0).DefaultSound(idx,1); end
                    if any(isnan(x2)), x2(isnan(x2))=params.Output(n0).DefaultSound(idx,2); end
                    y0=production_info2.([params.Output(n0).Plots_label{n1},'_control']);
                    y1=production_info2.([params.Output(n0).Plots_label{n1},'_min']);
                    y2=production_info2.([params.Output(n0).Plots_label{n1},'_max']);
                    if ~any(y0<=0), y0=[0 y0]; y1=[y1(1) y1]; y2=[y2(1) y2]; end
                    if ~any(y0>=production_info2.length), y0=[y0 production_info2.length]; y1=[y1 y1(end)]; y2=[y2 y2(end)]; end
                    if any(y0>production_info2.length), y1=y1(y0<=production_info2.length); y2=y2(y0<=production_info2.length); y0=y0(y0<=production_info2.length); end
                    %if isequal(y1,'X'), y1=params.Output(n0).DefaultSound(idx,1); end
                    %if isequal(y2,'X'), y2=params.Output(n0).DefaultSound(idx,2); end
                    if any(isnan(y1)), y1(isnan(y1))=params.Output(n0).DefaultSound(idx,1); end
                    if any(isnan(y2)), y2(isnan(y2))=params.Output(n0).DefaultSound(idx,2); end
                    if numel(x0)==1&&numel(y0)==1&&x1==y1&&x2==y2,
                    else
                        if numel(x0)==1, x0=[0 production_info1.length]; x1=[x1 x1]; x2=[x2 x2]; end
                        if numel(y0)==1, y0=[0 production_info2.length]; y1=[y1 y1]; y2=[y2 y2]; end
                        x0=[x0 production_info1.length+duration_transition+y0];
                        x1=[x1 y1];
                        x2=[x2 y2];
                    end
                    production_info.([params.Output(n0).Plots_label{n1},'_control'])=x0;
                    production_info.([params.Output(n0).Plots_label{n1},'_min'])=x1;
                    production_info.([params.Output(n0).Plots_label{n1},'_max'])=x2;
                end
            end
        end
        segments={'gestures','phonemes','syllables','words'};
        nlen=duration_transition;
        for n1=1:numel(segments)
            if isempty(segmentID), n2=inf;
            else [nill,n2]=ismember(segmentID,segments);
            end
            if n1<=n2
                production_info.([segments{n1},'_duration'])=[production_info1.([segments{n1},'_duration']) nlen production_info2.([segments{n1},'_duration'])];
                production_info.([segments{n1},'_name'])=[production_info1.([segments{n1},'_name']) {'-'} production_info2.([segments{n1},'_name'])];
                production_info.([segments{n1},'_durationfixed'])=[production_info1.([segments{n1},'_durationfixed']) true production_info2.([segments{n1},'_durationfixed'])];
                nlen=1;
            else
                production_info.([segments{n1},'_duration'])=[production_info1.([segments{n1},'_duration'])(1:end-1) production_info1.([segments{n1},'_duration'])(end)+nlen+production_info2.([segments{n1},'_duration'])(1) production_info2.([segments{n1},'_duration'])(2:end)];
                production_info.([segments{n1},'_name'])=[production_info1.([segments{n1},'_name']) production_info2.([segments{n1},'_name'])(2:end)];
                production_info.([segments{n1},'_durationfixed'])=[production_info1.([segments{n1},'_durationfixed']) production_info2.([segments{n1},'_durationfixed'])(2:end)];
                nlen=-1;
            end
        end

        %timeseries <- timeseries1 & timeseries2;
        timeseries=diva_targets('timeseries',production_info,'header');
        if ~isempty(timeseries1),
            t0=timeseries.time<=production_info1.length;
            timeseries.Art(t0,:)=timeseries1.Art(min(size(timeseries1.Art,1),1:nnz(t0)),:);
        end
        if ~isempty(timeseries2),
            t0=timeseries.time>=production_info1.length+duration_transition;
            timeseries.Art(t0,:)=timeseries2.Art(min(size(timeseries2.Art,1),1:nnz(t0)),:);
        end
        t0=find(timeseries.time>=production_info1.length & timeseries.time<=production_info1.length+duration_transition);
        if t0(1)>1, t0=[t0(1)-1;t0(:)]; end
        if t0(end)<size(timeseries.Art,1), t0=[t0(:);t0(end)+1]; end
        for n1=1:size(timeseries.Art,2), timeseries.Art(t0,n1)=linspace(timeseries.Art(t0(1),n1),timeseries.Art(t0(end),n1),numel(t0))'; end
        varargout={production_info, timeseries};
    otherwise
        varargout{1}=feval([mfilename,'_',option],varargin{:});
end
end

function production_info=diva_targets_format(production_info,doextend)
if nargin<2||isempty(doextend), doextend=false; end
temp=[];
allx0=[];
params=diva_vocaltract;
for n0=1:numel(params.Output),
    for n1=1:numel(params.Output(n0).Plots_dim)
        if numel(params.Output(n0).Plots_dim{n1})==1
            idx=params.Output(n0).Plots_dim{n1};
            if ~isfield(production_info, [params.Output(n0).Plots_label{n1},'_control']), % allows incomplete targets (for back-compatibility)
                if isempty(temp), temp=diva_targets_initstruct; end
                production_info.([params.Output(n0).Plots_label{n1},'_control'])=[0 production_info.length];
                production_info.([params.Output(n0).Plots_label{n1},'_min'])=temp.([params.Output(n0).Plots_label{n1},'_min']);
                production_info.([params.Output(n0).Plots_label{n1},'_max'])=temp.([params.Output(n0).Plots_label{n1},'_max']);
            end
            x0=production_info.([params.Output(n0).Plots_label{n1},'_control']);
            x1=production_info.([params.Output(n0).Plots_label{n1},'_min']);
            x2=production_info.([params.Output(n0).Plots_label{n1},'_max']);
            if ~any(x0<=0), x0=[0 x0]; x1=[x1(1) x1]; x2=[x2(1) x2]; end
            if ~any(x0>=production_info.length)&&(numel(x0)<=1||doextend), x0=[x0 production_info.length]; x1=[x1 x1(end)]; x2=[x2 x2(end)]; end; % extends time creating new segment
            if ~any(x0>=production_info.length), ix0=find(x0==x0(end),1); x0(ix0:end)=production_info.length; end; % extends time extending last segment            
            x0=min(production_info.length,x0);
            if ~isequal(x0,unique(x0)), [x0,idx]=unique(x0,'first'); x1=x1(idx); x2=x2(idx); end
            production_info.([params.Output(n0).Plots_label{n1},'_control'])=x0(:)';
            production_info.([params.Output(n0).Plots_label{n1},'_min'])=x1(:)';
            production_info.([params.Output(n0).Plots_label{n1},'_max'])=x2(:)';
            allx0=union(allx0,x0);
        end
    end
end
nsegments=max(0,numel(allx0)-1);
segments={'gestures','phonemes','syllables','words'};
for n1=1:numel(segments)
    if n1==1, production_info.([segments{n1},'_duration'])=diff(allx0(:)'); end
    if ~isfield(production_info, [segments{n1},'_duration']), production_info.([segments{n1},'_duration'])=nsegments; end
    if ~isfield(production_info, [segments{n1},'_name'])||isempty(production_info.([segments{n1},'_name'])), production_info.([segments{n1},'_name'])=repmat({'undefined'},1,numel(production_info.([segments{n1},'_duration']))); end
    if ~isfield(production_info, [segments{n1},'_durationfixed'])||isempty(production_info.([segments{n1},'_durationfixed'])), production_info.([segments{n1},'_durationfixed'])=false(size(production_info.([segments{n1},'_duration']))); end
    x0=production_info.([segments{n1},'_duration']);
    x1=production_info.([segments{n1},'_name']);
    x2=production_info.([segments{n1},'_durationfixed']);
    if n1>1, 
        if isempty(x0),x0=nsegments; end
        x0=max(1,round(x0));
        while sum(x0)>nsegments, if x0(end)>nsegments-sum(x0), x0(end)=x0(end)-nsegments+sum(x0); else x0=x0(1:end-1); end; end 
        if sum(x0)<nsegments, x0(end)=x0(end)+nsegments-sum(x0); end
        %while sum(x0)>nsegments, x0=x0(1:end-1); end
        %if sum(x0)<nsegments, x0=[x0 nsegments-sum(x0)]; end
    end
    if ischar(x1), x1={x1}; end
    if numel(x1)>numel(x0), x1=x1(1:numel(x0)); end
    if numel(x1)<numel(x0), x1=x1(min(numel(x1),1:numel(x0))); end
    if numel(x2)>numel(x0), x2=x2(1:numel(x0)); end
    if numel(x2)<numel(x0), x2=x2(min(numel(x2),1:numel(x0))); end
    production_info.([segments{n1},'_duration'])=x0(:)';
    production_info.([segments{n1},'_name'])=x1(:)';
    production_info.([segments{n1},'_durationfixed'])=x2(:)';
    nsegments=numel(x0);
end
if isfield(production_info,'sampling')&&isequal(production_info.sampling,'fixedrate'), production_info.sampling='fixed rate'; end
if ~isfield(production_info,'sampling'), production_info.sampling='sparse'; end
if ~isfield(production_info,'interpolation')||isequal(production_info.sampling,'sparse'), production_info.interpolation='linear'; end
end

function production_info=diva_targets_initstruct(nrandom)
if nargin<1, nrandom=0; end
production_info.name='';
production_info.length=500;
production_info.wrapper=0;
production_info.interpolation='linear';
production_info.sampling='sparse';
params=diva_vocaltract;
for n0=1:numel(params.Output),
    for n1=1:numel(params.Output(n0).Plots_dim)
        if numel(params.Output(n0).Plots_dim{n1})==1
            idx=params.Output(n0).Plots_dim{n1};
            if isfield(params.Output(n0),'DefaultSound'), Default=params.Output(n0).DefaultSound; else Default=params.Output(n0).Range; end
            if n0==1&&nrandom>0
                production_info.([params.Output(n0).Plots_label{n1},'_control'])=linspace(0,production_info.length,nrandom);
                x=sort(rand(2,nrandom));
                production_info.([params.Output(n0).Plots_label{n1},'_min'])=Default(idx,1)*(1-x(1,:))+Default(idx,2)*x(1,:);
                production_info.([params.Output(n0).Plots_label{n1},'_max'])=Default(idx,1)*(1-x(2,:))+Default(idx,2)*x(2,:);
                if Default(idx,2)-Default(idx,1)>100, 
                    production_info.([params.Output(n0).Plots_label{n1},'_min'])=round(production_info.([params.Output(n0).Plots_label{n1},'_min'])); 
                    production_info.([params.Output(n0).Plots_label{n1},'_max'])=round(production_info.([params.Output(n0).Plots_label{n1},'_max']));
                end
            else
                production_info.([params.Output(n0).Plots_label{n1},'_control'])=0;
                production_info.([params.Output(n0).Plots_label{n1},'_min'])=Default(idx,1);
                production_info.([params.Output(n0).Plots_label{n1},'_max'])=Default(idx,2);
            end
        end
    end
end
production_info=diva_targets_format(production_info);
end

function varargout=diva_targets_resampletime(production_info,t1,t2)
varargout={};
% deals with fixed time-segments
[nill,nill,tfixed,tall1]=diva_programs('get_gestures',production_info);
tall2=interp1(t1,t2,tall1,'linear');
isfixed=find(tfixed);
nofixed=find(~tfixed);
if ~isempty(isfixed)&~isempty(nofixed)
    dtall1=diff(tall1);
    for nrepeat=1:100,
        dtall2=diff(tall2);
        dtall2(nofixed)=dtall2(nofixed)+sum(dtall2(isfixed)-dtall1(isfixed))/numel(nofixed);
        dtall2(isfixed)=dtall1(isfixed);
        tall2=[0 cumsum(max(eps,dtall2))];
    end
end
% inteterpolates control points
fnames=fieldnames(production_info);
fnames=fnames(strcmp(fnames,'gestures_duration')|cellfun('length',regexp(fnames,'_control$'))>0);
for n0=1:numel(fnames)
    production_info.(fnames{n0})=round(1*interp1(tall1,tall2,production_info.(fnames{n0}),'linear'))/1; % note: rounded ms units 
end
production_info.length=max(t2);
production_info=diva_targets_format(production_info);
varargout={production_info};
end

function varargout=diva_targets_timeseriesconvert(production_info,params_info)
varargout={};
if isfield(production_info,'sampling')&&isequal(production_info.sampling,'sparse')
    dosparse=true;
    Time=[0;production_info.length+2*production_info.wrapper]; 
    for n0=1:numel(params_info)
        for n1=1:numel(params_info(n0).Plots_dim)
            if numel(params_info(n0).Plots_dim{n1})==1
                x0=production_info.([params_info(n0).Plots_label{n1},'_control'])+production_info.wrapper;
                Time=[Time;x0(:)];
            end
        end
    end
    Time=unique(Time);
    Nt=numel(Time);
else
    dosparse=false;
    DT=5; % sampling rate
    Nt=1+ceil((production_info.length+2*production_info.wrapper)/DT);
    Time=(0:Nt-1)'*DT;
end
for n0=1:numel(params_info)
    y_min=zeros([Nt,params_info(n0).Dimensions]);
    y_max=zeros([Nt,params_info(n0).Dimensions]);
    for n1=1:numel(params_info(n0).Plots_dim)
        if numel(params_info(n0).Plots_dim{n1})==1
            idx=params_info(n0).Plots_dim{n1};
            x0=production_info.([params_info(n0).Plots_label{n1},'_control'])+production_info.wrapper;
            x1=production_info.([params_info(n0).Plots_label{n1},'_min']);
            x2=production_info.([params_info(n0).Plots_label{n1},'_max']);
            %if isequal(x1,'X'), x1=params_info(n0).DefaultSound(idx,1); end
            %if isequal(x2,'X'), x2=params_info(n0).DefaultSound(idx,2); end
            if any(isnan(x1)), x1(isnan(x1))=params_info(n0).DefaultSound(idx,1); end
            if any(isnan(x2)), x2(isnan(x2))=params_info(n0).DefaultSound(idx,2); end
            y_min(:,idx)=diva_targets_interpolate(x0,x1,Time,production_info.interpolation);
            y_max(:,idx)=diva_targets_interpolate(x0,x2,Time,production_info.interpolation);
        end
    end
    if production_info.wrapper>0,
        mask=Time<production_info.wrapper | Time>production_info.wrapper+production_info.length;
        y0_min=params_info(n0).DefaultSilence(:,1);
        y0_max=params_info(n0).DefaultSilence(:,2);
        y_min(mask,:)=repmat(y0_min',nnz(mask),1);
        y_max(mask,:)=repmat(y0_max',nnz(mask),1);
    end
    temp=max(y_min,y_max);
    y_min=min(y_min,y_max);
    y_max=temp;
    varargout=[varargout,{y_min,y_max}];
end
varargout=[varargout,{Time}];
end

function y=diva_targets_interpolate(x0,y0,x,interpolation)
x0=x0(:);
y0=y0(:);
x=x(:);
if numel(x0)~=numel(y0), y=nan(size(x)); return; end
[x0,idx]=sort(x0);
y0=y0(idx);
idx=find(x0(2:end)==x0(1:end-1));
x0(idx)=x0(idx)+eps;
if min(x0)>0,x0=[0;x0];y0=[y0(1);y0]; end
if max(x0)<max(x),x0=[x0;max(x)];y0=[y0;y0(end)]; end
if numel(x0)<=2, interpolation='linear'; end
if numel(x0)<=1, interpolation='nearest'; end
y=interp1(x0,y0,x,interpolation);
end

function [production_id,production_label]=diva_targets_readcsvfile(filename)
filepath=regexprep(filename,'\.csv$','_targets');
production_id=[];
production_label={};
if isdir(filepath) % targets in diva_targets folder
    fname=dir(fullfile(filepath,'*.txt'));
    [nill,tname,nill]=cellfun(@fileparts,{fname.name}','uni',0);
    tname=tname(cellfun('length',regexp(tname,'^bak_'))==0);
    production_label=[production_label;tname(:)];
    production_id=[production_id; nan(numel(tname),1)];
end
if ~isempty(dir(filename)) % targets listed in diva.csv file
    [tproduction_id,tproduction_label]=textread(filename,'%n%s','delimiter',',','headerlines',1);
    production_label=[production_label;tproduction_label(:)];
    production_id=[production_id; tproduction_id];
elseif isempty(production_id)
    disp(['warning: targets file ',filename,' or directory ',filepath,' does not exist or is empty: initializing']);
end
end

function diva_targets_writecsvfile(filename,production_id,production_label)
if any(~isnan(production_id))
    fh=fopen(filename,'wt');
    fprintf(fh,'ID,Label\n');
    for n1=1:numel(production_id)
        if ~isnan(n1), fprintf(fh,'%d,%s\n',production_id(n1),production_label{n1}); end
    end
    fclose(fh);
end
end

function out=diva_targets_txt2struct(filename,out)
if nargin<2, out=[]; end
comment=0;
fieldname='arg';
s=textread(filename,'%s');
for n1=1:length(s),
    if comment || isempty(s{n1}),
    elseif strncmp(s{n1},'%{',2), % comment open
        comment=1;
    elseif strncmp(s{n1},'%}',2), % comment close
        comment=0;
    elseif s{n1}(1)=='#', % field name
        fieldname=(s{n1}(2:end));
        out.(fieldname)=[];
    else % field value
        n=str2double(s{n1});
        if ~isnan(n)&&all(ismember(s{n1},'0123456789.+-')), newvalue=n; 
        elseif isnan(n)&&~isempty(regexp(fieldname,'_min$|_max$')), newvalue=NaN; 
        elseif any(s{n1}==','), newvalue=regexp(s{n1},'\s*,\s*','split'); newvalue=newvalue(cellfun('length',newvalue)>0);
        else newvalue=s{n1}; 
        end; %{s{n1}}; end
        if isfield(out,fieldname) && ~isempty(out.(fieldname)),
            out.(fieldname)=cat(2,out.(fieldname),newvalue);
        else
            out.(fieldname)=newvalue;
        end
    end
end
out=diva_targets_format(out);
end

function diva_targets_struct2txt(out,filename)
fh=fopen(filename,'wt');
s=fieldnames(out);
for n1=1:length(s),
    fprintf(fh,'#%s\n',s{n1});
    if iscell(out.(s{n1}))
        fprintf(fh,'%s\n',regexprep(sprintf('%s,',out.(s{n1}){:}),',$',''));
    elseif ischar(out.(s{n1}))
        fprintf(fh,'%s\n',out.(s{n1}));
    else
        x=out.(s{n1});
        for n2=1:numel(x),
            n=sum(rem(x(n2)*logspace(0,6,7),1)~=0);
            if isnan(x(n2)), fprintf(fh,'X ');
            else fprintf(fh,['%0.',num2str(n),'f '],x(n2));
            end
        end
        fprintf(fh,'\n');
    end
end
fclose(fh);
end



    

