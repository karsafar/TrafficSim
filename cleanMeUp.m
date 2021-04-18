% fires when main function terminates
function cleanMeUp()
% close waitbar
f = findall(0,'type','figure','tag','TMWWaitbar');
delete(f)
end