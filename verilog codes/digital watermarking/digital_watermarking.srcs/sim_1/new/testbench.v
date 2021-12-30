`timescale 1ps / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2020 12:53:13 PM
// Design Name: 
// Module Name: final
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


module testbench;
    parameter n=64;                                 // n denotes the dimension nxn of the image
    integer i,j;
    integer file1, file2, file3, file4, file5;
    reg [7:0] image [0:n*n-1];                      // image_data.txt is read into the 1D array 'image' 
    reg [7:0] watermarkdata [0:n*n-1];              // watermark_data.txt is read into the 1D array 'watermarkdata' 
    reg [15:0] image2d [0:n-1][0:n-1];              // 2D matrix of the 1D array 'image'
    reg [15:0] watermark2d [0:n-1][0:n-1];          // 2D matrix of the 1D array 'watermarkdata'
    reg clk,en1,en2,en3,en4,en5,en6;
    wire [15:0] DCT [0:n-1][0:n-1];
    wire [15:0] embedd [0:n-1][0:n-1];
    wire [15:0] IDCT [0:n-1][0:n-1];
    wire [15:0] gaussian [0:n-1][0:n-1];
    wire [15:0] extract [0:n-1][0:n-1];
    wire [15:0] watermark [0:n-1][0:n-1];

dct testbench(clk,en1,en2,en3,en4,en5,en6,image2d,watermark2d,DCT,embedd,IDCT,gaussian,extract,watermark);

initial clk = 0;
always #1 clk = ~clk;
    
initial begin
    file1 = $fopen("image_dct.txt", "a");    
    file2 = $fopen("watermarked_image.txt", "a");
    file3 = $fopen("noised_watermarked_image.txt", "a");
    file4 = $fopen("noised_extracted_watermark.txt", "a");
end

initial begin
    en1 = 0;
    
    $readmemh("image_data.txt", image);                //Read image_data text file into the 1d array 'image'
    $readmemh("watermark_data.txt", watermarkdata);    //Read watermark_data text file into the 1d array 'watermarkdata'  
    
    for (i=0; i<n; i=i+1) begin
        for (j=0; j<n; j=j+1) begin
            image2d[i][j] = image[n*i+j];               //The 1d array image is written into 2d array image2d
            watermark2d[i][j] = watermarkdata[n*i+j];   //The 1d array watermarkdata is written into 2d array watermark2d
        end
    end
    
    en1 = 1;

    #5;
    en1 = 0;
    en2 = 1;
    
    #5;
    en2 = 0;
    en3 = 1;
    
    #5;
    en3 = 0;
    en4 = 1;
    
    #5;
    en4 = 0;
    en5 = 1;
    
    #5;
    en5 = 0;
    en6 = 1;
    
    #5;
    en6 = 0;
    
////// Write the embedded matrix into fd (dct_file) //////
    for (i=0; i<n; i=i+1) begin
        for (j=0; j<n; j=j+1) begin
            $fwrite(file1, "%x\n", DCT[i][j]);         // Write DCT matrix into file1
            $fwrite(file2, "%x\n", IDCT[i][j]);        // Write IDCT matrix into file2
            $fwrite(file3, "%x\n", gaussian[i][j]);    // Write gaussian matrix into file3
            $fwrite(file4, "%x\n", watermark[i][j]);   // Write watermark matrix into file4
        end
    end
    
    $fclose(file1);
    $fclose(file2);
    $fclose(file3);
    $fclose(file4);
    $finish;
    
    end
endmodule