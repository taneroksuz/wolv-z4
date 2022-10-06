import configure::*;
import wires::*;
import fp_cons::*;
import fp_wire::*;

module fpu_decode
(
  input fp_decode_in_type fp_decode_in,
  output fp_decode_out_type fp_decode_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31 : 0] instr;

  logic [31 : 0] imm_i;
  logic [31 : 0] imm_s;

  logic [31 : 0] imm;

  logic [6  : 0] opcode;
  logic [2  : 0] funct3;
  logic [6  : 0] funct7;

  logic [0  : 0] wren;
  logic [0  : 0] rden1;

  logic [0  : 0] fwren;
  logic [0  : 0] frden1;
  logic [0  : 0] frden2;
  logic [0  : 0] frden3;

  logic [0  : 0] fload;
  logic [0  : 0] fstore;

  logic [1  : 0] fmt;
  logic [2  : 0] rm;

  logic [0  : 0] fpu;
  logic [0  : 0] fpuc;
  logic [0  : 0] fpuf;

  lsu_op_type lsu_op;

  fp_operation_type fpu_op;

  logic [0  : 0] valid;

  always_comb begin

    instr = fp_decode_in.instr;

    imm_i = {{20{instr[31]}},instr[31:20]};
    imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};

    opcode = instr[6:0];
    funct3 = instr[14:12];
    funct7 = instr[31:25];
    fmt = instr[26:25];
    rm = instr[14:12];

    imm = 0;

    wren = 0;
    rden1 = 0;

    fwren = 0;
    frden1 = 0;
    frden2 = 0;
    frden3 = 0;

    fload = 0;
    fstore = 0;

    fpu = 0;
    fpuc = 0;
    fpuf = 0;

    lsu_op = init_lsu_op;

    fpu_op = init_fp_operation;

    fpu_op.fcvt_op = instr[21:20];

    valid = 1;

    case (opcode)
      opcode_fload : begin
        imm = imm_i;
        rden1 = 1;
        fwren = 1;
        fload = 1;
        // fpu = 1;
        if (funct3 == funct_lw) begin
          lsu_op.lsu_lw = 1;
        end else begin
          valid = 0;
        end
      end
      opcode_fstore : begin
        imm = imm_s;
        rden1 = 1;
        frden2 = 1;
        fstore = 1;
        // fpu = 1;
        if (funct3 == funct_sw) begin
          lsu_op.lsu_sw = 1;
        end else begin
          valid = 0;
        end
      end
      opcode_fp : begin
        case (funct7[6:2])
          funct_fadd : begin 
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuc = 1;
            fpuf = 1;
            fpu_op.fadd = 1;
          end
          funct_fsub : begin
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuc = 1;
            fpuf = 1;
            fpu_op.fsub = 1;
          end
          funct_fmul : begin
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuc = 1;
            fpuf = 1;
            fpu_op.fmul = 1;
          end
          funct_fdiv : begin
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuc = 1;
            fpuf = 1;
            fpu_op.fdiv = 1;
          end
          funct_fsqrt : begin
            fwren = 1;
            frden1 = 1;
            fpu = 1;
            fpuc = 1;
            fpuf = 1;
            fpu_op.fsqrt = 1;
          end
          funct_fsgnj : begin
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpu_op.fsgnj = 1;
          end
          funct_fminmax : begin
            fwren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuf = 1;
            fpu_op.fmax = 1;
          end
          funct_fcomp : begin
            wren = 1;
            frden1 = 1;
            frden2 = 1;
            fpu = 1;
            fpuf = 1;
            fpu_op.fcmp = 1;
          end
          funct_fmv_f2i : begin
            wren = 1;
            frden1 = 1;
            fpu = 1;
            if (rm == 0) begin
              fpu_op.fmv_f2i = 1;
            end else if (rm == 1) begin
              fpu_op.fclass = 1;
            end
          end
          funct_fmv_i2f : begin
            rden1 = 1;
            fwren = 1;
            fpu = 1;
            fpu_op.fmv_i2f = 1;
          end
          funct_fconv_f2i : begin
            wren = 1;
            frden1 = 1;
            fpu = 1;
            fpuf = 1;
            fpu_op.fcvt_f2i = 1;
          end
          funct_fconv_i2f : begin
            rden1 = 1;
            fwren = 1;
            fpu = 1;
            fpuf = 1;
            fpu_op.fcvt_i2f = 1;
          end
          default : valid = 0;
        endcase
      end
      opcode_fmadd : begin
        fwren = 1;
        frden1 = 1;
        frden2 = 1;
        frden3 = 1;
        fpu = 1;
        fpuc = 1;
        fpuf = 1;
        fpu_op.fmadd = 1;
      end
      opcode_fmsub : begin
        fwren = 1;
        frden1 = 1;
        frden2 = 1;
        frden3 = 1;
        fpu = 1;
        fpuc = 1;
        fpuf = 1;
        fpu_op.fmsub = 1;
      end
      opcode_fnmsub : begin
        fwren = 1;
        frden1 = 1;
        frden2 = 1;
        frden3 = 1;
        fpu = 1;
        fpuc = 1;
        fpuf = 1;
        fpu_op.fnmsub = 1;
      end
      opcode_fnmadd : begin
        fwren = 1;
        frden1 = 1;
        frden2 = 1;
        frden3 = 1;
        fpu = 1;
        fpuc = 1;
        fpuf = 1;
        fpu_op.fnmadd = 1;
      end
      default : valid = 0;
    endcase

    fp_decode_out.imm = imm;
    fp_decode_out.wren = wren;
    fp_decode_out.fwren = fwren;
    fp_decode_out.rden1 = rden1;
    fp_decode_out.frden1 = frden1;
    fp_decode_out.frden2 = frden2;
    fp_decode_out.frden3 = frden3;
    fp_decode_out.fload = fload;
    fp_decode_out.fstore = fstore;
    fp_decode_out.fmt = fmt;
    fp_decode_out.rm = rm;
    fp_decode_out.fpu = fpu;
    fp_decode_out.fpuc = fpuc;
    fp_decode_out.fpuf = fpuf;
    fp_decode_out.valid = valid;
    fp_decode_out.lsu_op = lsu_op;
    fp_decode_out.fpu_op = fpu_op;

  end

