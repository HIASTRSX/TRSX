module pp_uart_transmitter(
        clk,
        rst,
        soft_rst,
        uart_clk,
        uart_xmitH,
        xmitH,
        xmit_dataH,
        xmit_doneH,
        data_flag,
        stop_flag,
        check_flag
      );


//
// Xmitter state definition
//
parameter  x_IDLE    = 3'b000,
            x_READY     = 3'b001,
      x_START    = 3'b010,
      x_WAIT    = 3'b011,
      x_SHIFT    = 3'b100,
      x_PARITY    = 3'b101,
      x_STOP1    = 3'b110,
      x_STOP2     = 3'b111;


parameter   x_STARTbit  = 2'b00,
            x_STOPbit   = 2'b01,
            x_ShiftReg  = 2'b10,
            x_PARITYbit = 2'b11;
      
parameter   x_Fivebit   = 2'b00,
            x_Sixbit    = 2'b01,
            x_Seven     = 2'b10,
            x_Eight     = 2'b11;
      
parameter   x_Oddcheck  = 2'b01,
            x_Evencheck = 2'b10;
      
parameter   x_Tstopbit  = 1'b1,
            x_Ostopbit  = 1'b0;
//
// Common parameter Definition
//
parameter  LO     = 1'b0,
            HI    = 1'b1,
             X    = 1'bx;


//parameter  WORD_LEN = 8;

// ******************************************
//
// PORT DEFINITIONS
//
// ******************************************
input       clk;  // system clock. Must be 16 x Baud
input       rst;  // asynch reset
input       soft_rst;
input       uart_clk;
output      uart_xmitH;  // this pin goes to the connector
input       xmitH;    // active high, Xmit command
input  [7:0]xmit_dataH;  // data to be xmitted
output      xmit_doneH;  // status

input   [1:0]data_flag;    //00:5bits,01:6bits,10:7bits,11:8bits
input        stop_flag;     //0 :1bit,1:2bts
input   [1:0]check_flag;  //00:without,01:odd,10:even,11:reserve



// ******************************************
//
// MEMORY ELEMENT DEFINITIONS
//
// ******************************************
reg    [2:0]next_state, state;
reg         load_shiftRegH;
reg         shiftEnaH;
reg    [4:0]bitCell_cntrH;
reg         countEnaH;
reg    [7:0]xmit_ShiftRegH;
reg    [3:0]bitCountH;
reg         rst_bitCountH;
reg         ena_bitCountH;
reg    [1:0]xmitDataSelH;
reg         uart_xmitH;
reg         xmit_doneInH;
reg         xmit_doneH;
reg         parity_bit;
reg         xmit_parity;
reg    [3:0]WORD_LEN;
reg         parity_chkEn;

reg     [1:0]frame_bits;
reg          stop_bits;
reg     [1:0]parity_check;


always @(posedge clk or negedge rst)
if(!rst)begin
  frame_bits <= 2'b11;
  stop_bits  <= 1'b1;
  parity_check <= 2'b00;
end
else if(!soft_rst)begin
  frame_bits <= 2'b11;
  stop_bits  <= 1'b1;
  parity_check <= 2'b00;
end
else if(state == x_IDLE) begin
  frame_bits <= data_flag;
  stop_bits  <= stop_flag;
  parity_check <= check_flag;
end


always @(xmit_ShiftRegH or xmitDataSelH or xmit_parity)
  case (xmitDataSelH)
  x_STARTbit: uart_xmitH = LO;
  x_STOPbit:  uart_xmitH = HI;
  x_ShiftReg: uart_xmitH = xmit_ShiftRegH[0];
  x_PARITYbit: uart_xmitH = xmit_parity;
  endcase


//
// Bit Cell time Counter
//
always @(posedge clk or negedge rst)
  if (~rst) bitCell_cntrH <= 0;
  else if(!soft_rst)  bitCell_cntrH <= 0;
  else if(uart_clk) begin
    if (countEnaH) bitCell_cntrH <= bitCell_cntrH + 1'b1;
    else bitCell_cntrH <= 0;
  end


//
// Shift Register
//
// The LSB must be shifted out first
//
always @(posedge clk or negedge rst)
  if (~rst) xmit_ShiftRegH <= 0;
  else if (!soft_rst)  xmit_ShiftRegH <= 0;
  else if (load_shiftRegH) xmit_ShiftRegH <= xmit_dataH;
  else if (shiftEnaH) begin
    xmit_ShiftRegH[6:0] <= xmit_ShiftRegH[7:1];
    xmit_ShiftRegH[7]   <= HI;
  end else xmit_ShiftRegH <= xmit_ShiftRegH;

// Parity bit 
always @(posedge clk or negedge rst)
  if (~rst) parity_bit <= 0;
  else if (!soft_rst)  parity_bit <= 0;
  else if(load_shiftRegH)begin
      case(frame_bits)
        x_Fivebit: parity_bit <= ^xmit_dataH[4:0];
        x_Sixbit : parity_bit <= ^xmit_dataH[5:0];
        x_Seven  : parity_bit <= ^xmit_dataH[6:0];
        x_Eight  : parity_bit <= ^xmit_dataH;
      endcase
  end

always @(*)
  if(parity_check == x_Oddcheck) begin
    xmit_parity = ~parity_bit;
    parity_chkEn = 1'b1;
  end
  else if(parity_check == x_Evencheck) begin
    xmit_parity = parity_bit;
    parity_chkEn = 1'b1;
  end
  else begin
    xmit_parity = 1'b0;
    parity_chkEn = 1'b0;
  end
  
