function [arrow_ind,trea_ind]= arrow_finder(props)
%search and find all the objects that meet the condition
n_objects=numel(props);
arrow_ind=[];
trea_ind=[]
hold on;
for object_id = 1 : n_objects
    if  props(object_id).Area > 90 && props(object_id).Area < 2000
    arrow_ind=[arrow_ind; object_id];
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
    end
    if props(object_id).Area > 2000
    trea_ind=[trea_ind; object_id];
    end
end
hold off;
end