endmodule

module fpu_forwarding
(
  input fp_forwarding_register_in_type fp_forwarding_rin,
  input fp_forwarding_execute_in_type fp_forwarding_ein,
  output fp_forwarding_out_type fp_forwarding_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] res1;
  logic [31:0] res2;
  logic [31:0] res3;

  always_comb begin
    res1 = 0;
    res2 = 0;
    res3 = 0;
    if (fp_forwarding_rin.rden1 == 1) begin
      res1 = fp_forwarding_rin.rdata1;
      if (fp_forwarding_ein.wren == 1 & fp_forwarding_rin.raddr1 == fp_forwarding_ein.waddr) begin
        res1 = fp_forwarding_ein.wdata;
      end
    end
    if (fp_forwarding_rin.rden2 == 1) begin
      res2 = fp_forwarding_rin.rdata2;
      if (fp_forwarding_ein.wren == 1 & fp_forwarding_rin.raddr2 == fp_forwarding_ein.waddr) begin
        res2 = fp_forwarding_ein.wdata;
      end
    end
    if (fp_forwarding_rin.rden3 == 1) begin
      res3 = fp_forwarding_rin.rdata3;
      if (fp_forwarding_ein.wren == 1 & fp_forwarding_rin.raddr3 == fp_forwarding_ein.waddr) begin
        res3 = fp_forwarding_ein.wdata;
      end
    end
    fp_forwarding_out.data1 = res1;
    fp_forwarding_out.data2 = res2;
    fp_forwarding_out.data3 = res3;
  end

endmodule

module fpu_register
(
  input logic rst,
  input logic clk,
  input fp_register_read_in_type fp_register_rin,
  input fp_register_write_in_type fp_register_win,
  output fp_register_out_type fp_register_out
);
  timeunit 1ns;
  timeprecision 1ps;

  logic [31:0] fp_reg_file[0:31] = '{default:'0};

  always_ff @(posedge clk) begin
    if (fp_register_win.wren == 1) begin
      fp_reg_file[fp_register_win.waddr] <= fp_register_win.wdata;
    end
  end

  assign fp_register_out.rdata1 = fp_reg_file[fp_register_rin.raddr1];
  assign fp_register_out.rdata2 = fp_reg_file[fp_register_rin.raddr2];
  assign fp_register_out.rdata3 = fp_reg_file[fp_register_rin.raddr3];

