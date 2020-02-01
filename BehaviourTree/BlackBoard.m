classdef BlackBoard < handle & dynamicprops
   
    properties
%         arrayDoublicate
    end
    
    methods
        function add_item(obj,name,value)
            addprop(obj,name);
            obj.(name) = value;
%             obj.arrayDoublicate = [obj.arrayDoublicate; value];
        end
        function set_props(obj,prop,val)
            obj.(prop) = val;
        end
    end
    
end