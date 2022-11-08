function varargout=diva_programs(option,varargin)
% DIVA_PROGRAMS provides external access to DIVA motor programs
% 
% -------------------------------------------------------
% PRODUCING A MOTOR PROGRAM OR SEQUENCE OF MOTOR PROGRAMS
% -------------------------------------------------------
%
% [s,fs] = diva_programs('play', programID [, transition_durations]); 
%   produces programID, optionally specifying durations of transitions between each program 
%       programID             : cell array indicating N existing DIVA programs (in diva_targets directory) to be produced 
%       transition_durations  : vector of length N-1, with durations{n} in ms units specifying the duration of the transition between programID{n} and programID{n+1}  
%       s                     : audio signal output
%       fs                    : sampling frequency (Hz)
%
% e.g. [s, fs]= diva_programs('play', {'buy','puppy'});
%
% [s,fs] = diva_programs('play_gestures', programID  [, transition_durations, gesture_durations]); 
% [s,fs] = diva_programs('play_phonemes', programID  [, transition_durations, phoneme_durations]); 
% [s,fs] = diva_programs('play_syllables', programID  [, transition_durations, syllable_durations]); 
% [s,fs] = diva_programs('play_words', programID  [, transition_durations, word_durations]); 
%   same as 'play' option but also specifying the durations of each gesture/phoneme/syllable/word within each program 
%       gesture_durations     : cell array of length N, with durations{n} in ms units specifying the durations of each gesture in programID{n} (one value per gesture) 
%       phoneme_durations     : cell array of length N, with durations{n} in ms units specifying the durations of each phoneme in programID{n} (one value per phoneme) 
%       syllable_durations    : cell array of length N, with durations{n} in ms units specifying the durations of each syllable in programID{n} (one value per syllable) 
%       word_durations        : cell array of length N, with durations{n} in ms units specifying the durations of each word in programID{n} (one value per word) 
%
% e.g. [s, fs]= diva_programs('play_syllables', {'buy','puppy'}, 40, {200, [500,40,250]});
%
% diva_programs('play####', ...)
%    same as corresponding 'play' option but playing the output over the speakers
%
% [s,fs] = diva_programs('play####', ..., 'saveas', newprogramID)
%    same as corresponding 'play' option but also saving the result as a new program with name <newprogramID> 
%
% [target,timeseries] = diva_programs('combine####', ...)
%    same as corresponding 'play' option but returning all information of the resulting new motor program
%
% ----------------------------------------------------
% VIEWING/EDITING TEMPORAL PROPERTIES OF DIVA PROGRAMS
% ----------------------------------------------------
%
% [programIDs] = diva_programs('list');
%   lists all motor programs available
%
% [name, length, fixed] = diva_programs('get_gestures', programID);
% [name, length, fixed] = diva_programs('get_phonemes', programID);
% [name, length, fixed] = diva_programs('get_syllables', programID);
% [name, length, fixed] = diva_programs('get_words', programID);
%   reads gesture/phoneme/syllable/word segments in program <programID>
%       programID             : name of existing DIVA program (in diva_targets directory)
%                                alternatively, programStruct structure with DIVA program fields (e.g. from diva_target('load',...))
%       length (get_gestures) : [1xNg] vector of durations (in ms units) of each gesture 
%                                (note: each gesture is the segment between two consecutive via-points in a production)
%                                (note: if via-points are defined separately for each target dimension, gestures are defined from the union of all via-points) 
%       length (get_phonemes) : [1xNp] vector of durations (number of individual gestures) of each phoneme 
%                                (note: the values in "length" must add up to the total number of gestures in this program) 
%       length (get_syllables): [1xNs] vector of durations (number of phonemes) of each syllable 
%                                (note: the values in "length" must add up to the total number of phonemes in this program) 
%       length (get_words)    : [1xNw] vector of durations (number of syllables) of each word 
%                                (note: the values in "length" must add up to the total number of syllables in this program) 
%       name                  : [1xN] cell array of gesture/phoneme/syllable/word names 
%       fixed                 : [1xN] vector of 0/1 values indicating whether the duration of this gesture/phoneme/syllable/word is fixed irrespective of production speed  
%
% diva_programs('set_####', programID, name, length [, fixed]);
%   specifies gesture/phoneme/syllable/word segments in program <programID>
%   note: output stored in diva_targets directory
%       
% [programStruct] = diva_programs('set_####', programStruct, name, length [, fixed]);
%   returns modified structure (without changing any files in diva_targets) 
%