endmodule

module fpu_execute
(
  input logic rst,
  input logic clk,
  input fp_execute_in_type fp_execute_in,
  output fp_execute_out_type fp_execute_out
);
  timeunit 1ns;
  timeprecision 1ps;

  lzc_32_in_type lzc1_32_i;
  lzc_32_out_type lzc1_32_o;
  lzc_32_in_type lzc2_32_i;
  lzc_32_out_type lzc2_32_o;
  lzc_32_in_type lzc3_32_i;
  lzc_32_out_type lzc3_32_o;
  lzc_32_in_type lzc4_32_i;
  lzc_32_out_type lzc4_32_o;

  lzc_128_in_type lzc_128_i;
  lzc_128_out_type lzc_128_o;

  fp_ext_in_type fp_ext1_i;
  fp_ext_out_type fp_ext1_o;
  fp_ext_in_type fp_ext2_i;
  fp_ext_out_type fp_ext2_o;
  fp_ext_in_type fp_ext3_i;
  fp_ext_out_type fp_ext3_o;

  fp_cmp_in_type fp_cmp_i;
  fp_cmp_out_type fp_cmp_o;
  fp_max_in_type fp_max_i;
  fp_max_out_type fp_max_o;
  fp_sgnj_in_type fp_sgnj_i;
  fp_sgnj_out_type fp_sgnj_o;
  fp_fma_in_type fp_fma_i;
  fp_fma_out_type fp_fma_o;
  fp_rnd_in_type fp_rnd_i;
  fp_rnd_out_type fp_rnd_o;

  fp_cvt_f2i_in_type fp_cvt_f2i_i;
  fp_cvt_f2i_out_type fp_cvt_f2i_o;
  fp_cvt_i2f_in_type fp_cvt_i2f_i;
  fp_cvt_i2f_out_type fp_cvt_i2f_o;

  fp_mac_in_type fp_mac_i;
  fp_mac_out_type fp_mac_o;
  fp_fdiv_in_type fp_fdiv_i;
  fp_fdiv_out_type fp_fdiv_o;

  lzc_32 lzc_32_comp_1
  (
  .a ( lzc1_32_i.a ),
  .c ( lzc1_32_o.c ),
  .v ( lzc1_32_o.v )
  );

  lzc_32 lzc_32_comp_2
  (
  .a ( lzc2_32_i.a ),
  .c ( lzc2_32_o.c ),
  .v ( lzc2_32_o.v )
  );

  lzc_32 lzc_32_comp_3
  (
  .a ( lzc3_32_i.a ),
  .c ( lzc3_32_o.c ),
  .v ( lzc3_32_o.v )
  );

  lzc_32 lzc_32_comp_4
  (
  .a ( lzc4_32_i.a ),
  .c ( lzc4_32_o.c ),
  .v ( lzc4_32_o.v )
  );

  lzc_128 lzc_128_comp
  (
  .a ( lzc_128_i.a ),
  .c ( lzc_128_o.c ),
  .v ( lzc_128_o.v )
  );

  fp_ext fp_ext_comp_1
  (
  .fp_ext_i ( fp_ext1_i	),
  .fp_ext_o ( fp_ext1_o	),
  .lzc_o ( lzc1_32_o	),
  .lzc_i ( lzc1_32_i )
  );

  fp_ext fp_ext_comp_2
  (
  .fp_ext_i ( fp_ext2_i	),
  .fp_ext_o ( fp_ext2_o	),
  .lzc_o ( lzc2_32_o	),
  .lzc_i ( lzc2_32_i )
  );

  fp_ext fp_ext_comp_3
  (
  .fp_ext_i ( fp_ext3_i	),
  .fp_ext_o ( fp_ext3_o	),
  .lzc_o ( lzc3_32_o	),
  .lzc_i ( lzc3_32_i )
  );

  fp_cmp fp_cmp_comp
  (
  .fp_cmp_i ( fp_cmp_i ),
  .fp_cmp_o ( fp_cmp_o )
  );

  fp_max fp_max_comp
  (
  .fp_max_i ( fp_max_i ),
  .fp_max_o ( fp_max_o )
  );

  fp_sgnj fp_sgnj_comp
  (
  .fp_sgnj_i ( fp_sgnj_i ),
  .fp_sgnj_o ( fp_sgnj_o )
  );

  fp_cvt fp_cvt_comp
  (
  .fp_cvt_f2i_i (fp_cvt_f2i_i),
  .fp_cvt_f2i_o (fp_cvt_f2i_o),
  .fp_cvt_i2f_i (fp_cvt_i2f_i),
  .fp_cvt_i2f_o (fp_cvt_i2f_o),
  .lzc_o (lzc4_32_o),
  .lzc_i (lzc4_32_i)
  );

  fp_fma fp_fma_comp
  (
  .reset ( rst ),
  .clock ( clk ),
  .fp_fma_i ( fp_fma_i ),
  .fp_fma_o ( fp_fma_o ),
  .lzc_o ( lzc_128_o ),
  .lzc_i ( lzc_128_i )
  );

  fp_mac fp_mac_comp
  (
  .reset (rst),
  .clock (clk),
  .fp_mac_i (fp_mac_i),
  .fp_mac_o (fp_mac_o)
  );

  fp_fdiv fp_fdiv_comp
  (
  .reset (rst),
  .clock (clk),
  .fp_fdiv_i (fp_fdiv_i),
  .fp_fdiv_o (fp_fdiv_o),
  .fp_mac_o (fp_mac_o),
  .fp_mac_i (fp_mac_i)
  );

  fp_rnd fp_rnd_comp
  (
  .fp_rnd_i (fp_rnd_i),
  .fp_rnd_o (fp_rnd_o)
  );

  fp_exe fp_exe_comp
  (
  .fp_exe_i ( fp_execute_in ),
  .fp_exe_o ( fp_execute_out ),
  .fp_ext1_o ( fp_ext1_o ),
  .fp_ext1_i ( fp_ext1_i ),
  .fp_ext2_o ( fp_ext2_o ),
  .fp_ext2_i ( fp_ext2_i ),
  .fp_ext3_o ( fp_ext3_o ),
  .fp_ext3_i ( fp_ext3_i ),
  .fp_cmp_o ( fp_cmp_o ),
  .fp_cmp_i ( fp_cmp_i ),
  .fp_max_o ( fp_max_o ),
  .fp_max_i ( fp_max_i ),
  .fp_sgnj_o ( fp_sgnj_o ),
  .fp_sgnj_i ( fp_sgnj_i ),
  .fp_cvt_f2i_i (fp_cvt_f2i_i),
  .fp_cvt_f2i_o (fp_cvt_f2i_o),
  .fp_cvt_i2f_i (fp_cvt_i2f_i),
  .fp_cvt_i2f_o (fp_cvt_i2f_o),
  .fp_fma_o ( fp_fma_o ),
  .fp_fma_i ( fp_fma_i ),
  .fp_fdiv_o (fp_fdiv_o),
  .fp_fdiv_i (fp_fdiv_i),
  .fp_rnd_o ( fp_rnd_o ),
  .fp_rnd_i ( fp_rnd_i )
  );

