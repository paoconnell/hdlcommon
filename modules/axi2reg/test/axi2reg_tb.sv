`include "vunit_defines.svh"

module axi2reg_tb;

  parameter integer AXI_ADDR_WIDTH = 4;

  reg                       s_axi_aclk = '0;
  reg                       s_axi_aresetn = '0;
  reg  [AXI_ADDR_WIDTH-1:0] s_axi_awaddr = '0;
  reg                 [2:0] s_axi_awprot = '0;
  reg                       s_axi_awvalid = '0;
  wire                      s_axi_awready;
  reg                [31:0] s_axi_wdata = '0;
  reg                 [3:0] s_axi_wstrb = '1;
  reg                       s_axi_wvalid = '0;
  wire                      s_axi_wready;
  wire                [1:0] s_axi_bresp;
  wire                      s_axi_bvalid;
  reg                       s_axi_bready = '0;
  reg  [AXI_ADDR_WIDTH-1:0] s_axi_araddr = '0;
  reg                 [2:0] s_axi_arprot = '0;
  reg                       s_axi_arvalid = '0;
  wire                      s_axi_arready;
  wire               [31:0] s_axi_rdata;
  wire                [1:0] s_axi_rresp;
  wire                      s_axi_rvalid;
  reg                       s_axi_rready = '0;

  wire                       reg_wren;
  wire  [AXI_ADDR_WIDTH-3:0] reg_wraddr;
  wire                [31:0] reg_wrdata;
  wire                       reg_rden;
  wire  [AXI_ADDR_WIDTH-3:0] reg_rdaddr;
  wire                [31:0] reg_rddata;

  always #10 s_axi_aclk = ~s_axi_aclk;
  initial begin
    repeat(3) @(negedge s_axi_aclk);
    s_axi_aresetn = 1'b1;
  end

  task automatic axi_check_read;
    input [AXI_ADDR_WIDTH-1:0] addr;
    input               [31:0] exp_data;
    begin
      s_axi_araddr  = addr;
      s_axi_arvalid = 1'b1;
      s_axi_rready  = 1'b1;
      wait(s_axi_arready);
      wait(s_axi_rvalid);

      if (s_axi_rdata !== exp_data) begin
        $display("Error: AXI read (%x) %x, expected %x: ", addr, s_axi_rdata, exp_data);
      end

      @(posedge s_axi_aclk);
      s_axi_arvalid = 1'b0;
      @(posedge s_axi_aclk);
      s_axi_rready = 1'b0;
    end
  endtask

  task automatic axi_write;
    input [AXI_ADDR_WIDTH-1:0] addr;
    input               [31:0] data;
    begin
      s_axi_wdata   = data;
      s_axi_awaddr  = addr;
      s_axi_awvalid = 1'b1;
      s_axi_wvalid  = 1'b1;
      s_axi_bready  = 1'b1;
      wait(s_axi_awready && s_axi_wready);
      @(posedge s_axi_aclk);
      s_axi_awvalid = 1'b0;
      s_axi_wvalid  = 1'b0;
      s_axi_bready  = 1'b0;
      @(posedge s_axi_aclk);
    end
  endtask

  axi2reg #(
    .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH)
  ) dut (
    .s_axi_aclk        (s_axi_aclk),
    .s_axi_aresetn     (s_axi_aresetn),
    .s_axi_awaddr      (s_axi_awaddr),
    .s_axi_awprot      (s_axi_awprot),
    .s_axi_awvalid     (s_axi_awvalid),
    .s_axi_awready     (s_axi_awready),
    .s_axi_wdata       (s_axi_wdata),
    .s_axi_wstrb       (s_axi_wstrb),
    .s_axi_wvalid      (s_axi_wvalid),
    .s_axi_wready      (s_axi_wready),
    .s_axi_bresp       (s_axi_bresp),
    .s_axi_bvalid      (s_axi_bvalid),
    .s_axi_bready      (s_axi_bready),
    .s_axi_araddr      (s_axi_araddr),
    .s_axi_arprot      (s_axi_arprot),
    .s_axi_arvalid     (s_axi_arvalid),
    .s_axi_arready     (s_axi_arready),
    .s_axi_rdata       (s_axi_rdata),
    .s_axi_rresp       (s_axi_rresp),
    .s_axi_rvalid      (s_axi_rvalid),
    .s_axi_rready      (s_axi_rready),
    .reg_wren          (reg_wren),
    .reg_wraddr        (reg_wraddr),
    .reg_wrdata        (reg_wrdata),
    .reg_rden          (reg_rden),
    .reg_rdaddr        (reg_rdaddr),
    .reg_rddata        (reg_rddata)
  );

  registers_example reg_inst (
    .clk               (s_axi_aclk),
    .rst               (~s_axi_aresetn),
    .reg_wren          (reg_wren),
    .reg_wraddr        (reg_wraddr),
    .reg_wrdata        (reg_wrdata),
    .reg_rden          (reg_rden),
    .reg_rdaddr        (reg_rdaddr),
    .reg_rddata        (reg_rddata)
  );

  `TEST_SUITE begin

    `TEST_CASE("writeread") begin
      axi_write(4'h0, 32'h33221100);
      axi_write(4'h4, 32'h77665544);
      axi_write(4'h8, 32'hBB998877);
      axi_write(4'hc, 32'hFFEEDDCC);
      axi_check_read(4'h0, 32'h33221100);
      axi_check_read(4'h4, 32'h77665544);
      axi_check_read(4'h8, 32'hBB998877);
      axi_check_read(4'hc, 32'hFFEEDDCC);
    end

  end

endmodule
