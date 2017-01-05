function [handles, waitbarH]= embedWaitbar(x,whichbar,varargin)
% create a embed waitbar
% h = embedWaitbar(p,'title',handles.sFigure,[x,y,w,h],handles.titleText);
% set value: embedWaitbar(p,h) or embedWaitbar(p,h,'title')
%

if ischar(whichbar) || iscellstr(whichbar)
    if nargin > 3 
        bar = waitbar(x,'','visible','off');
        h = get(bar,'children');
        set(h,'parent',varargin{1});
        set(h,'Units','character','Position',varargin{2});
        set(h,'XColor',[0.09,0.09,1]);
        set(h,'YColor',[0.09,0.09,1]);
        set(h,'Color',[0.09,0.09,1]);
        h.Visible = 'off';
        handles.h = h;
        handles.maxWidth = varargin{2}(3);
        if nargin == 5
            set(varargin{3},'String',whichbar);
            handles.title = varargin{3};
        end
        embedWaitbar(x,handles);
        h.Visible = 'on';
    else
        error('Not enough arguments!');
    end
else
    position = get(whichbar.h,'Position');
    position(3) = whichbar.maxWidth * x;
    set(whichbar.h,'Position',position);
    if nargin == 3
        set(whichbar.title,'String',varargin{1});
    end
end

end
