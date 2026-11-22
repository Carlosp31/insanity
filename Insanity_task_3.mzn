%      Instant Insanity solver using constraint programming in Minizinc
%--------------------------------------------------------------------------------------
% Each cube has 6 faces with top (index 1), front (index 2), right (index 3), down (index 4), back (index 5), left (index 6).
% We use the same order as in tasks 1 and 2: the opposite face of index f is always f+3 (top-down 1-4, front-back 2-5,
% right-left 3-6), because when a cube is turned two opposite faces always stay opposite.
% n is the number of faces of a cube.
int: n = 6;

% The 4 colors are modeled as integers from 1 to 4.

array [1..4] of string: colors = ["Red", "Blue", "Green", "White"]; 

% In tasks 1 and 2 the colors of the cubes were given. Now they are variables:
% the solver chooses the color of every face, so the result are new cube nets.
% Every face can take a color from 1 to 4, so each cube is an array of 6 variables with domain 1..4.

array [1..n] of var 1..4: cube1;
array [1..n] of var 1..4: cube2;
array [1..n] of var 1..4: cube3;
array [1..n] of var 1..4: cube4;


% ============================================================
% Model 
% ============================================================

% The same cubes have to solve both problems, but each problem needs its own orientation of the cubes,
% so we have two sets of orientation variables.
% As in task 1, a cube can be placed in 24 different ways: any of its 6 faces can be on top, and for each of them
% we can turn the cube around the vertical axis in 4 positions (6 x 4 = 24).
% Orientation for the standard problem (4 different colors on each side):
var 1..24: state1;
var 1..24: state2;
var 1..24: state3;
var 1..24: state4;
% Orientation for the second problem (one color on each side):
var 1..24: stateEq1;
var 1..24: stateEq2;
var 1..24: stateEq3;
var 1..24: stateEq4;

% Table of the 24 states (orientations) of a cube, the same as in tasks 1 and 2.
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


% Same function as in task 1, but now the cube is also a variable (var 1..4) because its colors are unknown.

% The function State_orientator gives the colors that a cube shows on the 4 sides of the tower (front, right, back
% and left) when the cube is in a certain state. The top and down faces are not returned because in the tower
% they are hidden, so they do not matter for the problem.

% Every color is found in two steps: first states[state, position] tells us which original face of the cube is in
% that position, and then with that face we look for its color in the array of the cube.

% The sides are the positions 2 (front), 3 (right), 5 (back) and 6 (left).
% The state is a variable (var) because the solver decides it, so the colors that the function returns are also
% variables (var 1..4).

function array[1..4] of var 1..4: State_orientator(array[1..6] of var 1..4: cube, var 1..24: state) =
  % Front (2)              Right (3)               Back (5)                Left (6)
  [cube[states[state, 2]], cube[states[state, 3]], cube[states[state, 5]], cube[states[state, 6]]]; 

% Side colors of each cube (front, right, back, left) in the orientation of the standard problem.
% s1[1] is the color of cube 1 on the front of the standard tower, s1[2] on the right, s1[3] on the back and s1[4]
% on the left, and the same for the other cubes.

array[1..4] of var 1..4: s1 = State_orientator(cube1, state1);
array[1..4] of var 1..4: s2 = State_orientator(cube2, state2);
array[1..4] of var 1..4: s3 = State_orientator(cube3, state3);
array[1..4] of var 1..4: s4 = State_orientator(cube4, state4);

% Side colors of each cube (front, right, back, left) in the orientation of the second problem.
% They use the same cubes (same colors) but the other set of states, so e1 is cube 1 turned with stateEq1.

array[1..4] of var 1..4: e1 = State_orientator(cube1, stateEq1);
array[1..4] of var 1..4: e2 = State_orientator(cube2, stateEq2);
array[1..4] of var 1..4: e3 = State_orientator(cube3, stateEq3);
array[1..4] of var 1..4: e4 = State_orientator(cube4, stateEq4);

% Constraints
% ============================================================

