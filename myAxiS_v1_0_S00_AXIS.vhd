library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myAxiS_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here
        NUMBER_OF_INPUT_WORDS  : integer := 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
        i_wr_en   : out  std_logic;
        i_wr_data : out  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
        o_full    : in std_logic;
        
        -- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end myAxiS_v1_0_S00_AXIS;

architecture arch_imp of myAxiS_v1_0_S00_AXIS is
	-- Define the states of state machine
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO
	type state is ( IDLE,        -- This is the initial/idle state 
	                WRITE_FIFO); -- In this state FIFO is written with the
	                             -- input stream data S_AXIS_TDATA 
	signal axis_tready	: std_logic;
	-- State variable
	signal  mst_exec_state : state;    
	-- FIFO write enable
	signal fifo_wren : std_logic;
	-- sink has accepted all the streaming data and stored in FIFO
	signal writes_done : std_logic;

begin
	-- I/O Connections assignments
    i_wr_en <= fifo_wren;
	S_AXIS_TREADY	<= axis_tready;
	-- Control state machine implementation
	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      -- Synchronous reset (active low)
	      mst_exec_state      <= IDLE;
	    else
	      case (mst_exec_state) is
	        when IDLE     => 
	          -- The sink starts accepting tdata when 
	          -- there tvalid is asserted to mark the
	          -- presence of valid streaming data 
	          if (S_AXIS_TVALID = '1')then
	            mst_exec_state <= WRITE_FIFO;
	          else
	            mst_exec_state <= IDLE;
	          end if;
	      
	        when WRITE_FIFO => 
	          -- When the sink has accepted all the streaming input data,
	          -- the interface swiches functionality to a streaming master
	          if (writes_done = '1') then
	            mst_exec_state <= IDLE;
	          else
	            -- The sink accepts and stores tdata 
	            -- into FIFO
	            mst_exec_state <= WRITE_FIFO;
	          end if;
	        
	        when others    => 
	          mst_exec_state <= IDLE;
	        
	      end case;
	    end if;  
	  end if;
	end process;
	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
	axis_tready <= '1' when ((mst_exec_state = WRITE_FIFO) and (o_full = '0')) else '0';

	process(S_AXIS_ACLK)
	begin
	  if (rising_edge (S_AXIS_ACLK)) then
	    if(S_AXIS_ARESETN = '0') then
	      writes_done <= '0';
	    else
            if (fifo_wren = '1') then
              -- write pointer is incremented after every write to the FIFO
              -- when FIFO write signal is enabled.
              writes_done <= '0';
            elsif (o_full = '1' or S_AXIS_TLAST = '1') then
              -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
              -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
              writes_done <= '1';
            end if;
	    end if;
	  end if;
	end process;

	-- FIFO write enable generation
	fifo_wren <= S_AXIS_TVALID and axis_tready;
	
	-- Latching input data that goes to FIFO
	process(S_AXIS_TDATA, S_AXIS_ARESETN,fifo_wren)
	variable data_tmp : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	begin
      if(S_AXIS_ARESETN = '0') then
        data_tmp := (others => '0');
      elsif (fifo_wren = '1') then
        data_tmp := S_AXIS_TDATA;
      else 
        data_tmp := data_tmp;
      end if;
      
      i_wr_data <= data_tmp;
    end process;

	-- Add user logic here

	-- User logic ends

end arch_imp;
