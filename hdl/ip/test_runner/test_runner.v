module test_runner #(
  parameter ADDR_WIDTH = 8,
            DATA_WIDTH = 8,
            NREGS      = ((1<<7))
)(
  input                   clock,
  input                   nreset,


  /* Avalon MM slave interface */
  input      [ADDR_WIDTH-1:0] address,
  input      [           1:0] byteenable,

  input                       read,
  output reg [DATA_WIDTH-1:0] readdata,
  output reg                  readdatavalid,

  input                       write,
  input      [DATA_WIDTH-1:0] writedata,


  /* Avalon Interrupt sender interface */
  output reg              irq,


  /* Conduit */
  output reg              enable,
  input                   done
);

  // Register map is currently as follows:
  // 128 real registers (addresses 0    - 0x7f)
  // 128 fake registers (addresses 0x80 - 0xFF)
  //
  // 0x7F: special ID: 0x0A
  //
  // fake registers are not stored in the register file, but are mapped to
  // special registers or direct I/O:
  //
  // 0x80: done input
  // 0x81: enable output


  reg    [DATA_WIDTH-1:0] regfile [NREGS];

  parameter REG_ID      = NREGS-1;
  parameter REG_DONE    = 'h80;
  parameter REG_ENABLE  = 'h81;



  always @(posedge clock, negedge nreset)
    if (~nreset) begin
      for (i = 0; i < NREGS; i++)
        regfile[i] <= 'b0;

      // Assign default set values
      regfile[NREGS-1] <= 8'h0A;
    end
    else if (write && (address < NREGS))
        regfile[address] <= writedata;


  always @(posedge clock, negedge nreset)
    if (~nreset)
      enable <= 1'b0;
    else if (write && (address == REG_ENABLE))
      enable <= writedata[0]; 


  always @(posedge clock, negedge nreset)
    if (~nreset)
      readdata <= 'b0;
    else if (read)
      if (address < NREGS)
        readdata <= regfile[address];
      else begin
        case(address)
          REG_DONE: readdata <= {7'b0 , done};
        endcase
      end


  always @(posedge clock, negedge nreset)
    if (~nreset)
      readdatavalid <= 1'b0;
    else
      readdatavalid <= read;


  always @(posedge clock, negedge nreset)
    if (~nreset)
      irq <= 1'b0;
    else
      irq <= done;

endmodule
