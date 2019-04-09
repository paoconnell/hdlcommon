
module registers_example (
  input         clk,
  input         rst,
  input         reg_wren,
  input   [1:0] reg_wraddr,
  input  [31:0] reg_wrdata,
  input         reg_rden,
  input   [1:0] reg_rdaddr,
  output [31:0] reg_rddata
);

  reg [31:0] reg0;
  reg [31:0] reg1;
  reg [31:0] reg2;
  reg [31:0] reg3;
  reg [31:0] reg_mux;

  always @(*) begin
    case (reg_rdaddr)
      2'h0 : reg_mux <= reg0;
      2'h1 : reg_mux <= reg1;
      2'h2 : reg_mux <= reg2;
      2'h3 : reg_mux <= reg3;
      default : reg_mux <= 0;
    endcase
  end
  assign reg_rddata = reg_mux;

  always @(posedge clk) begin
    if (rst) begin
      reg0 <= 32'h0;
      reg1 <= 32'h0;
      reg2 <= 32'h0;
      reg3 <= 32'h0;
    end else begin
      if (reg_wren) begin
        case (reg_wraddr)
          2'h0: reg0 <= reg_wrdata;
          2'h1: reg1 <= reg_wrdata;
          2'h2: reg2 <= reg_wrdata;
          2'h3: reg3 <= reg_wrdata;
          default : begin
            reg0 <= reg0;
            reg1 <= reg1;
            reg2 <= reg2;
            reg3 <= reg3;
          end
        endcase
      end
    end
  end

endmodule
