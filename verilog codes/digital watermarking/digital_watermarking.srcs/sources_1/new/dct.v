`timescale 1ps / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2020 10:18:22 AM
// Design Name: 
// Module Name: noised
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


module dct(clk,en1,en2,en3,en4,en5,en6,lenna2d,watermark2d,DCT,embedd,IDCT,gaussian,extract,watermark);
    parameter n=64; 
    input clk,en1,en2,en3,en4,en5,en6;
    input [15:0] watermark2d [0:n-1][0:n-1];
    input [15:0] lenna2d [0:n-1][0:n-1];
    output reg [15:0] DCT [0:n-1][0:n-1];
    output reg [15:0] embedd [0:n-1][0:n-1];
    output reg [15:0] IDCT [0:n-1][0:n-1];
    output reg [15:0] gaussian [0:n-1][0:n-1];
    output reg [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    integer i,j,x,y;
    real temp = 0.0;
    real pi = 3.141592653589793;
    
    always@(posedge clk && en1) begin
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                temp = 0.0;
                for (x=0; x<n; x=x+1) begin
                    for (y=0; y<n; y=y+1) begin
                        // temp stores the summation part of the dct formula
                        temp = temp + ($cos(((2*y+1)*j*pi)/(2*n)) * $cos(((2*x+1)*i*pi)/(2*n))* lenna2d[x][y]);
                    end
                end
                // Multiply the final summation(temp) with appropriate coefficients
                if (i==0 && j==0)begin
                    temp = temp/n;
                end
                if ((i==0 && j!=0) || (i!=0 && j==0))begin
                    temp = temp*($sqrt(2)/n);
                end
                if (i!=0 && j!=0)begin
                    temp = (2*temp)/n;
                end
                // assign temp to DCT[i][j]
                DCT[i][j] = temp;
            end
        end
    end
    embedd B1(clk,en2,en3,en4,en5,en6,DCT,watermark2d,embedd,IDCT,gaussian,extract,watermark);   // Call embedd module with nested inputs and outputs
endmodule

module embedd(clk,en2,en3,en4,en5,en6,DCT,watermark2d,embedd,IDCT,gaussian,extract,watermark);
    parameter n=64;
    input clk,en2,en3,en4,en5,en6;
    input [15:0] DCT [0:n-1][0:n-1];
    input [15:0] watermark2d [0:n-1][0:n-1];
    output reg [15:0] embedd [0:n-1][0:n-1];
    output reg [15:0] IDCT [0:n-1][0:n-1];
    output reg [15:0] gaussian [0:n-1][0:n-1];
    output reg [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    parameter g = 10;
    integer i,j;
    
    always@(posedge clk && en2)  begin
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                // adding watermark's data onto the dct file
                // g=10 is the 'visibility factor'
                embedd[i][j] = DCT[i][j] + g*watermark2d[i][j];
            end
        end
    end
    idct B2(clk,en3,en4,en5,en6,DCT,embedd,IDCT,gaussian,extract,watermark);     // Call idct module with nested inputs and outputs
endmodule

module idct(clk,en3,en4,en5,en6,DCT,embedd,IDCT,gaussian,extract,watermark);
    parameter n=64;
    input clk,en3,en4,en5,en6;
    input [15:0] embedd [0:n-1][0:n-1];
    input [15:0] DCT [0:n-1][0:n-1];
    output reg [15:0] IDCT [0:n-1][0:n-1];
    output reg [15:0] gaussian [0:n-1][0:n-1];
    output reg [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    real embedd_real [0:n-1][0:n-1];
    real temp = 0.0;
    real fin = 0.0;
    real pi = 3.141592653589793;
    parameter g=10;
    integer i,j,x,y;
    
    always@(posedge clk && en3) begin
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                // Restore negative values of the array 'embedd'
                // Store them in real type array 'embedd_real'
                embedd_real[i][j] = embedd[i][j] + 16'b1000000000000000;
                embedd_real[i][j] = embedd_real[i][j] - 16'b1000000000000000;
            end
        end
        
        for (x = 0; x < n; x=x+1) begin
            for (y = 0; y < n; y=y+1) begin
                fin = 0.0;
                for (i = 0; i < n; i=i+1) begin
                    for (j = 0; j < n; j=j+1) begin
                        // temp stores the summation part of the idct formula
                        temp = ($cos(((2*y+1)*j*pi)/(2*n)) * $cos(((2*x+1)*i*pi)/(2*n)) * embedd_real[i][j]);
                        // Multiply the final summation(temp) with appropriate coefficients
                        if (i==0 && j==0)begin
                            temp = temp/2;
                        end
                        if (i==0 && j!=0 || i!=0 && j==0) begin
                            temp = temp/$sqrt(2);
                        end
                        if (i!=0 && j!=0)begin
                            temp = temp;
                        end
                        fin = fin + temp;
                    end
                end
                fin = (fin*2)/n;
                // Assign fin to IDCT
                IDCT[x][y] = fin;
            end
        end
    end
    gaussian B3(clk,en4,en5,en6,DCT,IDCT,gaussian,extract,watermark);      // Call gaussian module with nested inputs and outputs
endmodule

module gaussian(clk,en4,en5,en6,DCT,IDCT,gaussian,extract,watermark);
    parameter n=64;
    input clk,en4,en5,en6;
    input [15:0] IDCT [0:n-1][0:n-1];
    input [15:0] DCT [0:n-1][0:n-1];
    output reg [15:0] gaussian [0:n-1][0:n-1];
    output reg [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    integer i,j;
    reg [15:0] a1,a2,a3,a4,a5,a6,a7,a8,a9;
    
    always@(posedge clk && en4) begin
        for (i=1; i<n-1; i=i+1) begin
            for (j=1; j<n-1; j=j+1) begin
                // Creating blocks of 3x3 to calculate the corresponding gaussian pixel
                a1 = IDCT[i-1][j-1];
                a2 = IDCT[i-1][j];
                a3 = IDCT[i-1][j+1];
                a4 = IDCT[i][j-1];
                a5 = IDCT[i][j];
                a6 = IDCT[i][j+1];
                a7 = IDCT[i+1][j-1];
                a8 = IDCT[i+1][j];
                a9 = IDCT[i+1][j+1];
                gaussian[i][j] = (1*a1 + 2*a2 + 1*a3 + 2*a4 + 4*a5 + 2*a6 + 1*a7 + 2*a8 + 1*a9)/16;           
            end
        end
        for (i=0; i<n; i=i+n-1) begin
            for (j=0; j<n; j=j+1) begin
                // Pixels over the boundary copied into gaussian without manipulation
                gaussian[i][j] = IDCT[i][j];
                gaussian[j][i] = IDCT[j][i];
            end
        end
    end
    extract B4(clk,en5,en6,DCT,gaussian,extract,watermark);          // Call extract module with nested inputs and outputs
endmodule

module extract(clk,en5,en6,DCT,gaussian,extract,watermark);
    parameter n=64;
    input clk,en5,en6;
    input [15:0] gaussian [0:n-1][0:n-1];
    input [15:0] DCT [0:n-1][0:n-1];
    output reg [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    real gaussian_real [0:n-1][0:n-1];
    integer i,j,x,y;
    real temp = 0.0;
    real pi = 3.141592653589793;
    
    always@(posedge clk && en5) begin
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                // Restore negative values of the array 'gaussian'
                // Store them in real type array 'gaussian_real'
                gaussian_real[i][j] = gaussian[i][j] + 16'b1000000000000000;
                gaussian_real[i][j] = gaussian_real[i][j] - 16'b1000000000000000;
            end
        end
        /// Apply dct on 'gaussian_real' and store into 'extract'
        for (i = 0; i < n; i=i+1) begin
            for (j = 0; j < n; j=j+1) begin
                temp = 0.0;
                for (x = 0; x < n; x=x+1) begin
                    for (y = 0; y < n; y=y+1) begin
                    // temp stores the summation part of the dct formula
                        temp = temp + ($cos(((2*y+1)*j*pi)/(2*n)) * $cos(((2*x+1)*i*pi)/(2*n)) * gaussian_real[x][y]);
                    end
                end
                // Multiply the final summation(temp) with appropriate coefficients
                if (i==0 && j==0)begin
                    temp = temp/n;
                end
                if (i==0 && j!=0 || i!=0 && j==0)begin
                    temp = temp*($sqrt(2)/n);
                end
                if (i!=0 && j!=0)begin
                    temp = (2*temp)/n;
                end
                // assign temp to extract[i][j]
                extract[i][j] = temp;
            end
        end
    end
    watermark B5(clk,en6,DCT,extract,watermark);      // Call watermark module with nested inputs and outputs
endmodule

module watermark(clk,en6,DCT,extract,watermark);
    parameter n=64;
    input clk, en6;
    input [15:0] DCT [0:n-1][0:n-1];
    input [15:0] extract [0:n-1][0:n-1];
    output reg [15:0] watermark [0:n-1][0:n-1];
    real DCT_real [0:n-1][0:n-1];
    real extract_real [0:n-1][0:n-1];
    real fin = 0.0;
    integer i,j;
    parameter g = 10;
    
    always@(posedge clk && en6) begin
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                // Restore negative values of the array 'extract'
                // Store them in real type array 'extract_real'
                extract_real[i][j] = extract[i][j] + 16'b1000000000000000;
                extract_real[i][j] = extract_real[i][j] - 16'b1000000000000000;
            end
        end
        
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                // Restore negative values of the array 'DCT'
                // Store them in real type array 'DCT_real'
                DCT_real[i][j] = DCT[i][j] + 16'b1000000000000000;
                DCT_real[i][j] = DCT_real[i][j] - 16'b1000000000000000;
            end
        end
        
        for (i=0; i<n; i=i+1) begin
            for (j=0; j<n; j=j+1) begin
                fin = (extract_real[i][j] - DCT_real[i][j])/g;
                watermark[i][j] = fin;
            end
        end
    end
 endmodule
    