% ---------------------
% FOR INTERNAL USE ONLY
% ---------------------
%
% [programStruct, timeseries] = diva_programs('load', programID);
%   loads all information from program <programID>
%       programID            : name of existing DIVA program (in diva_targets directory)
%       programStruct        : structure with DIVA program information (see "help diva_target") 
%       timeseries           : sequence of learned motor program targets 
%
% diva_programs('save', programID, programStruct [, timeseries]);
%   saves all information from program <programID>
%

segments={'gestures','phonemes','syllables','words'};
switch(lower(option))
    case 'load'
        targetID=varargin{1};
        target=diva_targets('load','txt',targetID);
        timeseries=diva_targets('load','mat',targetID);
        varargout={target, timeseries};

    case 'save'
        targetID=varargin{1};
        if numel(varargin)>=2&&~isempty(varargin{2}), 
            target = varargin{2};
            if isstruct(targetID), varargout{1}=target;
            else diva_targets('save','txt',targetID,target);
            end
        end
        if numel(varargin)>=3&&~isempty(varargin{3}), 
            timeseries = varargin{3};
            if isstruct(targetID), varargout{2}=timeseries;
            else diva_targets('save','matoverwrite',targetID,timeseries);
            end
        end

    case 'list'
        if nargout, [varargout{1:nargout}]=diva_targets(option,varargin{:});
        else diva_targets(option,varargin{:});
        end

    case cellfun(@(x)['get_',x],segments,'uni',0)
        targetID=varargin{1};
        segmentID=regexprep(lower(option),'get_','');
        if isstruct(targetID), target=targetID;
        else target=diva_targets('load','txt',targetID);
        end
        varargout={...
            target.([segmentID, '_name']),...
            target.([segmentID, '_duration']),...
            target.([segmentID, '_durationfixed'])};
        if nargout>3, varargout{4}= diva_programs_gettimes(target, segmentID); end

    case cellfun(@(x)['set_',x],segments,'uni',0)
        targetID=varargin{1};
        segmentID=regexprep(lower(option),'set_','');
        if isstruct(targetID), target=targetID;
        else target=diva_targets('load','txt',targetID);
        end
        
        if numel(varargin)<2||isempty(varargin{2}), names=target.([segmentID, '_name']); 
        else names=varargin{2}; 
        end
        if ischar(names), names={names}; end
        if numel(varargin)<3||isempty(varargin{3}), durations=target.([segmentID, '_duration']); 
        else durations=varargin{3};
        end
        if numel(varargin)<4||isempty(varargin{4}), 
            dfixed=target.([segmentID, '_durationfixed']); 
            if numel(dfixed)~=numel(names), dfixed=false(size(names)); end
        else dfixed=varargin{4};
        end
        assert(numel(names)==numel(durations),'mismatched size of ''names'' and ''durations'' inputs');
        assert(numel(names)==numel(dfixed),'mismatched size of ''names'' and ''fixed'' inputs');
        target=diva_targets('edit',target,...
            [segmentID, '_name'], names, ...
            [segmentID, '_duration'], durations, ...
            [segmentID, '_durationfixed'], dfixed);
        if isstruct(targetID), varargout={target};
        else diva_targets('save','txt',targetID,target);
        end

    case 'combine'
        [varargout{1:nargout}]=diva_programs('combine_gestures',varargin{:});

    case cellfun(@(x)['combine_',x],segments,'uni',0)
        targetname=[];
        saveas=find(cellfun(@(x)isequal(x,'saveas'),varargin),1);
        if ~isempty(saveas), 
            targetname=varargin{saveas+1}; 
            varargin(saveas+[0 1])=[];
        end
        segmentID=regexprep(lower(option),'combine_','');
        targetID=varargin{1};
        if ~iscell(targetID), targetID={targetID}; end
        if numel(varargin)>=2, transitions=varargin{2}; 
        else transitions=[];
        end
        if numel(varargin)>=3, times=varargin{3};
        else times=[];
        end
        assert(isempty(transitions)|numel(transitions)==numel(targetID)-1, 'mismatch between targetID and transitions inputs');
        assert(isempty(times)|numel(times)==numel(targetID), 'mismatch between targetID and %s duration inputs',segmentID);
        
        target=diva_targets('load','txt',targetID{1});
        assert(~isempty(target),'unable to find target %s',targetID{1});
        timeseries=diva_targets('load','mat',targetID{1});
        if numel(times)>=1&&~isempty(times{1})
            told=diva_programs_gettimes(target,lower(segmentID));
            tnew=[0 cumsum(times{1})];
            target=diva_targets('resampletime',target, told, tnew);
        end
        for n1=2:numel(targetID)
            target2=diva_targets('load','txt',targetID{n1});
            assert(~isempty(target2),'unable to find target %s',targetID{n1});
            timeseries2=diva_targets('load','mat',targetID{n1});
            if numel(times)>=n1&&~isempty(times{n1})
                told=diva_programs_gettimes(target2,lower(segmentID));
                tnew=[0 cumsum(times{n1})];
                assert(numel(told)==numel(tnew),'expecting %d duration values, found %d',numel(told)-1,numel(tnew)-1);
                target2=diva_targets('resampletime',target2, told, tnew);
            end
            if ~isempty(transitions), duration_transition=transitions(min(numel(transitions),n1));
            else duration_transition=40;
            end
            [target,timeseries] = diva_targets('combine', target, target2, duration_transition, [], timeseries, timeseries2, segmentID);
        end
        varargout={target,timeseries};
        if ~isempty(targetname)
            diva_programs('save',targetname,target,timeseries);
        end

    case 'play'
        if ~nargout, diva_programs('play_gestures',varargin{:});
        else [varargout{1:nargout}]=diva_programs('play_gestures',varargin{:});
        end

    case cellfun(@(x)['play_',x],segments,'uni',0)
        [target,timeseries] = diva_programs(regexprep(lower(option),'play_','combine_'),varargin{:});

        t0 = 0:5:max(timeseries.time);
        Art = interp1(timeseries.time,timeseries.Art,t0);
        s = diva_synth(Art','sound');
        fs=4*11025;
        if ~nargout, soundsc(s,fs);
        else varargout={s,fs};
        end

    otherwise
        error('unrecognized option %s',option);
end

end

function t = diva_programs_gettimes(target, segmentID)
t=[];
s=lower(segmentID);
while ~isequal(s,'gestures')
    switch(s)
        case 'words'
            n2=cumsum(target.words_duration);
            if isempty(t), t=n2; else t=n2(t); end
            s='syllables';
        case 'syllables'
            n2=cumsum(target.syllables_duration);
            if isempty(t), t=n2; else t=n2(t); end
            s='phonemes';
        case 'phonemes'
            n2=cumsum(target.phonemes_duration);
            if isempty(t), t=n2; else t=n2(t); end
            s='gestures';
        otherwise
            error('unrecognized keyword %s (gestures|phonemes|syllables|words)',s);
    end
end
n2=cumsum(target.gestures_duration);
if isempty(t), t=[0 n2]; else t=[0 n2(t)]; end
end

