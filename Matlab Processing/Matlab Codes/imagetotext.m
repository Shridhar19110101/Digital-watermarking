x=(imread('Lenna.bmp'));
x=double(x);
g=fopen("image_data.txt","wt");
for i=1:64
    for j=1:64
        fprintf(g, '%x\n', x(i,j));
    end
end
fclose(g);