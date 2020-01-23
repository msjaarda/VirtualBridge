% Take in single and double beta curve variables and generate trucks and
% wheelbase distances.

clear
clc
close all
format long g

% INPUT -----------

P = [0.345 0.655];
A = [86 35];
B = [419 600];
a = [32.228 5.185];
b = [4.918 8.848];
n = 200000;

Tab = rand(n,1);
y = Tab < P(1);
x = Tab >= P(1);
Tab(y) = (A(1) + betarnd(a(1),b(1),length(Tab(y)),1)*(B(1)-A(1)));
Tab(x) = (A(2) + betarnd(a(2),b(2),length(Tab(x)),1)*(B(2)-A(2)));

range = 30:10:620;

histogram(Tab,'Normalization','Probability');