endmodule

module fpu
#(
  parameter fpu_enable = 1
)
(
  input logic rst,
  input logic clk,
  input fpu_in_type fpu_in,
  output fpu_out_type fpu_out
);
  timeunit 1ns;
  timeprecision 1ps;

  generate

    if (fpu_enable == 1) begin

      fpu_decode fpu_decode_comp
      (
        .fp_decode_in (fpu_in.fp_decode_in),
        .fp_decode_out (fpu_out.fp_decode_out)
      );

      fpu_execute fpu_execute_comp
      (
        .rst (rst),
        .clk (clk),
        .fp_execute_in (fpu_in.fp_execute_in),
        .fp_execute_out (fpu_out.fp_execute_out)
      );

      fpu_register fpu_register_comp
      (
        .rst (rst),
        .clk (clk),
        .fp_register_rin (fpu_in.fp_register_rin),
        .fp_register_win (fpu_in.fp_register_win),
        .fp_register_out (fpu_out.fp_register_out)
      );

      fpu_forwarding fpu_forwarding_comp
      (
        .fp_forwarding_rin (fpu_in.fp_forwarding_rin),
        .fp_forwarding_ein (fpu_in.fp_forwarding_ein),
        .fp_forwarding_out (fpu_out.fp_forwarding_out)
      );

    end

  endgenerate

endmodule
