library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myAxiS_v1_0 is
	generic (
		-- Users to add parameters here
        FIFO_DEPTH : integer := 8; 
		C_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

        -- Parameters of Axi Slave Bus Interface S00_AXIS
		
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end myAxiS_v1_0;

architecture arch_imp of myAxiS_v1_0 is

	-- component declaration
	component myAxiS_v1_0_S00_AXIS is
		generic (
		NUMBER_OF_INPUT_WORDS : integer := 8;
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (        
		i_wr_en   : out  std_logic;
        i_wr_data : out  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
        o_full    : in std_logic;
        
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component myAxiS_v1_0_S00_AXIS;

	component myAxiS_v1_0_M00_AXIS is
		generic (
		NUMBER_OF_OUTPUT_WORDS  : integer := 8;
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		i_rd_en   : out  std_logic;
        o_rd_data : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
        o_empty   : in std_logic;
        
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component myAxiS_v1_0_M00_AXIS;

    component module_fifo_regs_no_flags is
        generic (
          g_WIDTH : natural := 8;
          g_DEPTH : integer := 32
          );
        port (
          i_rst_sync : in std_logic;
          i_clk      : in std_logic;
     
          -- FIFO Write Interface
          i_wr_en   : in  std_logic;
          i_wr_data : in  std_logic_vector(g_WIDTH-1 downto 0);
          o_full    : out std_logic;
     
          -- FIFO Read Interface
          i_rd_en   : in  std_logic;
          o_rd_data : out std_logic_vector(g_WIDTH-1 downto 0);
          o_empty   : out std_logic
          );
      end component module_fifo_regs_no_flags;
      
-- Signal Declaration
signal r_RESET   : std_logic;
signal r_CLOCK   : std_logic;
signal r_WR_EN   : std_logic;
signal r_WR_DATA : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
signal w_FULL    : std_logic;
signal r_RD_EN   : std_logic;
signal w_RD_DATA : std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
signal w_EMPTY   : std_logic;
      
begin

-- Instantiation of Axi Bus Interface S00_AXIS
myAxiS_v1_0_S00_AXIS_inst : myAxiS_v1_0_S00_AXIS
	generic map (
	    NUMBER_OF_INPUT_WORDS => FIFO_DEPTH,
		C_S_AXIS_TDATA_WIDTH	=> C_AXIS_TDATA_WIDTH
	)
	port map (
	    i_wr_en    => r_WR_EN,
        i_wr_data  => r_WR_DATA,
        o_full     => w_FULL,
      
		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M00_AXIS
myAxiS_v1_0_M00_AXIS_inst : myAxiS_v1_0_M00_AXIS
	generic map (
	    NUMBER_OF_OUTPUT_WORDS => FIFO_DEPTH,
		C_M_AXIS_TDATA_WIDTH	=> C_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
        i_rd_en    => r_RD_EN,
        o_rd_data  => w_RD_DATA,
        o_empty    => w_EMPTY,
      	
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);

-- Instantiation of FIFO
MODULE_FIFO_REGS : module_fifo_regs_no_flags
    generic map (
      g_WIDTH => C_AXIS_TDATA_WIDTH,
      g_DEPTH => FIFO_DEPTH
      )
    port map (
      i_rst_sync => r_RESET,
      i_clk      => r_CLOCK,
      
      i_wr_en    => r_WR_EN,
      i_wr_data  => r_WR_DATA,
      o_full     => w_FULL,
      
      i_rd_en    => r_RD_EN,
      o_rd_data  => w_RD_DATA,
      o_empty    => w_EMPTY
      );
      
	-- Add user logic here
    r_RESET <= (m00_axis_aresetn and s00_axis_aresetn);
    
	-- User logic ends

end arch_imp;
