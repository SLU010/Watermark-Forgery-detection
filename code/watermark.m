clear all;close all;clc;
h=rgb2hsi(imread('Lena.tif'));                  %读取图像转换为HSI模型
figure;imshow(h(:,:,3),[],'border','tight');
Z=double(im2uint8(h(:,:,3)));                   %选择强度分量，转换数据类型
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
ZM=floor(Z/2)*2;                                %LSB(最低有效位)平面清零
x=1; y=1;                                       %从左上角第一个图像块开始
for kk=1:m                                      %遍历4096个图像块
    [s,u,v]=svd(ZM(y:y+blocksize-1,x:x+blocksize-1));%奇异值分解
    tra=floor(trace(abs(u)));                   %计算信息矩阵u的迹作为嵌入的水印信息
    for ii=1:blocksize                          %遍历每个图像块中的行
        for jj=1:blocksize                      %遍历每个图像块中的列
            if B(ii,jj)==1&&tra~=0              %判断位置矩阵是否为1，迹是否为0
                ZM(y+ii-1,x+jj-1)=ZM(y+ii-1,x+jj-1)+mod(tra,2);%满足则在LSB平面插入信息
                tra=floor(tra/2);               %对矩阵u的迹做右移操作，准备下一次的信息插入
            end
        end
    end
    if x+blocksize>=Nc                          %如果到某一行的尽头了
        x=1;y=y+blocksize;                      %则换下一行，列数x置1，行数y+8(一个图像块的距离)
    else                                        %如果这行还没结束
        x=x+blocksize;                          %则列数x+8进入这一行的下一个图像块
    end
end                                   
apple=double(rgb2gray(imread('apple.jpg')));    %读取另一张图像用于拼接篡改
p=60; q=80;                                     %设置该插入图像的大小，不超过原图像的大小
apple=imresize(apple,[p,q]);                    %根据设置，改变插入图像的大小
ZM(65:65+p-1,209:209+q-1)=apple;                %插入图像，完成篡改
ZA=uint8(ZM); figure; imshow(ZA,[],'border','tight');   %显示篡改后的图像
imwrite(ZA,'watermarked.bmp','bmp');            %保存篡改后的图像