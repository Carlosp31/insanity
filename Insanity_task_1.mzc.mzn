int: state1;
int: state2;
int: state3;
int: state4;
array[int] of int: s1;
array[int] of int: s2;
array[int] of int: s3;
array[int] of int: s4;
array[int] of string: colors;

% We put the side colors of the 4 cubes together so we can go through them with forall:
% sides[cb, sd] is the color the model says cube cb shows on side sd (1 front, 2 right, 3 back, 4 left).
array[1..4, 1..4] of int: sides = array2d(1..4, 1..4, s1 ++ s2 ++ s3 ++ s4);

%Constraints
% ============================================================

% Every color of each side of the tower is different:
% For every side of the tower we ask for each cube if the color on that side is equal to a specific color from 1 to 4,
% if it is true the boolean is converted to 1, then we sum this result for the 4 cubes, if the total sum is 1 that color appeared only one time.
bool: Constraint1 = forall(sd, v in 1..4)( sum(cb in 1..4)(bool2int(sides[cb, sd] = v)) = 1 );


output ["The states are: \(state1), \(state2), \(state3), \(state4)\n"] ++
       [ if Constraint1 = true then "Every color appears one time on each side of the tower\n" else "Problem: Colors on a side of the tower are not different\n" endif];
