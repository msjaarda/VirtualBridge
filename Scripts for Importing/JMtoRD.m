clear, clc

load('A16Data.mat')

RD = table();

RD.ZST = ones(height(JM),1);

RD.JJJJMMTT = JM.Year*10000+JM.Month*100+JM.Day;

RD.T = zeros(height(JM),1);

RD.ST = zeros(height(JM),1);

RD.HHMMSS = JM.Hour*10000+JM.Min*100+floor(JM.Sec);

RD.FZG_NR =  zeros(height(JM),1);

RD.FS = JM.Lane - 1;

RD.SPEED = JM.Speedkph*100;

RD.LENTH = JM.Lenthcm;

RD.CS =  zeros(height(JM),1);

RD.CSF = JM.Type;

RD.GW_TOT = JM.WgtkN*102;

X = JM{:,13:27} > 0;

RD.AX = sum(X,2);

RD.AWT01 = JM{:,13}*102;
RD.AWT02 = JM{:,14}*102;
RD.AWT03 = JM{:,15}*102;
RD.AWT04 = JM{:,16}*102;
RD.AWT05 = JM{:,17}*102;
RD.AWT06 = JM{:,18}*102;
RD.AWT07 = JM{:,19}*102;
RD.AWT08 = JM{:,20}*102;
RD.AWT09 = JM{:,21}*102;
RD.AWT10 = JM{:,22}*102;


RD.W1_2 = JM{:,28};
RD.W2_3 = JM{:,29};
RD.W3_4 = JM{:,30};
RD.W4_5 = JM{:,31};
RD.W5_6 = JM{:,32};
RD.W6_7 = JM{:,33};
RD.W7_8 = JM{:,34};
RD.W8_9 = JM{:,35};
RD.W9_10 = JM{:,36};

RD.HH = string(round(100*(JM.Sec - floor(JM.Sec))));
RD.Head = JM.SeqNum;





