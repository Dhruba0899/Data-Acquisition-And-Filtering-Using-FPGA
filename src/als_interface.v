module als_interface (
    input wire clk,          
    input wire reset,       
    input wire start_conv,   // Signal to start a new conversion
    input wire miso,         // Master In Slave Out (data from PmodALS)
    output reg cs_n,         // Chip Select (active low)
    output reg sclk,         // Serial Clock that goes to pmod
    output reg [7:0] light_data, // 8-bit light sensor data
    output reg data_valid    // Indicates when new data is available
);
    localparam IDLE = 2'b00;
    localparam CONVERT = 2'b01;
    localparam FINISH = 2'b10;
    localparam SCLK_DIV = 25; //change value for clk frequency change; for als sck must be between 1-4MHz    
    // Registers
    reg [4:0] bit_counter;   // Counter for bits received (0-15)
    reg [1:0] state;         // State machine
    reg [15:0] shift_reg;    // Shift register for incoming data
    reg [7:0] sclk_counter;  // Counter for SCLK generation
    reg sclk_enable;         // Enable SCLK generation    
    // SCLK generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_counter <= 0;
            sclk <= 0;
        end else if (sclk_enable) begin
            if (sclk_counter == SCLK_DIV - 1) begin
                sclk <= ~sclk;
                sclk_counter <= 0;
            end else begin
                sclk_counter <= sclk_counter + 1;
            end
        end else begin
            sclk <= 0;
            sclk_counter <= 0;
        end
    end
        // Main SPI logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cs_n <= 1;
            bit_counter <= 0;
            shift_reg <= 0;
            light_data <= 0;
            data_valid <= 0;
            sclk_enable <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (start_conv) begin
                        state <= CONVERT;
                        cs_n <= 0;           // Assert CS_n to start conversion
                        bit_counter <= 0;     // Reset bit counter
                        shift_reg <= 0;       // Clear shift register
                        sclk_enable <= 1;     // Enable SCLK generation
                    end else begin
                        cs_n <= 1;            // Keep CS_n high when idle
                        sclk_enable <= 0;     // Disable SCLK
                    end
                end
                
                CONVERT: begin
                    if (sclk_counter == SCLK_DIV - 1 && sclk == 0) begin  // Just before SCLK rises; 
                    //PmodALS places data bits "on the falling edge of the SCLK and valid on the subsequent rising edge of SCLK". 
                    //So we want to sample the MISO line at the rising edge when the data is valid.
                       
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
                    cs_n <= 1;  // Deassert CS_n                    
                    // Extract the 8 data bits (bits 12 to 5 of the 16-bit frame)
                    // Format: 3 leading zeros, 8 data bits (MSB first), 4 trailing zeros
                    light_data <= shift_reg[11:4];
                    data_valid <= 1;
                    state <= IDLE;
                end                
                default: state <= IDLE;
            endcase
        end
    end

endmodule