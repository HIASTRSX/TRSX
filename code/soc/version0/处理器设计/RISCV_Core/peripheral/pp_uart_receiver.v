
module pp_uart_receiver (  // system connections
        rst,
        clk,
        soft_rst,
        uart_clk,
        // uart
        uart_dataH,

        //
        rec_dataH,
        rec_readyH,
        
        data_flag,
        check_flag,
        parity_err
        );

//
// Receiver state definition
//
parameter   r_START   = 3'b001,
            r_CENTER  = 3'b010,
            r_WAIT    = 3'b011,
            r_SAMPLE  = 3'b100,
            r_STOP    = 3'b101;

 
//
// Common parameter Definition
//
parameter  LO     = 1'b0,
            HI    = 1'b1,    
             X    = 1'bx;

parameter   r_Fivebit   = 2'b00,
            r_Sixbit    = 2'b01,
            r_Seven     = 2'b10,
            r_Eight     = 2'b11;
      
parameter   r_Oddcheck  = 2'b01,
            r_Evencheck = 2'b10;
      
parameter   r_Tstopbit  = 1'b1,
            r_Ostopbit  = 1'b0; 
//parameter  WORD_LEN = 8;

// ******************************************
//
// PORT DEFINITIONS
//
// ******************************************
input        rst;  // async reset
input        clk;  // main clock must be 16 x Baud Rate
input        soft_rst;
input        uart_clk;
input        uart_dataH;  // goes to the UART pin

output    [7:0]rec_dataH;  // parallel received data
output         rec_readyH;  // when high, new data is ok to be read

input     [1:0]data_flag;    //00:5bits,01:6bits,10:7bits,11:8bits
input     [1:0]check_flag;   //00:without,01:odd,10:even,11:reserve
output reg[1:0]parity_err; //00:no error ,01:odd check error, 10: even check error

// ******************************************
//
// MEMORY ELEMENT DEFINITIONS
//
// ******************************************

reg    [2:0]next_state, state;
reg         rec_datH, rec_datSyncH;
reg    [3:0]bitCell_cntrH;
reg         cntr_resetH;
reg    [8:0]par_dataH;
reg         shiftH;
reg    [3:0]recd_bitCntrH;
reg         countH;
reg         rstCountH;
reg         rec_readyH;
reg         rec_readyInH;
reg     [3:0]WORD_LEN;  
reg         parity_bit;     
reg     [1:0]frame_bits;
reg     [1:0]parity_check;    


reg    [7:0]  rec_dataH;

always @(posedge clk or negedge rst)
if(!rst)begin
  frame_bits <=2'b11;
  parity_check <=2'b00;
end
else if(!soft_rst)begin
  frame_bits <=2'b11;
  parity_check <=2'b00;
end
else if(state ==r_START)begin
  frame_bits <= data_flag;
  parity_check <= check_flag;
end

