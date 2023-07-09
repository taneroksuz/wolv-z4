import constants::*;
import wires::*;
import functions::*;

module decode_stage
(
  input logic reset,
  input logic clock,
  input decoder_out_type decoder_out,
  output decoder_in_type decoder_in,
  input compress_out_type compress_out,
  output compress_in_type compress_in,
  input fp_decode_out_type fp_decode_out,
  output fp_decode_in_type fp_decode_in,
  input agu_out_type agu_out,
  output agu_in_type agu_in,
  input bcu_out_type bcu_out,
  output bcu_in_type bcu_in,
  input register_out_type register_out,
  output register_read_in_type register_rin,
  output fp_register_read_in_type fp_register_rin,
  input fp_register_out_type fp_register_out,
  input csr_out_type csr_out,
  output csr_decode_in_type csr_din,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_decode_in_type fp_csr_din,
  input forwarding_out_type forwarding_out,
  output forwarding_register_in_type forwarding_rin,
  input fp_forwarding_out_type fp_forwarding_out,
  output fp_forwarding_register_in_type fp_forwarding_rin,
  input mem_out_type imem_out,
  output mem_in_type dmem_in,
  input decode_in_type a,
  input decode_in_type d,
  output decode_out_type y,
  output decode_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  decode_reg_type r,rin;
  decode_reg_type v;

  always_comb begin

    v = r;

    v.pc = d.f.pc;

    //if ((d.d.stall | d.e.stall) == 1) begin
    //  v = r;
    //end

    v.clear = csr_out.trap | csr_out.mret | d.e.fence | d.d.jump | d.e.clear;

    if (imem_out.mem_ready == 1) begin
      v.instr = imem_out.mem_rdata;
      v.stall = 0;
      if (v.busy == 1) begin
        v.instr = nop_instr;
        v.stall = 1;
        v.busy = 0;
      end
    end else if (v.busy == 0) begin
      v.instr = nop_instr;
      v.stall = 1;
      v.busy = v.clear;
    end else begin
      v.instr = nop_instr;
      v.stall = 1;
    end

    v.waddr = v.instr[11:7];
    v.raddr1 = v.instr[19:15];
    v.raddr2 = v.instr[24:20];
    v.raddr3 = v.instr[31:27];
    v.caddr = v.instr[31:20];

    v.fwren = 0;
    v.frden1 = 0;
    v.frden2 = 0;
    v.frden3 = 0;
    v.fload = 0;
    v.fstore = 0;
    v.fmt = 0;
    v.rm = 0;
    v.fpunit = 0;
    v.fpuc = 0;
    v.fpuf = 0;
    v.fpu_op = init_fp_operation;

    decoder_in.instr = v.instr;

    v.imm = decoder_out.imm;
    v.wren = decoder_out.wren;
    v.rden1 = decoder_out.rden1;
    v.rden2 = decoder_out.rden2;
    v.cwren = decoder_out.cwren;
    v.crden = decoder_out.crden;
    v.auipc = decoder_out.auipc;
    v.lui = decoder_out.lui;
    v.jal = decoder_out.jal;
    v.jalr = decoder_out.jalr;
    v.branch = decoder_out.branch;
    v.load = decoder_out.load;
    v.store = decoder_out.store;
    v.nop = decoder_out.nop;
    v.csrreg = decoder_out.csrreg;
    v.division = decoder_out.division;
    v.mult = decoder_out.mult;
    v.bitm = decoder_out.bitm;
    v.bitc = decoder_out.bitc;
    v.alu_op = decoder_out.alu_op;
    v.bcu_op = decoder_out.bcu_op;
    v.lsu_op = decoder_out.lsu_op;
    v.csr_op = decoder_out.csr_op;
    v.div_op = decoder_out.div_op;
    v.mul_op = decoder_out.mul_op;
    v.bit_op = decoder_out.bit_op;
    v.fence = decoder_out.fence;
    v.ecall = decoder_out.ecall;
    v.ebreak = decoder_out.ebreak;
    v.mret = decoder_out.mret;
    v.wfi = decoder_out.wfi;
    v.valid = decoder_out.valid;

    compress_in.instr = v.instr;

    if (compress_out.valid == 1) begin
      v.imm = compress_out.imm;
      v.waddr = compress_out.waddr;
      v.raddr1 = compress_out.raddr1;
      v.raddr2 = compress_out.raddr2;
      v.wren = compress_out.wren;
      v.rden1 = compress_out.rden1;
      v.rden2 = compress_out.rden2;
      v.fwren = compress_out.fwren;
      v.frden1 = compress_out.frden1;
      v.frden2 = compress_out.frden2;
      v.frden3 = compress_out.frden3;
      v.lui = compress_out.lui;
      v.jal = compress_out.jal;
      v.jalr = compress_out.jalr;
      v.branch = compress_out.branch;
      v.load = compress_out.load;
      v.store = compress_out.store;
      v.fload = compress_out.fload;
      v.fstore = compress_out.fstore;
      v.fpunit = compress_out.fpunit;
      v.alu_op = compress_out.alu_op;
      v.bcu_op = compress_out.bcu_op;
      v.lsu_op = compress_out.lsu_op;
      v.ebreak = compress_out.ebreak;
      v.valid = compress_out.valid;
    end

    fp_decode_in.instr = v.instr;

    if (fp_decode_out.valid == 1) begin
      v.imm = fp_decode_out.imm;
      v.wren = fp_decode_out.wren;
      v.rden1 = fp_decode_out.rden1;
      v.fwren = fp_decode_out.fwren;
      v.frden1 = fp_decode_out.frden1;
      v.frden2 = fp_decode_out.frden2;
      v.frden3 = fp_decode_out.frden3;
      v.fload = fp_decode_out.fload;
      v.fstore = fp_decode_out.fstore;
      v.fmt = fp_decode_out.fmt;
      v.rm = fp_decode_out.rm;
      v.fpunit = fp_decode_out.fpunit;
      v.fpuc = fp_decode_out.fpuc;
      v.fpuf = fp_decode_out.fpuf;
      v.valid = fp_decode_out.valid;
      v.lsu_op = fp_decode_out.lsu_op;
      v.fpu_op = fp_decode_out.fpu_op;
    end

    if (csr_out.fs == 2'b00) begin
      v.fwren = 0;
      v.frden1 = 0;
      v.frden2 = 0;
      v.frden3 = 0;
      v.fload = 0;
      v.fstore = 0;
      v.fmt = 0;
      v.rm = 0;
      v.fpunit = 0;
      v.fpuc = 0;
      v.fpuf = 0;
    end

    if (v.rm == 3'b111) begin
      v.rm = fp_csr_out.frm;
    end

    if (v.stall == 0) begin
      v.npc = v.pc + ((v.instr[1:0] == 2'b11) ? 4 : 2);
    end

    register_rin.rden1 = v.rden1;
    register_rin.rden2 = v.rden2;
    register_rin.raddr1 = v.raddr1;
    register_rin.raddr2 = v.raddr2;

    forwarding_rin.rden1 = v.rden1;
    forwarding_rin.rden2 = v.rden2;
    forwarding_rin.raddr1 = v.raddr1;
    forwarding_rin.raddr2 = v.raddr2;
    forwarding_rin.rdata1 = register_out.rdata1;
    forwarding_rin.rdata2 = register_out.rdata2;

    v.rdata1 = forwarding_out.data1;
    v.rdata2 = forwarding_out.data2;

    fp_register_rin.rden1 = v.frden1;
    fp_register_rin.rden2 = v.frden2;
    fp_register_rin.rden3 = v.frden3;
    fp_register_rin.raddr1 = v.raddr1;
    fp_register_rin.raddr2 = v.raddr2;
    fp_register_rin.raddr3 = v.raddr3;

    fp_forwarding_rin.rden1 = v.frden1;
    fp_forwarding_rin.rden2 = v.frden2;
    fp_forwarding_rin.rden3 = v.frden3;
    fp_forwarding_rin.raddr1 = v.raddr1;
    fp_forwarding_rin.raddr2 = v.raddr2;
    fp_forwarding_rin.raddr3 = v.raddr3;
    fp_forwarding_rin.rdata1 = fp_register_out.rdata1;
    fp_forwarding_rin.rdata2 = fp_register_out.rdata2;
    fp_forwarding_rin.rdata3 = fp_register_out.rdata3;

    v.frdata1 = fp_forwarding_out.data1;
    v.frdata2 = fp_forwarding_out.data2;
    v.frdata3 = fp_forwarding_out.data3;

    bcu_in.rdata1 = v.rdata1;
    bcu_in.rdata2 = v.rdata2;
    bcu_in.bcu_op = v.bcu_op;

    v.jump = v.jal | v.jalr | bcu_out.branch;

    agu_in.rdata1 = v.rdata1;
    agu_in.imm = v.imm;
    agu_in.pc = v.pc;
    agu_in.auipc = v.auipc;
    agu_in.jal = v.jal;
    agu_in.jalr = v.jalr;
    agu_in.branch = v.branch;
    agu_in.load = v.load | v.fload;
    agu_in.store = v.store | v.fstore;
    agu_in.lsu_op = v.lsu_op;

    v.address = agu_out.address;
    v.byteenable = agu_out.byteenable;
    v.exception = agu_out.exception;
    v.ecause = agu_out.ecause;
    v.etval = agu_out.etval;

    if (v.exception == 1) begin
      if ((v.load | v.fload) == 1) begin
        v.load = 0;
        v.wren = 0;
        v.fload = 0;
        v.fwren = 0;
      end else if ((v.store | v.fstore) == 1) begin
        v.store = 0;
        v.fstore = 0;
      end else if (v.jump == 1) begin
        v.jump = 0;
        v.wren = 0;
      end else begin
        v.exception = 0;
      end
    end

    if (v.valid == 0) begin
      v.exception = 1;
      v.ecause = except_illegal_instruction;
      v.etval = v.instr;
    end else if (v.ebreak == 1) begin
      v.exception = 1;
      v.ecause = except_breakpoint;
      v.etval = v.instr;
    end else if (v.ecall == 1) begin
      v.exception = 1;
      v.ecause = except_env_call_mach;
      v.etval = v.instr;
    end

    if (a.e.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.division == 1) begin
      v.stall = 1;
    end else if (a.e.bitm == 1 && a.e.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.fpunit == 1 && a.e.fpuc == 1) begin
      v.stall = 1;
    end else if (a.e.fpunit == 1 && a.e.fpuf == 1 && v.crden == 1 && (v.caddr == csr_fflags || v.caddr == csr_fcsr)) begin
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | v.clear) == 1) begin
      v.wren = 0;
      v.cwren = 0;
      v.fwren = 0;
      v.auipc = 0;
      v.lui = 0;
      v.jal = 0;
      v.jalr = 0;
      v.branch = 0;
      v.load = 0;
      v.store = 0;
      v.fload = 0;
      v.fstore = 0;
      v.nop = 0;
      v.csrreg = 0;
      v.division = 0;
      v.mult = 0;
      v.bitm = 0;
      v.bitc = 0;
      v.fence = 0;
      v.ecall = 0;
      v.ebreak = 0;
      v.mret = 0;
      v.wfi = 0;
      v.fpunit = 0;
      v.fpuc = 0;
      v.fpuf = 0;
      v.valid = 0;
      v.jump = 0;
      v.exception = 0;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    if (v.store == 1) begin
      v.sdata = v.rdata2;
    end else if (v.fstore == 1) begin
      v.sdata = v.frdata2;
    end

    dmem_in.mem_valid = v.load | v.store | v.fload | v.fstore | v.fence;
    dmem_in.mem_fence = v.fence;
    dmem_in.mem_spec = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v.address;
    dmem_in.mem_wdata = store_data(v.sdata,v.lsu_op.lsu_sb,v.lsu_op.lsu_sh,v.lsu_op.lsu_sw);
    dmem_in.mem_wstrb = ((v.load | v.fload) == 1) ? 4'h0 : v.byteenable;

    csr_din.crden = v.crden;
    csr_din.craddr = v.caddr;

    fp_csr_din.crden = v.crden;
    fp_csr_din.craddr = v.caddr;

    v.cdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;

    rin = v;

    y.pc = v.pc;
    y.npc = v.npc;
    y.imm = v.imm;
    y.wren = v.wren;
    y.rden1 = v.rden1;
    y.rden2 = v.rden2;
    y.cwren = v.cwren;
    y.crden = v.crden;
    y.fwren = v.fwren;
    y.frden1 = v.frden1;
    y.frden2 = v.frden2;
    y.frden3 = v.frden3;
    y.waddr = v.waddr;
    y.raddr1 = v.raddr1;
    y.raddr2 = v.raddr2;
    y.raddr3 = v.raddr3;
    y.caddr = v.caddr;
    y.auipc = v.auipc;
    y.lui = v.lui;
    y.jal = v.jal;
    y.jalr = v.jalr;
    y.branch = v.branch;
    y.load = v.load;
    y.store = v.store;
    y.fload = v.fload;
    y.fstore = v.fstore;
    y.nop = v.nop;
    y.csrreg = v.csrreg;
    y.division = v.division;
    y.mult = v.mult;
    y.bitm = v.bitm;
    y.bitc = v.bitc;
    y.fence = v.fence;
    y.ecall = v.ecall;
    y.ebreak = v.ebreak;
    y.mret = v.mret;
    y.wfi = v.wfi;
    y.fmt = v.fmt;
    y.rm = v.rm;
    y.fpunit = v.fpunit;
    y.fpuc = v.fpuc;
    y.fpuf = v.fpuf;
    y.valid = v.valid;
    y.jump = v.jump;
    y.rdata1 = v.rdata1;
    y.rdata2 = v.rdata2;
    y.cdata = v.cdata;
    y.frdata1 = v.frdata1;
    y.frdata2 = v.frdata2;
    y.frdata3 = v.frdata3;
    y.address = v.address;
    y.byteenable = v.byteenable;
    y.alu_op = v.alu_op;
    y.bcu_op = v.bcu_op;
    y.lsu_op = v.lsu_op;
    y.csr_op = v.csr_op;
    y.div_op = v.div_op;
    y.mul_op = v.mul_op;
    y.bit_op = v.bit_op;
    y.fpu_op = v.fpu_op;
    y.exception = v.exception;
    y.ecause = v.ecause;
    y.etval = v.etval;
    y.stall = v.stall;

    q.pc = r.pc;
    q.npc = r.npc;
    q.imm = r.imm;
    q.wren = r.wren;
    q.rden1 = r.rden1;
    q.rden2 = r.rden2;
    q.cwren = r.cwren;
    q.crden = r.crden;
    q.fwren = r.fwren;
    q.frden1 = r.frden1;
    q.frden2 = r.frden2;
    q.frden3 = r.frden3;
    q.waddr = r.waddr;
    q.raddr1 = r.raddr1;
    q.raddr2 = r.raddr2;
    q.raddr3 = r.raddr3;
    q.caddr = r.caddr;
    q.auipc = r.auipc;
    q.lui = r.lui;
    q.jal = r.jal;
    q.jalr = r.jalr;
    q.branch = r.branch;
    q.load = r.load;
    q.store = r.store;
    q.fload = r.fload;
    q.fstore = r.fstore;
    q.nop = r.nop;
    q.csrreg = r.csrreg;
    q.division = r.division;
    q.mult = r.mult;
    q.bitm = r.bitm;
    q.bitc = r.bitc;
    q.fence = r.fence;
    q.ecall = r.ecall;
    q.ebreak = r.ebreak;
    q.mret = r.mret;
    q.wfi = r.wfi;
    q.fmt = r.fmt;
    q.rm = r.rm;
    q.fpunit = r.fpunit;
    q.fpuc = r.fpuc;
    q.fpuf = r.fpuf;
    q.valid = r.valid;
    q.jump = r.jump;
    q.rdata1 = r.rdata1;
    q.rdata2 = r.rdata2;
    q.cdata = r.cdata;
    q.frdata1 = r.frdata1;
    q.frdata2 = r.frdata2;
    q.frdata3 = r.frdata3;
    q.address = r.address;
    q.byteenable = r.byteenable;
    q.alu_op = r.alu_op;
    q.bcu_op = r.bcu_op;
    q.lsu_op = r.lsu_op;
    q.csr_op = r.csr_op;
    q.div_op = r.div_op;
    q.mul_op = r.mul_op;
    q.bit_op = r.bit_op;
    q.fpu_op = r.fpu_op;
    q.exception = r.exception;
    q.ecause = r.ecause;
    q.etval = r.etval;
    q.stall = r.stall;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_decode_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
