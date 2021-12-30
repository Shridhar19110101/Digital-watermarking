`timescale 1ps / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2020 10:54:39 AM
// Design Name: 
// Module Name: psnr_tb
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

// INPUT: finallenna.txt and gaussianfilter.txt
// OUTPUT: numeric value of psnr
module psnr_tb;
    parameter n=64;
    reg [7:0] a,b;
    reg clk;
    wire [15:0] out;
    integer i;
    integer j;
    integer file;
    real mse=0.0;
    real R=255*255; // R=(2^n - 1)^2, n=8 (number of bits in a,b)
    real S;
    real psnr;
    reg [7:0] memory1 [0:n*n-1];
    reg [7:0] memory2 [0:n*n-1];
    reg [7:0] array1 [0:n-1][0:n-1];
    reg [7:0] array2 [0:n-1][0:n-1];
    
    psnr psnr_tb(a,b,out,clk);
    
    initial clk = 1;
    always #1 clk = ~clk;
        
    initial begin
        //reading two text files (original watermarked and noised) that should be compared
        $readmemh("watermarked_image.txt",memory1);
        $readmemh("noised_watermarked_image.txt",memory2);
         
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                //generating 2D arrays array1 and array2 corresponding to the 1D arrays
                array1[i][j] = memory1[n*i+j];
                array2[i][j] = memory2[n*i+j];
            end
        end
        
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                //assigning values to the inputs of psnr module
                a = array1[i][j];
                b = array2[i][j];
                #2
                //Summation - Mean Square Error(mse)
                //Adding output from psnr module to mse at each step
                mse = mse + out;
            end
        end
        
        mse = mse/(n*n);  //since 128x128 image
        S = R/mse;
        psnr = 10*($log10(S));   // psnr = 10log(R/mse), where R=(2^n - 1)^2)
        
    end
    
endmodule
