%      Instant Insanity solver using constraint programming in Minizinc (all sides have one color instead of different colors)
%--------------------------------------------------------------------------------------
% We include this in order to use the all_equal constraint later.
include "globals.mzn";
%--------------------------------------------------------------------------------------
% We are going to model the Instant Insanity game cubes as an array for each cube. Each cube has 6 faces with

% top (index 1), front (index 2), right (index 3), down (index 4), back (index 5), left (index 6).

% We chose this order on purpose: the opposite face of index f is always f+3 (top-down 1-4, front-back 2-5,
% right-left 3-6). This is important because when a cube is turned two opposite faces always stay opposite.
% n is the number of faces of a cube.
int: n = 6;

% The 4 colors are modeled as integers from 1 to 4. The array colors is only used to print the names in the output.
array [1..4] of string: colors = ["Red", "Blue", "Green", "White"]; % Red = 1, Blue = 2, Green = 3, White = 4

% The colors of each cube were read from the cube nets of Figure 2 of the task. In each net the square on top is the
% top face, the row of 3 squares is left, front and right, the square under the front is the down face and the last
% square is the back face. 
array [1..n] of 1..4: cube1 = [1, 1, 4, 3, 4, 2]; %Top: Red, Front: Red, Right: White, Down: Green, Back: White, Left: Blue
array [1..n] of 1..4: cube2 = [2, 1, 4, 4, 2, 3]; 
array [1..n] of 1..4: cube3 = [3, 1, 2, 4, 3, 2]; 
array [1..n] of 1..4: cube4 = [4, 1, 1, 3, 1, 2]; 


% ============================================================
% Model
% ============================================================

% Variables of orientation of the cubes.
% A cube can be placed in 24 different ways: any of its 6 faces can be on top, and for each of them we can turn
% the cube around the vertical axis in 4 positions (6 x 4 = 24). 

var 1..24: state1;
var 1..24: state2;
var 1..24: state3;
var 1..24: state4;

% Table of the 24 states (orientations) of a cube.

% Each row is one state and each column is a position of the turned cube, in the same order as the faces:
% top, front, right, down, back, left. The number in the table is the original face of the cube that ends up in
% that position.

% For example, row 2 (1, 3, 5, 4, 6, 2) means that after turning the cube the original face 3
% is in the front, face 5 on the right, face 6 in the back and face 2 on the left.

% The rows are in groups of 4: in each group the same original face is on top, and inside the group the cube is
% turned around the vertical axis 
%(what was on the right goes to the front, the back goes to the right,the left goes to the back and the front goes to the left). 

% The top and the down faces do not move in that turn.

% In every row the positions 1-4, 2-5 and 3-6 have numbers with a difference of 3, so opposite faces stay opposite,
% which is what happens with a real cube.

array [1..24, 1..6] of int: states =
     % top = original face 1
  [| 1, 2, 3, 4, 5, 6
   | 1, 3, 5, 4, 6, 2
   | 1, 5, 6, 4, 2, 3
   | 1, 6, 2, 4, 3, 5
     % top = original face 2
   | 2, 4, 3, 5, 1, 6
   | 2, 3, 1, 5, 6, 4
   | 2, 1, 6, 5, 4, 3
   | 2, 6, 4, 5, 3, 1
     % top = original face 4
   | 4, 5, 3, 1, 2, 6
   | 4, 3, 2, 1, 6, 5
   | 4, 2, 6, 1, 5, 3
   | 4, 6, 5, 1, 3, 2
     % top = original face 5
   | 5, 1, 3, 2, 4, 6
   | 5, 3, 4, 2, 6, 1
   | 5, 4, 6, 2, 1, 3
   | 5, 6, 1, 2, 3, 4
     % top = original face 3
   | 3, 4, 5, 6, 1, 2
   | 3, 5, 1, 6, 2, 4
   | 3, 1, 2, 6, 4, 5
   | 3, 2, 4, 6, 5, 1
     % top = original face 6
   | 6, 4, 2, 3, 1, 5
   | 6, 2, 1, 3, 5, 4
   | 6, 1, 5, 3, 4, 2
   | 6, 5, 4, 3, 2, 1 |];


% The function State_orientator gives the colors that a cube shows on the 4 sides of the tower (front, right, back
% and left) when the cube is in a certain state. The top and down faces are not returned because in the tower
% they are hidden, so they do not matter for the problem.

% Every color is found in two steps: first states[state, position] tells us which original face of the cube is in
% that position, and then with that face we look for its color in the array of the cube.

% The sides are the positions 2 (front), 3 (right), 5 (back) and 6 (left).
% The state is a variable (var) because the solver decides it, so the colors that the function returns are also
% variables (var 1..4).

function array[1..4] of var 1..4: State_orientator(array[1..6] of int: cube, var 1..24: state) =
  % Front (2)              Right (3)               Back (5)                Left (6)
  [cube[states[state, 2]], cube[states[state, 3]], cube[states[state, 5]], cube[states[state, 6]]]; 

% Side colors of each cube (front, right, back, left) for its chosen state.
% s1[1] is the color of cube 1 on the front of the tower, s1[2] on the right, s1[3] on the back and s1[4] on the left,
% and the same for the other cubes. 

array[1..4] of var 1..4: s1 = State_orientator(cube1, state1);
array[1..4] of var 1..4: s2 = State_orientator(cube2, state2);
array[1..4] of var 1..4: s3 = State_orientator(cube3, state3);
array[1..4] of var 1..4: s4 = State_orientator(cube4, state4);

% Question of task 2
% ============================================================

% Is it possible to stack the cubes so each side has one color only?
% This means that the 4 cubes show the same color on the front, the same color on the right, and so on.

% For every side we take the color of the 4 cubes on that side and we ask
% the 4 colors to be equal with the all_equal constraint.

% If there is no way to stack the cubes like this, the solver proves that no
% orientation fulfills them and Minizinc prints =====UNSATISFIABLE=====, which is the answer of task 2.
constraint all_equal([s1[1], s2[1], s3[1], s4[1]]);   % front
constraint all_equal([s1[2], s2[2], s3[2], s4[2]]);   % right
constraint all_equal([s1[3], s2[3], s3[3], s4[3]]);   % back
constraint all_equal([s1[4], s2[4], s3[4], s4[4]]);   % left

solve satisfy;

