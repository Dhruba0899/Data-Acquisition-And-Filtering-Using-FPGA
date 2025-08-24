module spi_check(
    input wire sclk,          // Serial clock from master
    input wire cs_n,          // Chip select (active low)
    output reg miso           // Master In Slave Out data line
);
    reg [15:0] data_sequences [0:3];
    reg [1:0] seq_index;
    reg [3:0] bit_counter;
    initial begin
        data_sequences[0] = 16'h0555;  // ADC value 0x555 (1365 decimal)
        data_sequences[1] = 16'h07FF;  // ADC value 0x7FF (2047 decimal)
        data_sequences[2] = 16'h0AAA;  // ADC value 0xAAA (2730 decimal)
        data_sequences[3] = 16'h0FFF;  // ADC value 0xFFF (4095 decimal)        
        // Initialize other registers
        seq_index = 2'd0;
        bit_counter = 4'd0;
        miso = 1'b0;
    end
   
    always @(negedge cs_n or posedge cs_n) begin
        if (!cs_n) begin
            bit_counter <= 4'd0;
            miso <= data_sequences[seq_index][15];
        end else begin
            miso <= 1'b0;
            seq_index <= seq_index + 1;  
        end
    end
 
    always @(negedge sclk) begin
        if (!cs_n) begin 
            if (bit_counter < 15) begin
                bit_counter <= bit_counter + 1;
                miso <= data_sequences[seq_index][14 - bit_counter];
            end
        end
    end

endmodule