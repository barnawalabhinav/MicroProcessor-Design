----------------------------- PROCESSOR -----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity Proc is
  Port (
	input	: in std_logic_vector(8 downto 0); --input port from I/O device
  	reset	: in std_logic;--reset signal
    clk		: in std_logic --clock signal
    );
end Proc;

architecture exec of Proc is
	component Decoder is
 	Port (
		Dins 	: in word; --instruction
		Dic 	: out instr_class_type; --instruction class
		Dop 	: out optype; --operation
		Ddpc 	: out DP_subclass_type; --DP subclass
		Ddps 	: out DP_operand_src_type; --DP operand source
		Dldst	: out load_store_type; --load/store
		Dos 	: out DT_offset_sign_type; --DT offset sign
    	Dcd 	: out Condition_type; --Condition
        Dsr		: out Shift_Rotate_type; --Type of Shift or Rotate
    	Dsrs 	: out Shift_Rotate_src; --How is shift-rotate provided
		Dsign	: out std_logic; --Sign of extension of DT instructions
		Dsize 	: out DT_size; --Type of Data Transfer
		Didx 	: out DT_index; --Pre/Post indexing
		Dwb		: out std_logic; --Write Back
		Dhsrc 	: out DT_half_word_src --Offset Src for Half Word Transfer
	);
	end component Decoder;
    
    component ALU is
	Port (
  		Aa 		: in word; --operand 1
  		Ab 		: in word; --operand 2
  		Aop		: in optype; --opcode
  		Acin	: in std_logic; --Carry in
  		Aca		: out std_logic; --Carry out
		Ara		: out word --result
    );
	end component ALU;
    
    component RegFile is
  	Port (
  		Rrad1 	: in nibble; --read address 1
  		Rrad2 	: in nibble; --read address 2
  		Rwrad	: in nibble; --write address
  		Rdtin 	: in word; --data input
  		Ren	 	: in std_logic; --write enable
  		Rclk	: in std_logic; --clock
  		Rdout1 	: out word; --data output 1
  		Rdout2 	: out word --data output 2
    );
    end component RegFile;
    
    component Mem is
  	Port (
		Mstate	: in integer; --state of the FSM
		Mmod	: in std_logic; --mode flag
		Minp	: in std_logic_vector(8 downto 0); --input port
	  	Mclk	: in std_logic; --clock
	  	Madr 	: in byte; --address
	  	Mdtin	: in word; --data to be written
  		Mwren	: in nibble; --4 bit write enable
  		Mdtout 	: out word --data output
    );
	end component Mem;

	component PMconnect is
	Port (
		DTRout	: in word; --Source Data for Store
		DTMout 	: in word; --Data Output from Memory for Load
		DTins 	: in load_store_type;
		DTSize	: in DT_size; --Data transfer size
		DTsign	: in std_logic; --Signed/Unsigned transfer
		DTAdr 	: in bit_pair; --Address for the memory
		DState	: in integer; --State of the FSM
		DTRin 	: out word; --Data to be put in register
		DTMin 	: out word; --Data input of memory
		DTMW 	: out nibble --Memory Write enable
	);
	end component PMconnect;
    
    component ProgCount is
  	Port (
  		Pclk 	: in std_logic; --clock signal
  		Pen		: in std_logic; --clock
        Prst 	: in std_logic; --reset
        Pbr		: in word; --next instruction logic
  		pc		: out word --program counter
    );
	end component ProgCount;
    
    component Flags is
  	Port (
		Frte	: in std_logic := '0'; --Check for RTE instruction
		Fchk	: in std_logic; --Condition check
		FMRes	: in std_logic_vector(63 downto 0); --Multilier Result
		FMlg	: in std_logic; --Multiply long or not
  		FState	: in integer; --State of the FSM
    	Fclk	: in std_logic; --Clock signal
		Fic		: in instr_class_type;
    	Fdpc	: in DP_subclass_type;
    	Fop		: in optype;
    	FS		: in std_logic; --S bit
    	Fsr		: in std_logic; --Whether Shift/Rotate is provided
    	Fcs		: in std_logic; --Carry out from Shifter
    	Fca		: in std_logic; --Carry out from ALU
    	Fra		: in word;		--Result output from ALU
    	Fma		: in bit_pair;  --MSB of ALU operands index 0 -> op1 and index 1 -> op2
		FM		: out std_logic; --Mode flag
    	FC		: out std_logic; --Carry flag
    	FN		: out std_logic; --Negtive flag
    	FV		: out std_logic; --Overflow flag
    	FZ		: out std_logic  --Zero flag
    );
	end component Flags;

	component Cond is
  	Port (
		C_C		: in std_logic; --Carry flag
	    CN		: in std_logic; --Negtive flag
	    CV		: in std_logic; --Overflow flag
	    CZ		: in std_logic; --Zero flag
		Ccd		: in Condition_type; --Condition field
	    Cchk	: out std_logic --Whether cd field is true or not
    );
	end component Cond;

	component MUL is
	Port (
		MlFst	: in word := X"00000000"; --operand 1
		MlSnd 	: in word := X"00000000"; --operand 2
		MlAdd	: in std_logic_vector(63 downto 0) := X"0000000000000000"; --Addend
		MlLng	: in std_logic := '0'; --Long Multiply (Bit 23)
		MlSgn	: in std_logic := '0'; --Signed-Unsigned (Bit 22)
		MlAcm 	: in std_logic := '0'; --Accumulate (Bit 21)
		MlRes	: out std_logic_vector(63 downto 0) := X"0000000000000000" --Result
	);
	end component MUL;
    
    component CtrlPath is
  	Port (
		LMode	: in std_logic := '0'; --Mode of operation
		LMRes	: in std_logic_vector(63 downto 0); --Result of multiply
		Lwb		: in std_logic; --Write Back
		Lmw		: in nibble; -- Write enable from PMconnect
		Lindex	: in DT_index; --Pre/Post Indexing
		Lsize	: in DT_size; --Size of Data Transfer
		Lsign	: in std_logic; --Signed/Unsigned Data Transfer
  		Lsrsrc	: in Shift_Rotate_src; --Source of shift-rotate value
    	LC		: in std_logic; --Carry flag
  		LAS		: in word; --First ALU operand from FSM
        LBS		: in word; --Second ALU operand from FSM
  		LState	: in integer; --State of the FSM
	    Lchk	: in std_logic; --predicate from Condition Checker
	    Lic		: in instr_class_type;
	    Ldps	: in DP_operand_src_type;
	    Lop1	: in optype; --operand for ALU
        Lra		: in word; --ALU output
    	Lins	: in word; --Instruction
	    Ldout1	: in word; --Register File output for first operand
	    Ldout2	: in word; --Register File output for second operand
	    Los		: in DT_offset_sign_type;
	    Lldst	: in load_store_type;
        LDR		: in word; --Data Memory Output
    	LRes	: in word;  --Memory write address
        Lpc		: in word;  --Memory write address
        LShift	: out byte; --The shift-rotate amount
        LPen	: out std_logic; --Write enable for pc
        LDrad	: out byte; --Data Memory Address to be read
		Lrad1	: out nibble; --First Register to be Read
		Lrad2	: out nibble; --Second Register to be Read
        Lwrad	: out nibble; --Register to be written
	    Len		: out std_logic; --write enable for Register File
	    Lwren	: out nibble; --write enable for Data Memory
	    Lop		: out optype; --effective operand
	    La		: out word; --First operand of ALU
	    Lb		: out word; --Second operand of ALU
        LAa		: out word; --First operand that goes to ALU
        LAb		: out word; --Second operand that goes to ALU
        Ldtin	: out word; --Data to be written in register
	    Lma		: out bit_pair; --MSB of ALU operands: 0 => op1, 1 => op2
		LAdr 	: out bit_pair; --Selector for which byte to transfer
		LNpc	: out word; --New PC value
        Lcin	: out std_logic --ALU Carry
  	);
	end component;
    
  	component FSM is
  	Port (
		Schk	: in std_logic; --Condition check
  		Srst 	: in std_logic; --Reset signal
	  	Sclk	: in std_logic; --Clock
	    SDtout	: in word; --Data Output from Memory
	    LSA		: in word; --Input for first operand
	    LSB		: in word; --Input for second operand
	    Sic		: in instr_class_type;
	    Sldst	: in load_store_type;
	    SAra	: in word; --ALU output
	    SState	: inout integer := 1; --State of FSM
    	SLshift	: in byte; --The shift-rotate ammount from Control path
		SRad2	: in word; --Output from second register
    	SRshift	: out byte; --The shift-rotate ammount
	    SA		: out word; --Register A
	    SB		: out word; --Register B
	    SIR		: out word; --Instruction
	    SDR		: out word; --Data to be written in Register
	    SRes	: out word;  --Memory write address
		SDMem	: out word; --Data To be written in memory
		SM1		: out word; --Multiply first operand
		SM2		: out word; --Multiply second operand
		SMadl	: out word; --Lower half of Multiply Addend
		SMadh	: out word; --Upper half of Multiply Addend
        SS		: out std_logic --Set Flag bit
  	);
	end component;
    
    component ShiftRor is
  	Port (
	  	SRdps	: in DP_operand_src_type; --How is second operand provided
	  	SRsrs	: in Shift_Rotate_src; --Source of shift-rotate value
	  	SRCin	: in std_logic; --Shift Carry in
	    SRic	: in instr_class_type; --type of instruction
	    SRtype	: in Shift_Rotate_type; --type of shift-rotate
	    SRinp	: in word; --Value to be shifted
	    StRot	: in byte; --Shift-Rotate value to be incorporated
	    SRout	: out word; --Shifted output
	    SRCout	: out std_logic --Shift Carry out
  	);
	end component;

  -- signals for Shifter
    signal SRout : word; --Shifted output
    signal SRCout : std_logic; --Shift Carry out
  --signals for Decoder
	signal Dic 	 : instr_class_type; --instruction class
	signal Dop 	 : optype; --operation
	signal Ddpc  : DP_subclass_type; --DP subclass
	signal Ddps  : DP_operand_src_type; --DP operand source
	signal Dldst : load_store_type; --load/store
	signal Dos 	 : DT_offset_sign_type; --DT offset sign
    signal Dcd 	 : Condition_type; --Condition
   	signal Dsr	 : Shift_Rotate_type; --Type of Shift or Rotate
    signal Dsrs	 : Shift_Rotate_src; --How is shift-rotate provided
	signal Dsign : std_logic; --Sign of extension of DT instructions
	signal Dsize : DT_size; --Type of Data Transfer
	signal Didx  : DT_index; --Pre/Post indexing
	signal Dwb	 : std_logic; --Write Back
	signal Dhsrc : DT_half_word_src; --Offset Src for Half Word Transfer
  -- signals for ALU
  	signal Aca	: std_logic; --Carry out
	signal Ara	: word; --result
  -- signals for Register File
  	signal Rdout1 	: word; --data output 1
  	signal Rdout2 	: word; --data output 2
  -- signals for Data Memory
  	signal Mdtout 	: word; --data output
  -- signals for Flags
    signal Z	: std_logic; --Zero flag
	signal M	: std_logic; --Mode flag
	signal C	: std_logic; --Carry flag
    signal N	: std_logic; --Negtive flag
    signal V	: std_logic; --Overflow flag
  -- signals for Conditions
    signal CChk	: std_logic; --Predicate
  -- signals for Control Path
    signal LShift	: byte; --The shift-rotate ammount
    signal LDrad	: byte; --Data Memory Address to be read
    signal Lrad1	: nibble; --First Register to be Read
	signal Lrad2	: nibble; --Second Register to be Read
    signal Lwrad	: nibble; --Register to be written
	signal Len		: std_logic; --write enable for Register File
    signal Lwren	: nibble; --write enable for Data Memory
	signal Lop		: optype; --effective operand
	signal La		: word; --First operand of ALU
	signal Lb		: word; --Second operand of ALU
    signal LAa		: word; --First operand that goes to ALU
    signal LAb		: word; --Second operand that goes to ALU
    signal Ldtin	: word; --Data to be written in register
	signal Lma		: bit_pair; --MSB of ALU operands: 0 => op1, 1 => op2
	signal Adr 		: bit_pair; --Selector for which byte to transfer
    signal Lcin		: std_logic; --ALU Carry
	signal LNpc		: word; --New PC value
  -- signas for FSM
   	signal SRshift	: byte; --The shift-rotate ammount
	signal SDMem	: word; --The data to be written in memory for store instruction
	signal SM1		: word; --Multiply first operand
	signal SM2		: word; --Multiply second operand
	signal SMadl	: word; --Lower half of Multiply Addend
	signal SMadh	: word; --Upper half of Multiply Addend
	--signal for PMconnect
	signal Rin		: word;
	signal Min		: word;
	signal MW		: nibble;
	--signal for Multiply
	signal MlAdd	: std_logic_vector(63 downto 0);
	signal MlRes	: std_logic_vector(63 downto 0); --Multiply Result
  	
	signal pc		: word; --program counter
	signal En		: std_logic; --Write enable for PC
    signal State	: integer := 1; --State of FSM
    signal A		: word;
    signal B		: word;
    signal IR		: word;
    signal DR		: word;
    signal RES		: word;
    signal SS		: std_logic;

