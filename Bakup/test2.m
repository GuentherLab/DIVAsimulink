x = 4;
if x == 4
    disp('if')
elseif x == (2+2)
    disp('elseif')
else
    disp('else')
end
% Plot data - a line from (1,1) to (10,10).
h=plot(1:10, 'bs-')
grid on;
axis equal;
xlim([0 11]);
ylim([0 11]);
datacursormode on;
% Enlarge figure to full screen.
screenSize = get(0,'ScreenSize')
set(gcf, 'units','pixels','outerposition', screenSize);
% Ask user to click on a point.
uiwait(msgbox('Click near any data point'));
% Print the x,y coordinates - will be in plot coordinates
[x,y] = ginput(1) % Will be close to 5,5 but not exactly.
% Mark where they clicked with a cross.
hold on;
plot(x,y, 'r+', 'MarkerSize', 20, 'LineWidth', 3);
% Print the coordinate, but this time in figure space.
% Coordinates will be way different, like 267, 196 instead of 5,5.
cpFigure = get(gcf, 'CurrentPoint')
cpAxis = get(gca, 'CurrentPoint')
% Print coordinates on the plot.
label = sprintf('(%.1f, %.1f) = (%.1f, %.1f) in figure space', x, y, cpFigure(1), cpFigure(2));
text(x+.2, y, label);
% Tell use what ginput, cpFigure, and cpAxis are.
message = sprintf('ginput = (%.3f, %.3f)\nCP Axis = [%.3f, %.3f\n              %.3f, %.3f]\nCP Figure = (%.3f, %.3f)\n',...
  x, y, cpAxis(1,1), cpAxis(1,2), cpAxis(2,1), cpAxis(2,2), cpFigure(1), cpFigure(2));
uiwait(msgbox(message));
% Retrieve the x and y data from the plot
xdata = get(h, 'xdata')
ydata = get(h, 'ydata')
% Scan the actual ploted points, figuring out which one comes closest to 5,5
distances = sqrt((x-xdata).^2+(y-ydata).^2)
[minValue minIndex] = min(distances)
% Print the distances next to each data point
for k = 1 : length(xdata)
  label = sprintf('D = %.2f', distances(k));
  text(xdata(k)+.2, ydata(k), label, 'FontSize', 14);
end
% Draw a line from her point to the closest point.
plot([x xdata(minIndex)], [y, ydata(minIndex)], 'r-');
% Tell her what data point she clicked closest to
message = sprintf('You clicked closest to point (%d, %d)',...
  xdata(minIndex), ydata(minIndex));
helpdlg(message);


function test2(option)
if ~nargin
    option='init';
    test2(option)
else
    switch(option)
        case 'init'
            hfig=figure;    % creates a figure
            hax=axes;       % creates axes within figure 
            hplot=bar(rand(1,10));  % creates barplot withing axes
            set(hfig,'WindowButtonDownFcn',@downcallback, 'WindowButtonUpFcn',@upcallback, 'WindowButtonMotionFcn',@overcallback); % callback for when mouse hovers over plot
            %set(hfig,'WindowButtonUpFcn',@(varargin)downcallback); % callback for when mouse hovers over plot
            data=struct('hfig',hfig,'hax',hax,'hplots',hplot);  % store figure, axes and plot properties in a data var 
    end
end


    function downcallback(varargin)
        %ydata = data.hplots.YData;  % get bar plot y data
        %pos = get(data.hax,'currentpoint'); % get cursor pointer
        %curBarIdx = round(pos(1));  % % figure out x-index cursor is over
        
        data.mouseIsDown = true; % recognizes / saves the fact that the mouse is pressed down
    end

    function upcallback(varargin)
        %ydata = data.hplots.YData;  % get bar plot y data
        %pos = get(data.hax,'currentpoint'); % get cursor pointer
        %curBarIdx = round(pos(1));  % % figure out x-index cursor is over
        
        data.mouseIsDown = false;% recognizes / saves the fact that the mous has been let go
    end

    function overcallback(varargin)    % for when mouse hovers over plot
        if isfield(data, 'mouseIsDown')
            if data.mouseIsDown
                p1=get(0,'pointerlocation');    % get mouse location [x y]
                p2=get(data.hfig,'position');   % get position of figure [x y w h]
                pos=p1-p2(1:2); % find mouse position relative to figure
                
                set(data.hfig,'currentpoint',pos); % not sure
                
                pos2=get(data.hax,'currentpoint'); % get current point rel to axes [x y -; x y -]
                %disp(round(pos2(1)));
                
                curBarIdx = round(pos2(1));
                ydata = data.hplots.YData;  % get bar plot y data
                newY = ydata;
                newY(curBarIdx) = pos2(1,2);
                %disp(pos2(1,2));
                data.hplots.YData = newY;
            end
        end
    end

    
   %%
   %load diva_synth.mat
   %vt
   %close all
   %plot(vt.Average)
   %axis square
   %plot(vt.Average+vt.Base*randn(32,1)); axis equal;
   %vt.Average+vt.Base*x = newshapeoftract 
   %%

end