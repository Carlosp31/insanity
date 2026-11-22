int: state1;
int: state2;
int: state3;
int: state4;
int: stateEq1;
int: stateEq2;
int: stateEq3;
int: stateEq4;
array[int] of int: s1;
array[int] of int: s2;
array[int] of int: s3;
array[int] of int: s4;
array[int] of int: e1;
array[int] of int: e2;
array[int] of int: e3;
array[int] of int: e4;
array[int] of string: colors;

% We put the side colors of the 4 cubes together so we can go through them with forall:
% sides[cb, sd] and sidesEq[cb, sd] are the colors the model says cube cb shows on side sd (1 front, 2 right, 3 back, 4 left)
% in the standard problem and in the second problem.
array[1..4, 1..4] of int: sides = array2d(1..4, 1..4, s1 ++ s2 ++ s3 ++ s4);
array[1..4, 1..4] of int: sidesEq = array2d(1..4, 1..4, e1 ++ e2 ++ e3 ++ e4);

%Constraints
% ============================================================

% Standard problem, every color of each side of the tower is different:
% For every side of the tower we ask for each cube if the color on that side is equal to a specific color from 1 to 4,
% if it is true the boolean is converted to 1, then we sum this result for the 4 cubes, if the total sum is 1 that color appeared only one time.
bool: Constraint1 = forall(sd, v in 1..4)( sum(cb in 1..4)(bool2int(sides[cb, sd] = v)) = 1 );

% Second problem, each side of the tower has only one color:
% For every side of the tower we ask for each cube if the color on that side is equal to the color of cube 1 on that same side,
% if it is true the boolean is converted to 1, then we sum this result for the 4 cubes, if the total sum is 4 all the cubes show the same color.
bool: Constraint2 = forall(sd in 1..4)( sum(cb in 1..4)(bool2int(sidesEq[cb, sd] = sidesEq[1, sd])) = 4 );


output ["The states of the standard problem are: \(state1), \(state2), \(state3), \(state4)\n"] ++
       ["The states of the second problem are: \(stateEq1), \(stateEq2), \(stateEq3), \(stateEq4)\n"] ++
       [ if Constraint1 = true then "Standard problem: every color appears one time on each side of the tower\n" else "Problem: Colors on a side of the standard tower are not different\n" endif] ++
       [ if Constraint2 = true then "Second problem: each side of the tower has only one color\n" else "Problem: A side of the second tower has more than one color\n" endif];