//assign rec_dataH = par_dataH[7:0];
//par_dataH[8]:parity,par_dataH[7]MSB
always @(*)begin
  case(frame_bits)
    r_Fivebit: begin if(^parity_check) rec_dataH = {3'b0,par_dataH[7:3]};
           else rec_dataH = {3'b0,par_dataH[8:4]};
    end
    r_Sixbit : begin if(^parity_check) rec_dataH = {2'b0,par_dataH[7:2]};
           else rec_dataH = {2'b0,par_dataH[8:3]};
    end
    r_Seven  : begin if(^parity_check) rec_dataH = {1'b0,par_dataH[7:1]};
           else rec_dataH = {1'b0,par_dataH[8:2]};
    end
    r_Eight  : begin if(^parity_check) rec_dataH = par_dataH[7:0];
           else rec_dataH = par_dataH[8:1];
    end
  endcase
end

//word length
always @(posedge clk or negedge rst)
  if(~rst) WORD_LEN<= 4'h8;
  else if(!soft_rst)  WORD_LEN<= 4'h8;
  else if(state == r_START)begin
      case(frame_bits)
        r_Fivebit: begin if(^parity_check) WORD_LEN <= 4'h6;
               else WORD_LEN <= 4'h5; 
        end
        r_Sixbit : begin if(^parity_check) WORD_LEN <= 4'h7;
               else WORD_LEN <= 4'h6;
        end
        r_Seven  : begin if (^parity_check) WORD_LEN <= 4'h8;
               else WORD_LEN <= 4'h7;
        end
        r_Eight  : begin if (^parity_check) WORD_LEN <= 4'h9;
                   else WORD_LEN <= 4'h8;
        end
      endcase
  end

 // Parity bit 
always @(posedge clk or negedge rst)
  if (~rst) parity_bit <= 0;
  else if(!soft_rst)  parity_bit <= 0;
  else if(recd_bitCntrH == WORD_LEN)begin
      case(frame_bits)
        r_Fivebit: parity_bit <= ^rec_dataH[4:0];
        r_Sixbit : parity_bit <= ^rec_dataH[5:0];
        r_Seven  : parity_bit <= ^rec_dataH[6:0];
        r_Eight  : parity_bit <= ^rec_dataH;
      endcase
  end
  
always @(posedge clk or negedge rst)
  if(!rst) parity_err <= 2'b0;
  else if(!soft_rst)  parity_err <= 2'b0;
  else if(rec_readyH && (^parity_check))begin
    if(parity_check==2'b01 && parity_bit != ~par_dataH[8])//odd
      parity_err <= 2'b01;
    else if(parity_check==2'b10 && parity_bit != par_dataH[8])
      parity_err <= 2'b10;
    else
      parity_err <= 2'b0;
  end
  else
    parity_err <= 2'b0;
//
// synchronize the asynchrnous input
// to the system clock domain
// dual-rank
always @(posedge clk or negedge rst)
  if (~rst) begin
     rec_datSyncH <= 1;
     rec_datH     <= 1;
  end else begin
     rec_datSyncH <= uart_dataH;
     rec_datH     <= rec_datSyncH;
  end


// Bit-cell counter
always @(posedge clk or negedge rst)
  if (~rst) bitCell_cntrH <= 0;
  else if(!soft_rst)  bitCell_cntrH <= 0;
  else if (~uart_clk)   bitCell_cntrH <= bitCell_cntrH;   
  else if (cntr_resetH) bitCell_cntrH <= 0;
  else bitCell_cntrH <= bitCell_cntrH + 1'b1;


// Shifte Register to hold the incoming 
// serial data
// LSB is shifted in first
//
always @(posedge clk or negedge rst)
  if (~rst) par_dataH <= 0; 
  else if(!soft_rst) par_dataH <= 0; 
  else if(shiftH) begin
     par_dataH[7:0] <= par_dataH[8:1];
     par_dataH[8]   <= rec_datH;
  end


// RECEIVED BIT Counter
// This coutner keeps track of the number of
// bits received
always @(posedge clk or negedge rst)
  if (~rst) recd_bitCntrH <= 0;
  else if(!soft_rst) recd_bitCntrH <= 0;
  else if (~uart_clk)   recd_bitCntrH <= recd_bitCntrH; 
  else if (countH) recd_bitCntrH <= recd_bitCntrH + 1'b1;
  else if (rstCountH) recd_bitCntrH <= 0;




// State Machine - Next State Assignment
always @(posedge clk or negedge rst)
  if (~rst) state <= r_START;
  else if(!soft_rst) state <= r_START;
  else state <= next_state;


// State Machine - Next State and Output Decode
always @(*)
begin

  // default
  next_state  = state;
  cntr_resetH = HI;
  shiftH      = LO;
  countH      = LO;
  rstCountH   = LO;
  rec_readyInH= LO;

  case (state)
     
    //
    // START
    // Wait for the start bit
    // 
    r_START: begin
       if (~rec_datH ) next_state = r_CENTER;
       else begin 
         next_state = r_START;
         rstCountH  = HI; // place the bit counter in rst state
         rec_readyInH = LO; // by default, we're ready
       end
    end

    //
  // CENTER
  // Find the center of the bit-cell 
  // A bit cell is composed of 16 system-clock 
  // ticks
  //
    r_CENTER: begin
       if (bitCell_cntrH == 4'h4) begin
         // if after having waited 1/2 bit cell,
      // it is still 0, then it is a genuine start bit
         if (~rec_datH) next_state = r_WAIT;
     // otherwise, could have been a false noise
         else next_state = r_START;
       end else begin
         next_state  = r_CENTER;
     cntr_resetH = LO;  // allow counter to tick          
       end
    end


    //
  // WAIT
  // Wait a bit-cell time before sampling the
  // state of the data pin
  //
  r_WAIT: begin
    if (bitCell_cntrH == 4'hE) begin
           if (recd_bitCntrH == WORD_LEN)
             next_state = r_STOP; // we've sampled all 8 bits
           else begin
             next_state = r_SAMPLE;
           end
        end else begin
             next_state  = r_WAIT;
             cntr_resetH = LO;  // allow counter to tick 
        end
    end

    // 
  // SAMPLE
  // Sample the state of the RECEIVE data pin 
     //
  r_SAMPLE: begin
    shiftH = HI; // shift in the serial data
    countH = HI; // one more bit received
    next_state = r_WAIT;
  end  


    // 
    // STOP
    // make sure that we've seen the stop
    // bit
    //
    r_STOP: begin
    next_state = r_START;
        rec_readyInH = HI;
    end

    default: begin
       next_state  = 3'bxxx;
       cntr_resetH = X;
     shiftH      = X;
     countH      = X;
       rstCountH   = X;
       rec_readyInH  = X;

    end

  endcase
  
  if(~uart_clk) begin
      next_state  = state;
      cntr_resetH = HI;
      shiftH      = LO;
      countH      = LO;
      rstCountH   = LO;
      rec_readyInH= LO;
  end

end


// register the state machine outputs
// to eliminate ciritical-path/glithces
always @(posedge clk or negedge rst)
  if (~rst) rec_readyH <= 0;
  else if(!soft_rst)  rec_readyH <= 0;
  else rec_readyH <= rec_readyInH;




endmodule
