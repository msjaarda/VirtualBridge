clear
clc
close all
format long g

filename = 'CH289_20190503.log';

rd = importCOUNTLOGfilexx(filename, 2, 100000);

rd.Speed(isnan(rd.Speed)) = 50;
rd.Time = rd.h + rd.m/60 + rd.s/3600 + rd.ms/360000;

save(filename(1:end-4),'rd')