begin
	Machine	: FSM port map (	Schk	=> Cchk,
								Srst 	=> reset,
    							Sclk 	=> clk,
    							SDtout	=> Rin,
                            	LSA 	=> La,
                            	LSB 	=> Lb,
                            	Sic 	=> Dic,
                            	Sldst 	=> Dldst,
                            	SAra 	=> Ara,
                            	SState	=> State,
    							SLshift	=> LShift,
    							SRshift	=> SRshift,
								SRad2	=> Rdout2,
                            	SA 		=> A,
                            	SB 		=> B,
                            	SIR 	=> IR,
                            	SDR 	=> DR,
                            	SRES	=> RES,
								SDMem	=> SDMem,
								SM1		=> SM1,
								SM2		=> SM2,
								SMadl	=> SMadl,
								SMadh	=> SMadh,
                                SS		=> SS);
	Shifter	: ShiftRor port map (SRdps	=> Ddps,
    							SRsrs	=> Dsrs,
          						SRCin	=> C,
	    						SRic	=> Dic,
	    						SRtype	=> Dsr,
	    						SRinp	=> B,
	    						StRot	=> SRshift,
	    						SRout	=> SRout,
	    						SRCout	=> SRCout);
	PMcnct 	: PMconnect port map (DTRout=> SDMem,
								DTMout 	=> Mdtout,
								DTins 	=> Dldst,
								DTSize	=> Dsize,
								DTsign	=> Dsign,
								DTAdr 	=> Adr,
								DState	=> State,
								DTRin 	=> Rin,
								DTMin 	=> Min,
								DTMW 	=> MW);
    fetch	: Mem port map (	Mstate	=> State,
								Mmod	=> M,
								Minp	=> input,
								Mclk 	=> clk,
    							Madr 	=> LDrad,
                                Mdtin 	=> Min,
                                Mwren 	=> Lwren,
                                Mdtout 	=> Mdtout);
    decode	: Decoder port map (Dins  	=> IR,
    							Dic   	=> Dic,
                                Dop   	=> Dop,
                                Ddpc  	=> Ddpc,
                                Ddps  	=> Ddps,
                                Dldst 	=> Dldst,
                                Dos   	=> Dos,
                                Dcd   	=> Dcd,
                                Dsr		=> Dsr,
                                Dsrs	=> Dsrs,
								Dsign	=> Dsign,
								Dsize 	=> Dsize,
								Didx 	=> Didx,
								Dwb		=> Dwb,
								Dhsrc 	=> Dhsrc);
	MlAdd <= SMadh & SMadl;
	Multiply	: MUL port map (MlFst	=> SM1,
								MlSnd	=> SM2,
								MlAdd	=> MlAdd,
								MlLng	=> IR(23),
								MlSgn	=> IR(22),
								MlAcm 	=> IR(21),
								MlRes	=> MlRes);
    RegRead	: RegFile port map (Rrad1 	=> Lrad1,
    							Rrad2 	=> Lrad2,
                                Rwrad 	=> Lwrad,
                                Rdtin 	=> Ldtin,
                                Ren   	=> Len,
                                Rclk  	=> clk,
                                Rdout1 	=> Rdout1,
                                Rdout2 	=> Rdout2);
    Control	: CtrlPath port map (LMode	=> M,
								LMRes	=> MlRes,
								Lwb		=> Dwb,
								Lmw		=> MW,
								Lindex	=> Didx,
								Lsize	=> Dsize,
								Lsign	=> Dsign,
								Lsrsrc	=> Dsrs,
                                LC		=> C,
    							LAS		=> A,
    							LBS		=> SRout,
                                LState	=> State,
                                Lchk  	=> Cchk,
                                Lic   	=> Dic,
                                Ldps  	=> Ddps,
                                Lop1  	=> Dop,
                                Lra 	=> Ara,
                                Lins  	=> IR,
                                Ldout1 	=> Rdout1,
                                Ldout2 	=> Rdout2,
                                Los   	=> Dos,
                                Lldst 	=> Dldst,
                                LDR		=> DR,
                                LRes	=> RES,
                                Lpc		=> pc,
                                LShift	=> LShift,
                                LPen	=> En,
                                LDrad	=> LDrad,
                                Lrad1	=> Lrad1,
                                Lrad2	=> Lrad2,
                                Lwrad	=> Lwrad,
                                Len   	=> Len,
                                Lwren 	=> Lwren,
                                Lop   	=> Lop,
                                La		=> La,
                                Lb    	=> Lb,
                                LAa		=> LAa,
                                LAb		=> LAb,
                                Ldtin	=> Ldtin,
                                Lma   	=> Lma,
								LAdr	=> Adr,
								LNpc	=> LNpc,
                                Lcin	=> Lcin);
    Counter	: ProgCount port map (Pclk	=> clk,
    							Pen 	=> En,
    							Prst 	=> reset,
                                Pbr 	=> LNpc,
                                pc 		=> pc);
    operate	: ALU port map (	Aa 		=> LAa,
    							Ab 		=> LAb,
                            	Aop 	=> Lop,
                            	Acin 	=> Lcin,
                            	Aca 	=> Aca,
                            	Ara 	=> Ara);
    FlagSet	: Flags port map (	Frte	=> IR(0),
								Fchk	=> Cchk,
								FMRes	=> MlRes,
								FMlg	=> IR(23),
								FState	=> State,
    							Fclk	=> clk,
    						  	Fic 	=> Dic,
    						  	Fdpc 	=> Ddpc,
                              	Fop 	=> Lop,
                              	FS 		=> SS,
                              	Fsr 	=> '1',
                              	Fcs 	=> SRCout,
                              	Fca 	=> Aca,
                              	Fra 	=> RES,
                              	Fma 	=> Lma,
								FM		=> M,
                              	FC 		=> C,
                              	FN 		=> N,
                              	FV 		=> V,
                              	FZ		=> Z);
    Check	: Cond port map(	C_C 	=> C,
    							CN 		=> N,
                            	CV 		=> V,
                            	CZ 		=> Z,
                            	Ccd 	=> Dcd,
                            	Cchk	=> Cchk);
end exec;
