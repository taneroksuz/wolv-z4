import constants::*;
import wires::*;
import functions::*;
import fp_wire::*;

module decode_stage (
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
    output mem_in_type dmem_in,
    input decode_in_type a,
    input decode_in_type d,
    output decode_out_type y,
    output decode_out_type q
);
  timeunit 1ns; timeprecision 1ps;

  decode_reg_type r, rin;
  decode_reg_type v;

  always_comb begin

    v = r;

    v.instr.pc = a.f.done ? a.f.pc : 0;
    v.instr.instr = a.f.done ? a.f.instr : nop_instr;

    v.instr.npc = v.instr.pc + ((&v.instr.instr[1:0]) ? 4 : 2);

    v.stall = 0;
    v.clear = csr_out.trap | csr_out.mret | d.e.instr.op.fence | d.d.instr.op.jump | d.e.clear;

    v.instr.waddr = v.instr.instr[11:7];
    v.instr.raddr1 = v.instr.instr[19:15];
    v.instr.raddr2 = v.instr.instr[24:20];
    v.instr.raddr3 = v.instr.instr[31:27];
    v.instr.caddr = v.instr.instr[31:20];

    v.instr.fmt = 0;
    v.instr.rm = 0;
    v.instr.fpu_op = init_fp_operation;
    v.instr.op.fwren = 0;
    v.instr.op.frden1 = 0;
    v.instr.op.frden2 = 0;
    v.instr.op.frden3 = 0;
    v.instr.op.fload = 0;
    v.instr.op.fstore = 0;
    v.instr.op.fpunit = 0;
    v.instr.op.fpuc = 0;
    v.instr.op.fpuf = 0;

    decoder_in.instr = v.instr.instr;

    v.instr.imm = decoder_out.imm;
    v.instr.alu_op = decoder_out.alu_op;
    v.instr.bcu_op = decoder_out.bcu_op;
    v.instr.lsu_op = decoder_out.lsu_op;
    v.instr.csr_op = decoder_out.csr_op;
    v.instr.div_op = decoder_out.div_op;
    v.instr.mul_op = decoder_out.mul_op;
    v.instr.bit_op = decoder_out.bit_op;
    v.instr.op.wren = decoder_out.wren;
    v.instr.op.rden1 = decoder_out.rden1;
    v.instr.op.rden2 = decoder_out.rden2;
    v.instr.op.cwren = decoder_out.cwren;
    v.instr.op.crden = decoder_out.crden;
    v.instr.op.auipc = decoder_out.auipc;
    v.instr.op.lui = decoder_out.lui;
    v.instr.op.jal = decoder_out.jal;
    v.instr.op.jalr = decoder_out.jalr;
    v.instr.op.branch = decoder_out.branch;
    v.instr.op.load = decoder_out.load;
    v.instr.op.store = decoder_out.store;
    v.instr.op.nop = decoder_out.nop;
    v.instr.op.csreg = decoder_out.csreg;
    v.instr.op.division = decoder_out.division;
    v.instr.op.mult = decoder_out.mult;
    v.instr.op.bitm = decoder_out.bitm;
    v.instr.op.bitc = decoder_out.bitc;
    v.instr.op.fence = decoder_out.fence;
    v.instr.op.ecall = decoder_out.ecall;
    v.instr.op.ebreak = decoder_out.ebreak;
    v.instr.op.mret = decoder_out.mret;
    v.instr.op.wfi = decoder_out.wfi;
    v.instr.op.valid = decoder_out.valid;

    compress_in.instr = v.instr.instr;

    if (compress_out.valid == 1) begin
      v.instr.imm = compress_out.imm;
      v.instr.waddr = compress_out.waddr;
      v.instr.raddr1 = compress_out.raddr1;
      v.instr.raddr2 = compress_out.raddr2;
      v.instr.alu_op = compress_out.alu_op;
      v.instr.bcu_op = compress_out.bcu_op;
      v.instr.lsu_op = compress_out.lsu_op;
      v.instr.op.wren = compress_out.wren;
      v.instr.op.rden1 = compress_out.rden1;
      v.instr.op.rden2 = compress_out.rden2;
      v.instr.op.fwren = compress_out.fwren;
      v.instr.op.frden1 = compress_out.frden1;
      v.instr.op.frden2 = compress_out.frden2;
      v.instr.op.frden3 = compress_out.frden3;
      v.instr.op.lui = compress_out.lui;
      v.instr.op.jal = compress_out.jal;
      v.instr.op.jalr = compress_out.jalr;
      v.instr.op.branch = compress_out.branch;
      v.instr.op.load = compress_out.load;
      v.instr.op.store = compress_out.store;
      v.instr.op.fload = compress_out.fload;
      v.instr.op.fstore = compress_out.fstore;
      v.instr.op.fpunit = compress_out.fpunit;
      v.instr.op.ebreak = compress_out.ebreak;
      v.instr.op.valid = compress_out.valid;
    end

    fp_decode_in.instr = v.instr.instr;

    if (fp_decode_out.valid == 1) begin
      v.instr.imm = fp_decode_out.imm;
      v.instr.fmt = fp_decode_out.fmt;
      v.instr.rm = fp_decode_out.rm;
      v.instr.lsu_op = fp_decode_out.lsu_op;
      v.instr.fpu_op = fp_decode_out.fpu_op;
      v.instr.op.wren = fp_decode_out.wren;
      v.instr.op.rden1 = fp_decode_out.rden1;
      v.instr.op.fwren = fp_decode_out.fwren;
      v.instr.op.frden1 = fp_decode_out.frden1;
      v.instr.op.frden2 = fp_decode_out.frden2;
      v.instr.op.frden3 = fp_decode_out.frden3;
      v.instr.op.fload = fp_decode_out.fload;
      v.instr.op.fstore = fp_decode_out.fstore;
      v.instr.op.fpunit = fp_decode_out.fpunit;
      v.instr.op.fpuc = fp_decode_out.fpuc;
      v.instr.op.fpuf = fp_decode_out.fpuf;
      v.instr.op.valid = fp_decode_out.valid;
    end

    if (csr_out.fs == 2'b00) begin
      v.instr.fmt = 0;
      v.instr.rm = 0;
      v.instr.op.fwren = 0;
      v.instr.op.frden1 = 0;
      v.instr.op.frden2 = 0;
      v.instr.op.frden3 = 0;
      v.instr.op.fload = 0;
      v.instr.op.fstore = 0;
      v.instr.op.fpunit = 0;
      v.instr.op.fpuc = 0;
      v.instr.op.fpuf = 0;
    end

    if (v.instr.rm == 3'b111) begin
      v.instr.rm = fp_csr_out.frm;
    end

    if (v.instr.waddr == 0) begin
      v.instr.op.wren = 0;
    end

    register_rin.rden1 = v.instr.op.rden1;
    register_rin.rden2 = v.instr.op.rden2;
    register_rin.raddr1 = v.instr.raddr1;
    register_rin.raddr2 = v.instr.raddr2;

    forwarding_rin.rden1 = v.instr.op.rden1;
    forwarding_rin.rden2 = v.instr.op.rden2;
    forwarding_rin.raddr1 = v.instr.raddr1;
    forwarding_rin.raddr2 = v.instr.raddr2;
    forwarding_rin.rdata1 = register_out.rdata1;
    forwarding_rin.rdata2 = register_out.rdata2;

    v.instr.rdata1 = forwarding_out.data1;
    v.instr.rdata2 = forwarding_out.data2;

    fp_register_rin.rden1 = v.instr.op.frden1;
    fp_register_rin.rden2 = v.instr.op.frden2;
    fp_register_rin.rden3 = v.instr.op.frden3;
    fp_register_rin.raddr1 = v.instr.raddr1;
    fp_register_rin.raddr2 = v.instr.raddr2;
    fp_register_rin.raddr3 = v.instr.raddr3;

    fp_forwarding_rin.rden1 = v.instr.op.frden1;
    fp_forwarding_rin.rden2 = v.instr.op.frden2;
    fp_forwarding_rin.rden3 = v.instr.op.frden3;
    fp_forwarding_rin.raddr1 = v.instr.raddr1;
    fp_forwarding_rin.raddr2 = v.instr.raddr2;
    fp_forwarding_rin.raddr3 = v.instr.raddr3;
    fp_forwarding_rin.rdata1 = fp_register_out.rdata1;
    fp_forwarding_rin.rdata2 = fp_register_out.rdata2;
    fp_forwarding_rin.rdata3 = fp_register_out.rdata3;

    v.instr.frdata1 = fp_forwarding_out.data1;
    v.instr.frdata2 = fp_forwarding_out.data2;
    v.instr.frdata3 = fp_forwarding_out.data3;

    v.instr.sdata = (v.instr.op.fstore == 1) ? v.instr.frdata2 : v.instr.rdata2;

    bcu_in.rdata1 = v.instr.rdata1;
    bcu_in.rdata2 = v.instr.rdata2;
    bcu_in.bcu_op = v.instr.bcu_op;

    v.instr.op.jump = v.instr.op.jal | v.instr.op.jalr | bcu_out.branch;

    agu_in.rdata1 = v.instr.rdata1;
    agu_in.imm = v.instr.imm;
    agu_in.pc = v.instr.pc;
    agu_in.auipc = v.instr.op.auipc;
    agu_in.jal = v.instr.op.jal;
    agu_in.jalr = v.instr.op.jalr;
    agu_in.branch = v.instr.op.branch;
    agu_in.load = v.instr.op.load | v.instr.op.fload;
    agu_in.store = v.instr.op.store | v.instr.op.fstore;
    agu_in.lsu_op = v.instr.lsu_op;

    v.instr.address = agu_out.address;
    v.instr.byteenable = agu_out.byteenable;
    v.instr.op.exception = agu_out.exception;
    v.instr.ecause = agu_out.ecause;
    v.instr.etval = agu_out.etval;

    if (v.instr.op.exception == 1) begin
      if ((v.instr.op.load | v.instr.op.fload) == 1) begin
        v.instr.op.load  = 0;
        v.instr.op.wren  = 0;
        v.instr.op.fload = 0;
        v.instr.op.fwren = 0;
      end else if ((v.instr.op.store | v.instr.op.fstore) == 1) begin
        v.instr.op.store  = 0;
        v.instr.op.fstore = 0;
      end else if (v.instr.op.jump == 1) begin
        v.instr.op.jump = 0;
        v.instr.op.wren = 0;
      end else begin
        v.instr.op.exception = 0;
      end
    end

    if (v.instr.op.valid == 0) begin
      v.instr.op.exception = 1;
      v.instr.ecause = except_illegal_instruction;
      v.instr.etval = v.instr.instr;
    end else if (v.instr.op.ebreak == 1) begin
      v.instr.op.exception = 1;
      v.instr.ecause = except_breakpoint;
      v.instr.etval = v.instr.instr;
    end else if (v.instr.op.ecall == 1) begin
      v.instr.op.exception = 1;
      v.instr.ecause = except_env_call_mach;
      v.instr.etval = v.instr.instr;
    end

    if (a.e.instr.op.cwren == 1) begin
      v.stall = 1;
    end else if (a.e.instr.op.division == 1) begin
      v.stall = 1;
    end else if (a.e.instr.op.bitc == 1) begin
      v.stall = 1;
    end else if (a.e.instr.op.fpuc == 1) begin
      v.stall = 1;
    end else if (a.e.instr.op.fpunit == 1 && a.e.instr.op.fpuf == 1 && v.instr.op.crden == 1 && (v.instr.caddr == csr_fflags || v.instr.caddr == csr_fcsr)) begin
      v.stall = 1;
    end

    if ((v.stall | a.e.stall | v.clear) == 1) begin
      v.instr.op = init_operation;
    end

    if (v.clear == 1) begin
      v.stall = 0;
    end

    if (v.instr.op.store == 1) begin
      v.instr.sdata = v.instr.rdata2;
    end else if (v.instr.op.fstore == 1) begin
      v.instr.sdata = v.instr.frdata2;
    end

    dmem_in.mem_valid = v.instr.op.load | v.instr.op.store | v.instr.op.fload | v.instr.op.fstore | v.instr.op.fence;
    dmem_in.mem_fence = v.instr.op.fence;
    dmem_in.mem_spec = 0;
    dmem_in.mem_instr = 0;
    dmem_in.mem_addr = v.instr.address;
    dmem_in.mem_wdata = store_data(v.instr.sdata, v.instr.lsu_op.lsu_sb, v.instr.lsu_op.lsu_sh,
                                   v.instr.lsu_op.lsu_sw);
    dmem_in.mem_wstrb = ((v.instr.op.load | v.instr.op.fload) == 1) ? 4'h0 : v.instr.byteenable;

    csr_din.crden = v.instr.op.crden;
    csr_din.craddr = v.instr.caddr;

    fp_csr_din.crden = v.instr.op.crden;
    fp_csr_din.craddr = v.instr.caddr;

    v.instr.crdata = (fp_csr_out.ready == 1) ? fp_csr_out.cdata : csr_out.cdata;

    rin = v;

    y.instr = v.instr;
    y.stall = v.stall;

    q.instr = r.instr;
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
