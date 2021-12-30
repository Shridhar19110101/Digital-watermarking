x=(imread('Lenna.bmp'));
x=double(x);
imshow(x/255);

y=x;

wt=imread('watermark.bmp');
wt=double(wt);
wtm=wt;
figure,imshow(wtm);

a=zeros(64,64);
for i=1:1:64
    for j=1:64
        a(i,j)=wtm(i,j);
    end
end
save m.dat a -ascii


dx=dct2(x); dx11=dx;


load m.dat

g=10;
[rm,cm]=size(m);

dx(1:rm,1:cm)=dx(1:rm,1:cm)+g*m;


y=idct2(dx);

figure; imshow(y/255);
z=y;
[r,c,s]=size(z);

dy1=dct2(y);


y=z;
dy1(1:rm,1:cm)=(dy1(1:rm,1:cm)-dx11(1:rm,1:cm))/g;
figure,imshow(dy1);
