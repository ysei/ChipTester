module Fulladder(output logic CarryOut, 
                 output logic [3:0] AB,
                 input logic CarryIn,
                 input logic [3:0] A, B);

logic [4:0] Sum;

always_comb
begin
  Sum = A + B + CarryIn;
  CarryOut = Sum[4];
  AB = Sum[3:0];
end

endmodule
