// Synchronise a data bus from a slow clock to a fast clock
// Requirements:
//   1/ fast_clk period is >= 4x slow_clk period
//   2/ slow_data does not change every cycle

module sync_s2f_simple #(
  parameter integer DATA_WIDTH = 32
  ) (
  input fast_clk,
  input fast_rst,

  input       [DATA_WIDTH-1:0] slow_data,
  input                        slow_data_set,
  output reg  [DATA_WIDTH-1:0] fast_data,
  output reg                   fast_data_set
  );

  reg [2:0] data_set_sync;
  wire      fast_data_latch;

  always @(posedge fast_clk or posedge fast_rst) begin
    if (fast_rst) begin
      data_set_sync <= 3'b0;
      fast_data     <= {DATA_WIDTH{1'b0}};
      fast_data_set <= 1'b0;
    end else begin
      data_set_sync <= {data_set_sync[1:0], slow_data_set};

      if (fast_data_latch) begin
        fast_data <= slow_data;
      end
      fast_data_set <= fast_data_latch;
    end
  end
  assign fast_data_latch = data_set_sync[2:1] == 2'b01;

endmodule
