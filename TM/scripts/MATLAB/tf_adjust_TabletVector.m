function [adjust_vec_dr] = tf_adjust_TabletVector(vec_dr,ratio)
% TF_ADJUST_TABLET2WINDOW is the function to adjust intended vector dr of
% agent on a screen.
%
% This function is necessary, because the vector dr on the tablet is not
% equal to the vector dr on a screen.
% The ratio X to Y of the tablet is 5 to 4, and the ratio X to Y of a
% general screen is 16 to 9.
%
% vec_dr : A vector dr from GetMouse, also this is from a screen.
% ratio : The ratio X to Y of a screen.
% ex) 16:9 -> ratio = [16,9]
R = [5/ratio(1), 0; 0, 4/ratio(2)];	% a transform matrix (to get an original coordinate of tablet from GetMouse)
adjust_R = [1,0;0,1] * 3.5;       % a transform matrix (to make the original coordinate 3 times it on an adjust screen coordinate)
adjust_vec_dr = adjust_R * (R * vec_dr');
adjust_vec_dr = adjust_vec_dr';
end