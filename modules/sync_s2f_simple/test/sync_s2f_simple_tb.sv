`include "vunit_defines.svh"

module sync_s2f_simple_tb;

  parameter integer DATA_WIDTH = 16;

  reg slow_clk = 1'b0;
  reg fast_clk = 1'b0;
  reg fast_rst = 1'b1;

  reg  [DATA_WIDTH-1:0] slow_data = 0;
  reg                   slow_data_set = 0;
  wire [DATA_WIDTH-1:0] fast_data;
  wire                  fast_data_set;

  always #10 fast_clk = ~fast_clk;
  always #41 slow_clk = ~slow_clk;
  initial begin
    repeat(3) @(negedge fast_clk);
    fast_rst = 1'b0;
  end

  sync_s2f_simple #(
    .DATA_WIDTH       (DATA_WIDTH)
    ) dut (
    .fast_clk         (fast_clk),
    .fast_rst         (fast_rst),
    .slow_data        (slow_data),
    .slow_data_set    (slow_data_set),
    .fast_data        (fast_data),
    .fast_data_set    (fast_data_set)
  );

  `TEST_SUITE begin

    `TEST_CASE("basic") begin
      wait(~fast_rst);
      repeat(10) begin
        fork
          begin
            @(posedge slow_clk);
            slow_data <= $urandom % 16'hFFFF;
            slow_data_set <= 1'b1;
            @(posedge slow_clk);
            slow_data_set <= 1'b0;
            @(posedge slow_clk);
          end
          begin
            wait(fast_data_set);
            @(negedge fast_clk);
            assert (fast_data == slow_data);
            @(negedge fast_clk);
            assert (fast_data_set == 1'b0);
            assert (fast_data == slow_data);
          end
        join
      end
    end
  end

endmodule
