function testsingularvaluedecomposition(a,b)%A,B)

%picks vectors a, b from A and B respectively

%a = reshape(A(:,1),45,[]);
%b = reshape(B(:,1),45,[]);

%reshapes them into a matrix

mata = reshape(a(:,2),[],3);
matb = reshape(b(:,1),[],3);

%calculate means

meana = mean(mata);
meanb = mean(matb);

%calculates the centered matrices;

ca = mata - meana;
cb = matb - meanb;

%calculates the covariance matrix

cov_ = ca.'*cb;

%does the svd decomposition

[u,s,v] = svd(cov_);

%calculates the rotation matrix
r = v*u.';

%calculates rotated a and rotated b

tsb = cb*r;
tsa = (r*ca.').';

%makes everyone into long vectors so we can calculate distances:

longa = a(:,1);
longb = b(:,1);

longca = reshape(ca,[],1);
longcb = reshape(cb,[],1);

longtsb = reshape(tsb,[],1);
longtsa = reshape(tsa,[],1);

%calculate the distance without any change between vectors a and b

disp('Original distance:')
pdist2(longa',longb','euclidean','Smallest',1)

%calculate the distance with means removed (centered around the centroids)

disp('Distance with means removed (a and b centered):')
pdist2(longca',longcb','euclidean','Smallest',1)

%calculates the distance with svd rotation matrix

disp('Distance with rotation on a, b just centered:')
pdist2(longtsa',longcb','euclidean','Smallest',1)

disp('Distance with rotation on a and b:')
pdist2(longtsa',longtsb','euclidean','Smallest',1)

disp('Distance with rotation on b, a just centered:')
pdist2(longtsb',longca','euclidean','Smallest',1)

