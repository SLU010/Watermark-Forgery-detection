clear all;close all;clc;
h=rgb2hsi(imread('Lena.tif'));                  %��ȡͼ��ת��ΪHSIģ��
figure;imshow(h(:,:,3),[],'border','tight');
Z=double(im2uint8(h(:,:,3)));                   %ѡ��ǿ�ȷ�����ת����������
[Mc,Nc]=size(Z);                                %��ȡͼ��߳�512*512
blocksize=8;                                    %����ͼ���߳�Ϊ8
c=Mc/blocksize; d=Nc/blocksize; m=c*d;          %��ȡ8*8��ͼ����� ÿ��ÿ�и�64��ͼ��� ��m=4096��ͼ���
B=[1 0 1 0 1 1 0 1;                             %Ƕ����Ϣ��λ�þ���
   1 0 1 0 1 0 1 1;
   0 1 1 0 0 0 0 0;
   0 1 0 1 1 1 0 0;
   0 1 0 0 0 1 0 0;
   1 0 0 1 1 1 1 1;
   0 1 1 1 0 0 1 0;
   1 0 1 1 1 1 1 0];
ZM=floor(Z/2)*2;                                %LSB(�����Чλ)ƽ������
x=1; y=1;                                       %�����Ͻǵ�һ��ͼ��鿪ʼ
for kk=1:m                                      %����4096��ͼ���
    [s,u,v]=svd(ZM(y:y+blocksize-1,x:x+blocksize-1));%����ֵ�ֽ�
    tra=floor(trace(abs(u)));                   %������Ϣ����u�ļ���ΪǶ���ˮӡ��Ϣ
    for ii=1:blocksize                          %����ÿ��ͼ����е���
        for jj=1:blocksize                      %����ÿ��ͼ����е���
            if B(ii,jj)==1&&tra~=0              %�ж�λ�þ����Ƿ�Ϊ1�����Ƿ�Ϊ0
                ZM(y+ii-1,x+jj-1)=ZM(y+ii-1,x+jj-1)+mod(tra,2);%��������LSBƽ�������Ϣ
                tra=floor(tra/2);               %�Ծ���u�ļ������Ʋ�����׼����һ�ε���Ϣ����
            end
        end
    end
    if x+blocksize>=Nc                          %�����ĳһ�еľ�ͷ��
        x=1;y=y+blocksize;                      %����һ�У�����x��1������y+8(һ��ͼ���ľ���)
    else                                        %������л�û����
        x=x+blocksize;                          %������x+8������һ�е���һ��ͼ���
    end
end                                   
apple=double(rgb2gray(imread('apple.jpg')));    %��ȡ��һ��ͼ������ƴ�Ӵ۸�
p=60; q=80;                                     %���øò���ͼ��Ĵ�С��������ԭͼ��Ĵ�С
apple=imresize(apple,[p,q]);                    %�������ã��ı����ͼ��Ĵ�С
ZM(65:65+p-1,209:209+q-1)=apple;                %����ͼ����ɴ۸�
ZA=uint8(ZM); figure; imshow(ZA,[],'border','tight');   %��ʾ�۸ĺ��ͼ��
imwrite(ZA,'watermarked.bmp','bmp');            %����۸ĺ��ͼ��