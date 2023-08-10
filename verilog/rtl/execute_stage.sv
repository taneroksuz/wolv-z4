import constants::*;
import wires::*;

module execute_stage
(
  input logic reset,
  input logic clock,
  input alu_out_type alu_out,
  output alu_in_type alu_in,
  input lsu_out_type lsu_out,
  output lsu_in_type lsu_in,
  input csr_alu_out_type csr_alu_out,
  output csr_alu_in_type csr_alu_in,
  input div_out_type div_out,
  output div_in_type div_in,
  input mul_out_type mul_out,
  output mul_in_type mul_in,
  input bit_alu_out_type bit_alu_out,
  output bit_alu_in_type bit_alu_in,
  input bit_clmul_out_type bit_clmul_out,
  output bit_clmul_in_type bit_clmul_in,
  input fp_execute_out_type fp_execute_out,
  output fp_execute_in_type fp_execute_in,
  output register_write_in_type register_win,
  output fp_register_write_in_type fp_register_win,
  output forwarding_execute_in_type forwarding_ein,
  output fp_forwarding_execute_in_type fp_forwarding_ein,
  input csr_out_type csr_out,
  output csr_execute_in_type csr_ein,
  input fp_csr_out_type fp_csr_out,
  output fp_csr_execute_in_type fp_csr_ein,
  input mem_out_type dmem_out,
  input execute_in_type a,
  input execute_in_type d,
  output execute_out_type y,
  output execute_out_type q
);
  timeunit 1ns;
  timeprecision 1ps;

  execute_reg_type r,rin;
  execute_reg_type v;

  always_comb begin

    v = r;

    v.instr = d.d.instr;

    if (v.instr.op.fpunit == 1) begin
      if (v.instr.op.rden1 == 1) begin
        v.instr.frdata1 = v.instr.rdata1;
      end
    end

    if (d.e.stall == 1) begin
      v = r;
      v.instr.op = v.instr.op_b;
    end

    v.stall = 0;
    v.clear = csr_out.trap | csr_out.mret | d.e.clear;
    v.enable = ~(d.e.stall | v.clear);

    alu_in.rdata1 = v.instr.rdata1;
    alu_in.rdata2 = v.instr.rdata2;
    alu_in.imm = v.instr.imm;
    alu_in.sel = v.instr.op.rden2;
    alu_in.alu_op = v.instr.alu_op;

    v.instr.wdata = alu_out.result;

    mul_in.rdata1 = v.instr.rdata1;
    mul_in.rdata2 = v.instr.rdata2;
    mul_in.mul_op = v.instr.mul_op;

    v.instr.mdata = mul_out.result;

    bit_alu_in.rdata1 = v.instr.rdata1;
    bit_alu_in.rdata2 = v.instr.rdata2;
    bit_alu_in.imm = v.instr.imm;
    bit_alu_in.sel = v.instr.op.rden2;
    bit_alu_in.bit_op = v.instr.bit_op;

    v.instr.bdata = bit_alu_out.result;

    csr_alu_in.cdata = v.instr.crdata;
    csr_alu_in.rdata1 = v.instr.rdata1;
    csr_alu_in.imm = v.instr.imm;
    csr_alu_in.sel = v.instr.op.rden1;
    csr_alu_in.csr_op = v.instr.csr_op;

    v.instr.cwdata = csr_alu_out.cdata;

    div_in.rdata1 = v.instr.rdata1;
    div_in.rdata2 = v.instr.rdata2;
    div_in.enable = v.instr.op.division & v.enable;
    div_in.div_op = v.instr.div_op;

    v.instr.ddata = div_out.result;
    v.instr.dready = div_out.ready;

    bit_clmul_in.rdata1 = v.instr.rdata1;
    bit_clmul_in.rdata2 = v.instr.rdata2;
    bit_clmul_in.enable = v.instr.op.bitm & v.enable;
    bit_clmul_in.op = v.instr.bit_op.bit_zbc;

    v.instr.bcdata = bit_clmul_out.result;
    v.instr.bcready = bit_clmul_out.ready;

    fp_execute_in.data1 = v.instr.frdata1;
    fp_execute_in.data2 = v.instr.frdata2;
    fp_execute_in.data3 = v.instr.frdata3;
    fp_execute_in.fpu_op = v.instr.fpu_op;
    fp_execute_in.fmt = v.instr.fmt;
    fp_execute_in.rm = v.instr.rm;
    fp_execute_in.enable = v.instr.op.fpunit & v.enable;

    v.instr.fdata = fp_execute_out.result;
    v.instr.flags = fp_execute_out.flags;
    v.instr.fready = fp_execute_out.ready;

    lsu_in.ldata = dmem_out.mem_rdata;
    lsu_in.byteenable = v.instr.byteenable;
    lsu_in.lsu_op = v.instr.lsu_op;

    v.instr.ldata = lsu_out.result;

    if (v.instr.op.auipc == 1) begin
      v.instr.wdata = v.instr.address;
    end else if (v.instr.op.lui == 1) begin
      v.instr.wdata = v.instr.imm;
    end else if (v.instr.op.jal == 1) begin
      v.instr.wdata = v.instr.npc;
    end else if (v.instr.op.jalr == 1) begin
      v.instr.wdata = v.instr.npc;
    end else if (v.instr.op.crden == 1) begin
      v.instr.wdata = v.instr.crdata;
    end else if (v.instr.op.bitc == 1) begin
      v.instr.wdata = v.instr.bcdata;
    end else if (v.instr.op.bitm == 1) begin
      v.instr.wdata = v.instr.bdata;
    end else if (v.instr.op.mult == 1) begin
      v.instr.wdata = v.instr.mdata;
    end else if (v.instr.op.division == 1) begin
      v.instr.wdata = v.instr.ddata;
    end else if (v.instr.op.fpunit == 1) begin
      v.instr.wdata = v.instr.fdata;
    end

    if (v.instr.op.bitc == 1) begin
      v.stall = ~v.instr.bcready;
    end else if (v.instr.op.division == 1) begin
      v.stall = ~v.instr.dready;
    end else if (v.instr.op.fpunit == 1) begin
      v.stall = ~v.instr.fready;
    end

    if (v.instr.op.fence == 1) begin
      v.stall = ~dmem_out.mem_ready;
    end else if (v.instr.op.load == 1) begin
      v.instr.wdata = v.instr.ldata;
      v.stall = ~dmem_out.mem_ready;
    end else if (v.instr.op.store == 1) begin
      v.stall = ~dmem_out.mem_ready;
    end else if (v.instr.op.fload == 1) begin
      v.instr.fdata = v.instr.ldata;
      v.stall = ~dmem_out.mem_ready;
    end else if (v.instr.op.fstore == 1) begin
      v.stall = ~dmem_out.mem_ready;
    end

    v.instr.op_b = v.instr.op;

    if ((v.stall | v.clear) == 1) begin
      v.instr.op = init_operation;
    end

    if (v.instr.op_b.fence == 1) begin
      v.instr.op.fence = 1;
    end

    if (v.clear == 1) begin
      v.stall = 0;
      v.clear = 0;
    end

    if (v.instr.op.nop == 1) begin
      v.instr.op.valid = 0;
    end

    register_win.wren = v.instr.op.wren;
    register_win.waddr = v.instr.waddr;
    register_win.wdata = v.instr.wdata;

    fp_register_win.wren = v.instr.op.fwren;
    fp_register_win.waddr = v.instr.waddr;
    fp_register_win.wdata = v.instr.fdata;

    forwarding_ein.wren = v.instr.op.wren;
    forwarding_ein.waddr = v.instr.waddr;
    forwarding_ein.wdata = v.instr.wdata;

    fp_forwarding_ein.wren = v.instr.op.fwren;
    fp_forwarding_ein.waddr = v.instr.waddr;
    fp_forwarding_ein.wdata = v.instr.fdata;

    csr_ein.valid = v.instr.op.valid;
    csr_ein.cwren = v.instr.op.cwren;
    csr_ein.cwaddr = v.instr.caddr;
    csr_ein.cdata = v.instr.cwdata;

    csr_ein.mret = v.instr.op.mret;
    csr_ein.exception = v.instr.op.exception;
    csr_ein.epc = v.instr.pc;
    csr_ein.ecause = v.instr.ecause;
    csr_ein.etval = v.instr.etval;

    fp_csr_ein.cwren = v.instr.op.cwren;
    fp_csr_ein.cwaddr = v.instr.caddr;
    fp_csr_ein.cdata = v.instr.cwdata;
    fp_csr_ein.fpunit = v.instr.op.fpuf;
    fp_csr_ein.fflags = v.instr.flags;

    rin = v;

    y.instr = v.instr;
    y.stall = v.stall;
    y.clear = v.clear;

    q.instr = r.instr;
    q.stall = r.stall;
    q.clear = r.clear;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_execute_reg;
    end else begin
      r <= rin;
    end
  end

endmodule
