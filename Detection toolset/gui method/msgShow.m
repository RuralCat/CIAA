function msgShow(~,msg,msgType)
%

if nargin == 2
    msgType = 'none';
end
switch msgType
    case 'none'
        title = '';
    case 'error'
        title = 'Error';
    case 'help'
        title = 'Help';
    otherwise
        title = 'Unkown type';
end     
    
createMode = 'modal';
uiwait(msgbox(msg,title,msgType,createMode));