% Standard problem: each side of the tower must show the 4 colors without repeating.
% Each side of the tower must show the 4 colors without repeating.
% For every side we take the color of the 4 cubes on that side and we ask
% the 4 colors to be different from each other.

constraint s1[1] != s2[1] /\ s1[1] != s3[1] /\ s1[1] != s4[1] /\
           s2[1] != s3[1] /\ s2[1] != s4[1] /\ s3[1] != s4[1];   % front
           
constraint s1[2] != s2[2] /\ s1[2] != s3[2] /\ s1[2] != s4[2] /\
           s2[2] != s3[2] /\ s2[2] != s4[2] /\ s3[2] != s4[2];   % right
           
constraint s1[3] != s2[3] /\ s1[3] != s3[3] /\ s1[3] != s4[3] /\
           s2[3] != s3[3] /\ s2[3] != s4[3] /\ s3[3] != s4[3];   % back
           
constraint s1[4] != s2[4] /\ s1[4] != s3[4] /\ s1[4] != s4[4] /\
           s2[4] != s3[4] /\ s2[4] != s4[4] /\ s3[4] != s4[4];   % left

% Second problem: each side of the tower must show only one color.
% For every side we take the color of the 4 cubes on that side in the second orientation 
% we ask that cube 1 has the same color as cube 2, cube 2 the
% same as cube 3 and cube 3 the same as cube 4. If every cube is equal to the next one, the 4 colors are equal.

constraint e1[1] = e2[1] /\ e2[1] = e3[1] /\ e3[1] = e4[1];   % front
constraint e1[2] = e2[2] /\ e2[2] = e3[2] /\ e3[2] = e4[2];   % right
constraint e1[3] = e2[3] /\ e2[3] = e3[3] /\ e3[3] = e4[3];   % back
constraint e1[4] = e2[4] /\ e2[4] = e3[4] /\ e3[4] = e4[4];   % left

constraint cube1 != cube2 /\ cube1 != cube3 /\ cube1 != cube4 /\
           cube2 != cube3 /\ cube2 != cube4 /\ cube3 != cube4;
           
% With Gecode 6.4.0 this takes 20 minutes. With Chuffed 0.14.9 its instantly
solve satisfy; 

% ============================================================
% Output
% ============================================================

% Builds one row of a tower table: cube name, its 4 side colors (front, right, back, left) and its state.
% format_justify_string(-7, ...) fills every color name with spaces until it has 7 characters, so the columns are aligned.

function string: row(string: name, array[1..4] of int: side, int: st) =
  name ++ concat([format_justify_string(-7, colors[side[k]]) | k in 1..4]) ++ "(state \(st))\n";

% First we print the colors the solver chose for the 4 cubes, as arrays in the order of the faces
% (top, front, right, down, back, left). Then we print the tower of the standard problem and the tower of the
% second problem.

output ["Cubes (top, front, right, down, back, left) with Red = 1, Blue = 2, Green = 3, White = 4:\n",
        "cube1 = \(cube1)\n",
        "cube2 = \(cube2)\n",
        "cube3 = \(cube3)\n",
        "cube4 = \(cube4)\n",
        "\nStandard problem (4 different colors on each side):\n",
        "        Front  Right  Back   Left\n",
        row("Cube 1  ", fix(s1), fix(state1)),
        row("Cube 2  ", fix(s2), fix(state2)),
        row("Cube 3  ", fix(s3), fix(state3)),
        row("Cube 4  ", fix(s4), fix(state4)),
        "\nSecond problem (one color on each side):\n",
        "        Front  Right  Back   Left\n",
        row("Cube 1  ", fix(e1), fix(stateEq1)),
        row("Cube 2  ", fix(e2), fix(stateEq2)),
        row("Cube 3  ", fix(e3), fix(stateEq3)),
        row("Cube 4  ", fix(e4), fix(stateEq4))];
        "        Front  Right  Back   Left\n",
        row("Cube 1  ", fix(e1), fix(stateEq1)),
        row("Cube 2  ", fix(e2), fix(stateEq2)),
        row("Cube 3  ", fix(e3), fix(stateEq3)),
        row("Cube 4  ", fix(e4), fix(stateEq4))];
