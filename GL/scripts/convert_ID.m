function pos = convert_ID(ID)
x = repmat([-2:2]',5,1);
y = reshape(repmat([2:-1:-2],5,1),25,1);
pos = [x(ID);y(ID)];