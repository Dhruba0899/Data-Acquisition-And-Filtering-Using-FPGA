# Data-Acquisition-And-Filtering-Using-FPGA

Interfaced PMOD light and pressure sensors with a Zynq-7000 series FPGA via the SPI protocol and designed a Kalman Filter and Median Filter using Verilog on Xilinx Vivado to filter noise from sensor data. Utilized a Virtual I/O module to compare filtered vs raw sensor data.

----

# Kalman Filter 

<img width="604" height="471" alt="image" src="https://github.com/user-attachments/assets/fda7b6cc-c227-45f6-88c2-0cacb236129c" />


- The designed Kalman filter is a one dimensional scalar filter used to filter 8-bit input data from the PMOD ALS.
- The filter is based on two steps, a prediction step and a correction step. We first predict a value of the output and calculate the difference between it and the actual light data scaling it by the Kalman gain to calculate  the final output.
- The values of Q (process noise) and R (measurement noise ) tell the filter how much it should trust the prediction vs the sensor measurement.
- Based on the error between the prediction and the sensor data the Kalman gain and covariance are set and the output is corrected.




# Simulation Waveform (with SPI)

<img width="1063" height="219" alt="image" src="https://github.com/user-attachments/assets/40dba515-97ad-4900-a8c9-96b1bc9d0c6c" />

- The filter makes an initial guess of 70. It is interfaced with the SPI communication protocol design with a simulated stream of inputs.
- The filter waits till it gets the data valid signal from the SPI code to process the input which is given after 16 clock cycles of the SPI sclk when it has the input ready.
- We see that initially the filter has a large error but it quickly converges and starts to match the light data. It smoothens out large spikes and variations while maintaining responsiveness.

# Filter Response (Graphed) 

<img width="1025" height="530" alt="image" src="https://github.com/user-attachments/assets/bd6f6088-ae4a-4da0-b432-cf6fbe01d6c9" />

---

# Median Filter 

<img width="936" height="543" alt="image" src="https://github.com/user-attachments/assets/42441fc2-e3f1-4620-a825-6dd319418096" />

- The designed Median Filter is a 3 point median filter that takes the median of the past 3 11-bit inputs of a PMOD DPG sensor using the SPI communication protocol.
- Upon reset the filter window is loaded with all zeros. after 3 valid inputs we see the filter respond.
- A lower order of window size (3) is chosen to avoid the need for a complex sorting algorithm at the expense of some performance.
- The filter waits till the data valid signal provided by the SPI program goes high before processing the input. the SPI has a valid data at every 16 clock cyles (sclk of the SPI) and the filter requires at least 3 such inputs before it can start responding.

# Simulation Waveform (with SPI)

<img width="1076" height="203" alt="image" src="https://github.com/user-attachments/assets/27d82709-b8b2-4dc2-8abd-0e553e52574a" />

- The filter is connected to the SPI communication protocol code and simulated with test data to check its response.
- The filter is initially loaded with all zeroes we see that it only starts to respond after 3 valid inputs from the SPI communication protocol.
- The filter waits till it gets the data valid signal from the SPI code to process the input which is given after 16 clock cycles of the SPI sclk when it has the input ready.











