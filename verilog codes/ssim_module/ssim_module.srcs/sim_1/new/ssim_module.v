`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2020 05:58:40 AM
// Design Name: 
// Module Name: ssim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ssim;
    parameter n=64;
    integer i,j;
    real image1 [0:n-1][0:n-1];
    real image2 [0:n-1][0:n-1];
    reg [15:0] memory1 [0:n*n-1];
    reg [15:0] memory2 [0:n*n-1];
    real mem1 [0:n*n-1];
    real mem2 [0:n*n-1];
    real mean1=0;
    real mean2=0;
    real variance1=0;
    real variance2=0;
    real covariance=0;
    real c1,c2;
    real k1=0.01;
    real k2=0.03;
    real L=255;
    real A,B,SSIM;

    initial begin
        $readmemh("watermark_data.txt",memory1);         //reading the original watermark data into array memory1
        $readmemh("extractedwatermark.txt",memory2);   //reading the extracted watermary into the array memory2
        
        for (i=0; i<n*n; i=i+1) begin
            mem1[i] = memory1[i] + 16'b1000000000000000;
            mem2[i] = memory2[i] + 16'b1000000000000000;
        end
        
        for(i=0;i<n;i=i+1) begin
            for(j=0;j<n;j=j+1)begin
                image1[i][j] = mem1[i*n+j] - 16'b1000000000000000;
                image2[i][j] = mem2[i*n+j] - 16'b1000000000000000;
            end
        end
        
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin              
                mean1 = mean1 + image1[i][j];
                mean2 = mean2 + image2[i][j];
            end
        end
        
        mean1 = mean1/(n*n);
        mean2 = mean2/(n*n);
        
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin              
                variance1 = variance1 + (image1[i][j] - mean1)*(image1[i][j] - mean1);
                variance2 = variance2 + (image2[i][j] - mean2)*(image2[i][j] - mean2);
                covariance = covariance + (image1[i][j] - mean1)*(image2[i][j] - mean2);
             end
        end
        
        variance1 = variance1/(n*n - 1);
        variance2 = variance2/(n*n - 1);
        covariance = covariance/(n*n - 1);    
        
        c1 = (k1*L)*(k1*L);
        c2 = (k2*L)*(k2*L);
        
        A = (2*mean1*mean2 + c1)*(2*covariance + c2);
        B = (mean1*mean1 + mean2*mean2 + c1)*(variance1 + variance2 + c2);
        
        SSIM = A/B;
      
    end
endmodule