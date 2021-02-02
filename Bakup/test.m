function test(option)
if ~nargin
else
    switch(option)
        case 'init'
            hfig=figure;
            hax=axes;
            hplot=bar(rand(1,10));
            set(hfig,'windowbuttonmotionfcn',@(varargin)callbackthing)
            data=struct('hfig',hfig,'hax',hax,'hplots',hplot);
    end
end

    function callbackthing(varargin)
        p1=get(0,'pointerlocation');
        p2=get(data.hfig,'position');
        pos=p1-p2(1:2);
        
        set(data.hfig,'currentpoint',pos);
        pos2=get(data.hax,'currentpoint');
        
        disp(round(pos2(1)));
    end



end

