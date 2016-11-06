-- megafunction wizard: %ALTIOBUF%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altiobuf_bidir 

-- ============================================================
-- File Name: iobuf.vhd
-- Megafunction Name(s):
-- 			altiobuf_bidir
--
-- Simulation Library Files(s):
-- 			cycloneive
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 16.0.0 Build 211 04/27/2016 SJ Lite Edition
-- ************************************************************


--Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, the Altera Quartus Prime License Agreement,
--the Altera MegaCore Function License Agreement, or other 
--applicable license agreement, including, without limitation, 
--that your use is for the sole purpose of programming logic 
--devices manufactured by Altera and sold by Altera or its 
--authorized distributors.  Please refer to the applicable 
--agreement for further details.


--altiobuf_bidir CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Cyclone IV E" ENABLE_BUS_HOLD="FALSE" NUMBER_OF_CHANNELS=16 OPEN_DRAIN_OUTPUT="FALSE" USE_DIFFERENTIAL_MODE="FALSE" USE_DYNAMIC_TERMINATION_CONTROL="FALSE" USE_TERMINATION_CONTROL="FALSE" datain dataio dataout oe
--VERSION_BEGIN 16.0 cbx_altiobuf_bidir 2016:04:27:18:05:34:SJ cbx_mgl 2016:04:27:18:06:48:SJ cbx_stratixiii 2016:04:27:18:05:34:SJ cbx_stratixv 2016:04:27:18:05:34:SJ  VERSION_END

 LIBRARY cycloneive;
 USE cycloneive.all;

--synthesis_resources = cycloneive_io_ibuf 16 cycloneive_io_obuf 16 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  iobuf_iobuf_bidir_p1p IS 
	 PORT 
	 ( 
		 datain	:	IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 dataio	:	INOUT  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 dataout	:	OUT  STD_LOGIC_VECTOR (15 DOWNTO 0);
		 oe	:	IN  STD_LOGIC_VECTOR (15 DOWNTO 0)
	 ); 
 END iobuf_iobuf_bidir_p1p;

 ARCHITECTURE RTL OF iobuf_iobuf_bidir_p1p IS

	 SIGNAL  wire_ibufa_i	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_ibufa_o	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_obufa_i	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_obufa_o	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 SIGNAL  wire_obufa_oe	:	STD_LOGIC_VECTOR (15 DOWNTO 0);
	 COMPONENT  cycloneive_io_ibuf
	 GENERIC 
	 (
		bus_hold	:	STRING := "false";
		differential_mode	:	STRING := "false";
		simulate_z_as	:	STRING := "Z";
		lpm_type	:	STRING := "cycloneive_io_ibuf"
	 );
	 PORT
	 ( 
		i	:	IN STD_LOGIC := '0';
		ibar	:	IN STD_LOGIC := '0';
		o	:	OUT STD_LOGIC
	 ); 
	 END COMPONENT;
	 COMPONENT  cycloneive_io_obuf
	 GENERIC 
	 (
		bus_hold	:	STRING := "false";
		open_drain_output	:	STRING := "false";
		lpm_type	:	STRING := "cycloneive_io_obuf"
	 );
	 PORT
	 ( 
		i	:	IN STD_LOGIC := '0';
		o	:	OUT STD_LOGIC;
		obar	:	OUT STD_LOGIC;
		oe	:	IN STD_LOGIC := '1';
		seriesterminationcontrol	:	IN STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
	 ); 
	 END COMPONENT;
 BEGIN

	dataio <= wire_obufa_o;
	dataout <= wire_ibufa_o;
	wire_ibufa_i <= dataio;
	loop0 : FOR i IN 0 TO 15 GENERATE 
	  ibufa :  cycloneive_io_ibuf
	  GENERIC MAP (
		bus_hold => "false",
		differential_mode => "false"
	  )
	  PORT MAP ( 
		i => wire_ibufa_i(i),
		o => wire_ibufa_o(i)
	  );
	END GENERATE loop0;
	wire_obufa_i <= datain;
	wire_obufa_oe <= oe;
	loop1 : FOR i IN 0 TO 15 GENERATE 
	  obufa :  cycloneive_io_obuf
	  GENERIC MAP (
		bus_hold => "false",
		open_drain_output => "false"
	  )
	  PORT MAP ( 
		i => wire_obufa_i(i),
		o => wire_obufa_o(i),
		oe => wire_obufa_oe(i)
	  );
	END GENERATE loop1;

 END RTL; --iobuf_iobuf_bidir_p1p
--VALID FILE


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY iobuf IS
	PORT
	(
		datain		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		oe		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		dataio		: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		dataout		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END iobuf;


ARCHITECTURE RTL OF iobuf IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (15 DOWNTO 0);



	COMPONENT iobuf_iobuf_bidir_p1p
	PORT (
			datain	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			oe	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			dataout	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			dataio	: INOUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	dataout    <= sub_wire0(15 DOWNTO 0);

	iobuf_iobuf_bidir_p1p_component : iobuf_iobuf_bidir_p1p
	PORT MAP (
		datain => datain,
		oe => oe,
		dataout => sub_wire0,
		dataio => dataio
	);



END RTL;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: CONSTANT: enable_bus_hold STRING "FALSE"
-- Retrieval info: CONSTANT: number_of_channels NUMERIC "16"
-- Retrieval info: CONSTANT: open_drain_output STRING "FALSE"
-- Retrieval info: CONSTANT: use_differential_mode STRING "FALSE"
-- Retrieval info: CONSTANT: use_dynamic_termination_control STRING "FALSE"
-- Retrieval info: CONSTANT: use_termination_control STRING "FALSE"
-- Retrieval info: USED_PORT: datain 0 0 16 0 INPUT NODEFVAL "datain[15..0]"
-- Retrieval info: USED_PORT: dataio 0 0 16 0 BIDIR NODEFVAL "dataio[15..0]"
-- Retrieval info: USED_PORT: dataout 0 0 16 0 OUTPUT NODEFVAL "dataout[15..0]"
-- Retrieval info: USED_PORT: oe 0 0 16 0 INPUT NODEFVAL "oe[15..0]"
-- Retrieval info: CONNECT: @datain 0 0 16 0 datain 0 0 16 0
-- Retrieval info: CONNECT: @oe 0 0 16 0 oe 0 0 16 0
-- Retrieval info: CONNECT: dataio 0 0 16 0 @dataio 0 0 16 0
-- Retrieval info: CONNECT: dataout 0 0 16 0 @dataout 0 0 16 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL iobuf.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL iobuf.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL iobuf.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL iobuf.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL iobuf_inst.vhd FALSE
-- Retrieval info: LIB_FILE: cycloneive
