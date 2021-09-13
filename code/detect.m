clear all;close all;clc;
Z=double(imread('watermarked.bmp'));            %读取篡改图像
[Mc,Nc]=size(Z);                                %获取图像边长512*512
blocksize=8;                                    %设置图像块边长为8
c=Mc/blocksize; d=Nc/blocksize; m=c*d;          %获取8*8的图像块数 每行每列各64个图像块 共m=4096个图像块
B=[1 0 1 0 1 1 0 1;                             %嵌入信息的位置矩阵
   1 0 1 0 1 0 1 1;
   0 1 1 0 0 0 0 0;
   0 1 0 1 1 1 0 0;
   0 1 0 0 0 1 0 0;
   1 0 0 1 1 1 1 1;
   0 1 1 1 0 0 1 0;
   1 0 1 1 1 1 1 0];
ZM=floor(Z/2)*2;                                %将篡改图像的LSB平面清0，保存为ZM
ZX=Z-ZM;                                        %用篡改图像Z，减去LSB清零后的图像ZM，得到LSB平面的信息ZX
x=1; y=1;                                       %最左上角的图像块开始
for kk=1:m                                      %遍历4096个图像块
    [s,u,v]=svd(ZM(y:y+blocksize-1,x:x+blocksize-1));%奇异值分解
    tra=floor(trace(abs(u)));                   %计算信息矩阵u的迹
    k=0; tra1=0; trae=tra;                      %用于检测的变量初始化，tra1为计算LSB平面复原出的矩阵信息，trae为计算得到的图像块的信息
    for ii=1:blocksize                          %遍历每个图像块中的行
        for jj=1:blocksize                      %遍历每个图像块中的列
            if B(ii,jj)==1&&trae~=0             %判断位置矩阵是否为1，迹是否为0
                tra1=ZX(y+ii-1,x+jj-1)*2^k+tra1;%计算LSB平面复原出的矩阵信息
                k=k+1;                          %用于复原LSB平面信息的左移
                trae=floor(trae/2);             %与插入时相同，对矩阵u的迹做右移操作
            end
        end
    end
    if tra1~=tra                                %如果计算得到的信息与从LSB平面复原出的信息不同
        Z(y:y+blocksize-1,x:x+blocksize-1)=1;   %说明这个图像块之前没插入过水印(没记录信息)，判定为篡改设为黑色
    end
    if x+blocksize>=Nc                          %如果到某一行的尽头了
        x=1;y=y+blocksize;                      %则换下一行，列数x置1，行数y+8(一个图像块的距离)
    else                                        %如果这行还没结束
        x=x+blocksize;                          %则列数x+8进入这一行的下一个图像块
    end
end
Z=uint8(Z); imshow(Z,[],'border','tight');      %显示利用水印的拼接篡改检测结果