close all;
clear all;

%% Reading image
im = imread('Treasure_medium.jpg'); % change name to process other images
imshow(im);
pause;

%% Binarisation
bin_threshold = 0.09; % parameter to vary
bin_im = im2bw(im, bin_threshold);
imshow(bin_im);
pause;

%% Extracting connected components
con_com = bwlabel(bin_im);
imshow(label2rgb(con_com));  
pause;

%% Computing objects properties
props = regionprops(con_com);

%% Drawing bounding boxes
n_objects = numel(props);
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
end
hold off;
pause;

%% Arrow/non-arrow determination
% You should develop a function arrow_finder, which returns the IDs of the arror objects. 
% IDs are from the connected component analysis order. You may use any parameters for your function. 

[arrow_ind,trea_ind]= arrow_finder(props);

%% Finding red arrow
n_arrows = numel(arrow_ind);
start_arrow_id = 0;
% check each arrow until find the red one
for arrow_num = 1 : n_arrows
    object_id = arrow_ind(arrow_num);    % determine the arrow id
    
    % extract colour of the centroid point of the current arrow
    centroid_colour = im(round(props(object_id).Centroid(2)), round(props(object_id).Centroid(1)), :); 
    if centroid_colour(:, :, 1) > 240 && centroid_colour(:, :, 2) < 10 && centroid_colour(:, :, 3) < 10
	% the centroid point is red, memorise its id and break the loop
        start_arrow_id = object_id;
        break;
    end
end


%% Hunting
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;

% while the current object is an arrow, continue to search
    
    red_channel = im(:, :, 1);%find yellow pixel
    green_channel = im(:, :, 2);
    blue_channel = im(:, :, 3);
    yellow_map = green_channel > 150 & red_channel > 150 & blue_channel < 50;
    [i_yellow, j_yellow] = find(yellow_map > 0);
    [idx,C] = kmeans([j_yellow i_yellow],length(arrow_ind));
    C=round(C);
    CC=[];
    box=[];
    for i=1:length(props)
    [k,dist]=dsearchn(C,props(i).Centroid);
    box=[box;bbox2points(props(i).BoundingBox)];%convert boundary box 
    CC(i,:)=C(k,:);
    end
    j=0;
    rec=[];
while ismember(cur_object, arrow_ind) 
    % You should develop a function next_object_finder, which returns
    % the ID of the nearest object, which is pointed at by the current
    % arrow. You may use any other parameters for your function.
    j=j+1;
    %% Finding yellow pixels
    step=0;
    dir_vec=CC(cur_object,:)-props(cur_object).Centroid;%apply direction vector
    pos=props(cur_object).Centroid;%apply current point
    pos=pos+3*dir_vec;%make initial step
    
    while(step==0)
        for i = 1:length(props)
            if i==1 %check if in boundary box region, stop if yes
                step=inpolygon(pos(1),pos(2),box(i:i*4,1),box(i:4,2));
            elseif i>1
                step=inpolygon(pos(1),pos(2),box(i*4-3:i*4,1),box(i*4-3:i*4,2));
            end
            if step==1
                
                break
            end
            %for debug
            rec=[rec ; pos];
        end
        pos=pos+0.5*dir_vec;

    end
    cur_object=i;
    
    path(j) = cur_object;
    if j>1 && path(j)==path(j-1)
        break;
    end
end
path(path==0)=[];
disp('The movement is');
disp(path);
%% visualisation of the path
imshow(im);
hold on;
for path_element = 1 : numel(path) - 1
    object_id = path(path_element); % determine the object id
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'y');
    str = num2str(path_element);
    text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 14);
end

% visualisation of the treasure
treasure_id = path(end);
rectangle('Position', props(treasure_id).BoundingBox, 'EdgeColor', 'g');