//word length
always @(posedge clk or negedge rst)
  if(~rst) WORD_LEN<= 4'h8;
  else if (!soft_rst) WORD_LEN<= 4'h8;
  else if(state==x_IDLE)begin
      case(frame_bits)
        x_Fivebit: WORD_LEN <= 4'h5;
        x_Sixbit : WORD_LEN <= 4'h6;
        x_Seven  : WORD_LEN <= 4'h7;
        x_Eight  : WORD_LEN <= 4'h8;
      endcase
  end
//
// Transmitted bit counter
//
always @(posedge clk or negedge rst)
  if (~rst) bitCountH <= 0;
  else if (!soft_rst) bitCountH <= 0;
  else if (rst_bitCountH) bitCountH <= 0;
  else if (ena_bitCountH) bitCountH <= bitCountH + 1'b1;


//
// STATE MACHINE
//

// State Variable
always @(posedge clk or negedge rst)
  if (~rst) state <= x_IDLE;
  else if (!soft_rst) state <= x_IDLE;
  else state <= next_state;


// Next State, Output Decode
always @(*)
begin

  // Defaults
  next_state     = state;
  load_shiftRegH  = LO;
  countEnaH       = LO;
  shiftEnaH       = LO;
  rst_bitCountH   = LO;
  ena_bitCountH   = LO;
  xmitDataSelH    = x_STOPbit;
  xmit_doneInH    = LO;

  case (state)

    //
    // x_IDLE
    // wait for the start command
    //
    x_IDLE: begin
      if (xmitH) begin
                next_state = x_READY;
        load_shiftRegH = HI;
      end else begin
        next_state    = x_IDLE;
        rst_bitCountH = HI;
                xmit_doneInH  = HI;
      end
    end

        x_READY:
            next_state = x_START;
    //
    // x_START
    // send start bit
    //
    x_START: begin
            xmitDataSelH    = x_STARTbit;
            if (bitCell_cntrH == 4'hF)
              next_state = x_WAIT;
            else begin
              next_state = x_START;
              countEnaH  = HI; // allow to count up
            end
    end


    //
    // x_WAIT
    // wait 1 bit-cell time before sending
    // data on the xmit pin
    //
    x_WAIT: begin
            xmitDataSelH    = x_ShiftReg;
      // 1 bit-cell time wait completed
      /*if (bitCell_cntrH == 4'hE) begin
        if (bitCountH == WORD_LEN - 4'd1)begin
          if(parity_chkEn)
            next_state = x_PARITY;
          else
            next_state = x_STOP1;
        end*/
        if (bitCell_cntrH == 4'hE && bitCountH != WORD_LEN - 4'd1) begin
          next_state = x_SHIFT;
          ena_bitCountH = HI; //1more bit sent
        end
        else if (bitCell_cntrH == 4'hF && bitCountH == WORD_LEN - 4'd1)begin
          if(parity_chkEn)
            next_state = x_PARITY;
          else
            next_state = x_STOP1;
        end
      // bit-cell wait not complete
         else begin
          next_state = x_WAIT;
          countEnaH  = HI;
      end
    end



    //
    // x_SHIFT
    // shift out the next bit
    //
    x_SHIFT: begin
            xmitDataSelH    = x_ShiftReg;
      next_state = x_WAIT;
      shiftEnaH  = HI; // shift out next bit
    end

    x_PARITY: begin
      xmitDataSelH = x_PARITYbit;
      if(bitCell_cntrH == 4'hF)
        next_state = x_STOP1;
      else begin
        next_state = x_PARITY;
        countEnaH  = HI;
      end
    end

    //
    // x_STOP
    // send stop bit
    //
    x_STOP1: begin
            xmitDataSelH    = x_STOPbit;
      if (bitCell_cntrH == 4'hF) begin
        if(stop_bits == x_Tstopbit)
          next_state   = x_STOP2;
        else
          next_state   = x_IDLE;
                //xmit_doneInH = HI;
      end else begin
        next_state = x_STOP1;
        countEnaH = HI; //allow bit cell cntr
      end
    end
    
    x_STOP2: begin
            xmitDataSelH    = x_STOPbit;
      if (bitCell_cntrH == 4'hF) begin
        next_state   = x_IDLE;
                //xmit_doneInH = HI;
      end else begin
        next_state = x_STOP2;
        countEnaH = HI; //allow bit cell cntr
      end
    end

    default: begin
      next_state     = 3'bxxx;
      load_shiftRegH = X;
      countEnaH      = X;
            shiftEnaH      = X;
            rst_bitCountH  = X;
            ena_bitCountH  = X;
            xmitDataSelH   = 2'bxx;
            xmit_doneInH   = X;
    end

    endcase

  if ((state != x_IDLE) && !uart_clk) begin
      next_state     = state;
      load_shiftRegH = LO;
      //countEnaH      = LO;
            shiftEnaH      = LO;
            rst_bitCountH  = LO;
            ena_bitCountH  = LO;
          //xmitDataSelH   = 2'bxx;
            xmit_doneInH   = LO;
    end
end


// register the state machine outputs
// to eliminate ciritical-path/glithces
always @(posedge clk or negedge rst)
  if (~rst) xmit_doneH <= 0;
  else if(!soft_rst) xmit_doneH <= 0;
  else xmit_doneH <= xmit_doneInH;


endmodule
