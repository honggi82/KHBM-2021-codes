% 22 channel EEG layout

function [position]=EEG_22ch_layout()

position=[
0.44 0.80  % ch 1
0.16 0.65  % ch 2
0.30 0.65  % ch 3
0.44 0.65  % ch 4
0.58 0.65  % ch 5
0.72 0.65  % ch 6
0.02 0.50  % ch 7
0.16 0.50  % ch 8
0.30 0.50  % ch 9
0.44 0.50  % ch 10
0.58 0.50  % ch 11
0.72 0.50  % ch 12
0.86 0.50  % ch 13
0.16 0.35  % ch 14
0.30 0.35  % ch 15
0.44 0.35  % ch 16
0.58 0.35  % ch 17
0.72 0.35  % ch 18
0.30 0.20  % ch 19
0.44 0.20  % ch 20
0.58 0.20  % ch 21
0.44 0.05  % ch 22
];

position(:,3)=0.12; % size of X-axis
position(:,4)=0.1; % size of Y-axis