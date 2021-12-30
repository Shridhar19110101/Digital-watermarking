ID = fopen('extracted_watermark.txt');
AA1 = textscan(ID, '%s');
fclose(ID);
BB1=char(AA1{1,1});
mm=typecast(uint16(hex2dec(BB1)),'int16');
for i=1:64
    for j=1:64
        mm1(i,j)=mm(64*(i-1)+j,1);
    end
end
mm1=double(mm1);
imshow(mm1);
imsave;