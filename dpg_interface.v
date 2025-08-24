module dpg_interface (
    input wire clk,              // System clock
    input wire rst,              // Reset signal (active high)
    input wire start_conv,       // Start conversion signal
    input wire miso,             // SPI MISO (data from PmodDPG1)
    output reg sclk,             // SPI clock
    output reg cs_n,             // Chip select (active low)
    output reg [11:0] adc_data,  // 12-bit ADC data
    output reg data_valid        // Data valid signal
);    
    localparam IDLE = 2'b00;
    localparam CONVERT = 2'b01;
    localparam FINISH = 2'b10;    
    localparam SCLK_DIV = 50;    // for clk frequency = 2MHz   
    reg [1:0] state;
    reg [4:0] bit_counter;
    reg [15:0] shift_reg;
    reg [7:0] sclk_counter;
    reg sclk_enable;
    // SCLK generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk_counter <= 0;
            sclk <= 0;          // CPOL = 0, start with SCLK low
        end else if (sclk_enable) begin
            if (sclk_counter == SCLK_DIV - 1) begin
                sclk <= ~sclk;  // Toggle SCLK
                sclk_counter <= 0;
            end else begin
                sclk_counter <= sclk_counter + 1;
            end
        end else begin
            sclk <= 0;         // Return to idle state (SCLK low)
            sclk_counter <= 0;
        end
    end
    
    // SPI logic 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            cs_n <= 1;          // Deselect chip
            bit_counter <= 0;
            shift_reg <= 0;
            adc_data <= 0;
            data_valid <= 0;
            sclk_enable <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (start_conv) begin
                        state <= CONVERT;
                        cs_n <= 0;          // Select chip to start conversion
                        bit_counter <= 0;
                        shift_reg <= 0;
                        sclk_enable <= 1;   // Enable SCLK generation
                    end else begin
                        cs_n <= 1;          // Keep chip deselected when idle
                    end
                end
                
                CONVERT: begin
                    // Sample MISO on rising edge of SCLK (CPHA = 0)
                    if (sclk_counter == SCLK_DIV - 1 && sclk == 0) begin  // Just before SCLK rises
                        shift_reg <= {shift_reg[14:0], miso};  // Shift in new bit
                        
                        if (bit_counter == 15) begin  // Received all 16 bits
                            state <= FINISH;
                            sclk_enable <= 0;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end
                end
                
                FINISH: begin
                    cs_n <= 1;  // Deselect chip                    
                    // Extract the 12 data bits (bits 11 to 0) from the frame
                    // Format: 4 leading zeros, 12 data bits
                    adc_data <= shift_reg[11:0];                    
                    data_valid <= 1;
                    state <= IDLE;
                end                
                default: state <= IDLE;
            endcase
        end
    end

endmodule