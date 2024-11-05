class ReceiverBase;
	virtual Execute_io.TB Execute;	// interface signals
	virtual DUT_probe_if Prober; // Probe signals
	
	string   name;		// unique identifier
	OutputPacket   pkt2cmp;		// actual Packet object
	reg	[`REGISTER_WIDTH-1:0]	aluout2cmp;
	reg				mem_en2cmp;
	reg	[`REGISTER_WIDTH-1:0]	memout2cmp;
	reg				carry2cmp;

	// Connections for the Probe signals
	reg 	[`REGISTER_WIDTH-1:0]	aluin1_cmp;
	reg 	[`REGISTER_WIDTH-1:0]	aluin2_cmp; 
	reg 	[2:0]			opselect_cmp;
	reg 	[2:0]			operation_cmp;
	reg 	[4:0]  			shift_number_cmp;
	reg 				enable_shift_cmp; 
	reg 				enable_arith_cmp; 
	
	extern function new(string name = "ReceiverBase", virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
	extern virtual task recv();
	extern virtual task get_payload();
endclass

function ReceiverBase::new(string name, virtual Execute_io.TB Execute, virtual DUT_probe_if Prober);
	this.name = name;
	this.Execute = Execute;
	this.Prober = Prober;
	pkt2cmp = new();
endfunction

task ReceiverBase::recv();
	int pkt_cnt = 0;
	get_payload();
	pkt2cmp.name = $psprintf("rcvdPkt[%0d]", pkt_cnt++);
	pkt2cmp.aluout = aluout2cmp;
	pkt2cmp.mem_write_en = mem_en2cmp;
	pkt2cmp.mem_data_write_out = memout2cmp;
	pkt2cmp.carry			= carry2cmp;
	
	// Probe the internal signals as well.	
	pkt2cmp.aluin1 = aluin1_cmp; 
	pkt2cmp.aluin2 = aluin2_cmp; 
	pkt2cmp.opselect = opselect_cmp;
	pkt2cmp.operation = operation_cmp;	
	pkt2cmp.shift_number = shift_number_cmp;
	pkt2cmp.enable_shift = enable_shift_cmp; 
	pkt2cmp.enable_arith = enable_arith_cmp;		
endtask

task ReceiverBase::get_payload();
	mem_en2cmp = Execute.cb.mem_write_en;
	memout2cmp = Execute.cb.mem_data_write_out;
	
	// get the internals signals of the DUT as well 
	aluin1_cmp = Prober.aluin1; 
	aluin2_cmp = Prober.aluin2; 
	opselect_cmp = Prober.opselect;
	operation_cmp = Prober.operation;	
	shift_number_cmp = Prober.shift_number;
	enable_shift_cmp = Prober.enable_shift; 
	enable_arith_cmp = Prober.enable_arith;

	@ (Execute.cb);
	$display ($time, "[RECEIVER]  Getting Payload");
	aluout2cmp = Execute.cb.aluout;
	carry2cmp = Execute.cb.carry;
	$display ($time, "[RECEIVER]  Payload Contents:  Aluout = %h mem_write_en = %d mem_data_write_out = %h", aluout2cmp, mem_en2cmp, memout2cmp);
	// this is a bad example because there are no constructs of variable time for completion
	 //at the negative edge of the the next clock the output should be stable
	 
		
endtask
