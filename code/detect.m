clear all;close all;clc;
Z=double(imread('watermarked.bmp'));            %��ȡ�۸�ͼ��
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
ZM=floor(Z/2)*2;                                %���۸�ͼ���LSBƽ����0������ΪZM
ZX=Z-ZM;                                        %�ô۸�ͼ��Z����ȥLSB������ͼ��ZM���õ�LSBƽ�����ϢZX
x=1; y=1;                                       %�����Ͻǵ�ͼ��鿪ʼ
for kk=1:m                                      %����4096��ͼ���
    [s,u,v]=svd(ZM(y:y+blocksize-1,x:x+blocksize-1));%����ֵ�ֽ�
    tra=floor(trace(abs(u)));                   %������Ϣ����u�ļ�
    k=0; tra1=0; trae=tra;                      %���ڼ��ı�����ʼ����tra1Ϊ����LSBƽ�渴ԭ���ľ�����Ϣ��traeΪ����õ���ͼ������Ϣ
    for ii=1:blocksize                          %����ÿ��ͼ����е���
        for jj=1:blocksize                      %����ÿ��ͼ����е���
            if B(ii,jj)==1&&trae~=0             %�ж�λ�þ����Ƿ�Ϊ1�����Ƿ�Ϊ0
                tra1=ZX(y+ii-1,x+jj-1)*2^k+tra1;%����LSBƽ�渴ԭ���ľ�����Ϣ
                k=k+1;                          %���ڸ�ԭLSBƽ����Ϣ������
                trae=floor(trae/2);             %�����ʱ��ͬ���Ծ���u�ļ������Ʋ���
            end
        end
    end
    if tra1~=tra                                %�������õ�����Ϣ���LSBƽ�渴ԭ������Ϣ��ͬ
        Z(y:y+blocksize-1,x:x+blocksize-1)=1;   %˵�����ͼ���֮ǰû�����ˮӡ(û��¼��Ϣ)���ж�Ϊ�۸���Ϊ��ɫ
    end
    if x+blocksize>=Nc                          %�����ĳһ�еľ�ͷ��
        x=1;y=y+blocksize;                      %����һ�У�����x��1������y+8(һ��ͼ���ľ���)
    else                                        %������л�û����
        x=x+blocksize;                          %������x+8������һ�е���һ��ͼ���
    end
end
Z=uint8(Z); imshow(Z,[],'border','tight');      %��ʾ����ˮӡ��ƴ�Ӵ۸ļ����