module axi2reg # (
  parameter integer AXI_ADDR_WIDTH = 4
) (
  input                       s_axi_aclk,
  input                       s_axi_aresetn,
  input  [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
  input                 [2:0] s_axi_awprot,
  input                       s_axi_awvalid,
  output                      s_axi_awready,
  input              [31:0]   s_axi_wdata,
  input                 [3:0] s_axi_wstrb,
  input                       s_axi_wvalid,
  output                      s_axi_wready,
  output                [1:0] s_axi_bresp,
  output                      s_axi_bvalid,
  input                       s_axi_bready,
  input  [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
  input                 [2:0] s_axi_arprot,
  input                       s_axi_arvalid,
  output                      s_axi_arready,
  output               [31:0] s_axi_rdata,
  output                [1:0] s_axi_rresp,
  output                      s_axi_rvalid,
  input                       s_axi_rready,

  output wire                      reg_wren,
  output wire [AXI_ADDR_WIDTH-3:0] reg_wraddr,
  output wire               [31:0] reg_wrdata,
  output wire                      reg_rden,
  output wire [AXI_ADDR_WIDTH-3:0] reg_rdaddr,
  input wire                [31:0] reg_rddata
  );

  // AXI4LITE signals
  reg [AXI_ADDR_WIDTH-1:0] axi_awaddr;
  reg                      axi_awready;
  reg                      axi_wready;
  reg                [1:0] axi_bresp;
  reg                      axi_bvalid;
  reg [AXI_ADDR_WIDTH-1:0] axi_araddr;
  reg                      axi_arready;
  reg               [31:0] axi_rdata;
  reg                [1:0] axi_rresp;
  reg                      axi_rvalid;

  reg                      axi_write_enabled;

  assign s_axi_awready = axi_awready;
  assign s_axi_wready  = axi_wready;
  assign s_axi_bresp   = axi_bresp;
  assign s_axi_bvalid  = axi_bvalid;
  assign s_axi_arready = axi_arready;
  assign s_axi_rdata   = axi_rdata;
  assign s_axi_rresp   = axi_rresp;
  assign s_axi_rvalid  = axi_rvalid;

  // Write and response
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn) begin
      axi_write_enabled <= 1'b1;
      axi_awready       <= 1'b0;
      axi_awaddr        <= {AXI_ADDR_WIDTH{1'b0}};
      axi_wready        <= 1'b0;
      axi_bvalid        <= 0;
      axi_bresp         <= 2'b0;
    end else begin

      if (~axi_awready && s_axi_awvalid && s_axi_wvalid && axi_write_enabled) begin
        axi_write_enabled <= 1'b0;
        axi_awaddr        <= s_axi_awaddr;
        axi_wready        <= 1'b1;
        axi_awready       <= 1'b1;
      end else begin
        if (s_axi_bready && axi_bvalid) begin
          axi_write_enabled <= 1'b1;
        end
        axi_wready  <= 1'b0;
        axi_awready <= 1'b0;
      end

      if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid) begin
        axi_bvalid <= 1'b1;
        axi_bresp  <= 2'b0;  //OKAY
      end else begin
        if (s_axi_bready && axi_bvalid) begin
          axi_bvalid <= 1'b0;
        end
      end

    end
  end

  assign reg_wren   = axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid;
  assign reg_wrdata = s_axi_wdata;
  assign reg_wraddr = axi_awaddr[AXI_ADDR_WIDTH-1:2];

  // Read and response
  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn) begin
        axi_arready <= 1'b0;
        axi_araddr  <= 32'b0;
        axi_rvalid  <= 0;
        axi_rresp   <= 0;
    end else begin

      if (~axi_arready && s_axi_arvalid) begin
        axi_arready <= 1'b1;
        axi_araddr  <= s_axi_araddr;
      end else begin
        axi_arready <= 1'b0;
      end

      if (axi_arready && s_axi_arvalid && ~axi_rvalid) begin
        axi_rvalid <= 1'b1;
        axi_rresp  <= 2'b0;  //OKAY
      end else if (axi_rvalid && s_axi_rready) begin
        axi_rvalid <= 1'b0;
      end
    end
  end

  assign reg_rden   = axi_arready & s_axi_arvalid & ~axi_rvalid;
  assign reg_rdaddr = axi_araddr[AXI_ADDR_WIDTH-1:2];

  always @(posedge s_axi_aclk) begin
    if (~s_axi_aresetn) begin
      axi_rdata <= 32'h0;
    end else begin
      if (reg_rden) begin
        axi_rdata <= reg_rddata;
      end
    end
  end

endmodule
