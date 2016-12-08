(*
 * Copyright 2016, NTU
 *
 * This software may be distributed and modified according to the terms of
 * the BSD 2-Clause license. Note that NO WARRANTY is provided.
 * See "LICENSE_BSD2.txt" for details.
 *
 * Author: Zhe Hou, David Sanan.
 *)

header {* SPARC instruction model *}
theory Sparc_Instruction
imports Main Sparc_Types Sparc_State "~~/src/HOL/Eisbach/Eisbach_Tools"
begin
text{*
This theory provides a formal model for assembly instruction to be executed in the model.

An instruction is defined as a tuple composed of a @{term sparc_operation} element,
defining the operation the instruction carries out, and a list of operands 
@{term inst_operand}. @{term inst_operand} can be a user register @{term user_reg} 
or a memory address @{term mem_add_type}.
*}
datatype inst_operand = 
W5 word5
|W30 word30
|W22 word22
|Cond  word4
|Flag word1
|Asi asi_type
|Simm13 word13 
|Opf word9
|Imm7 word7

primrec get_operand_w5::"inst_operand \<Rightarrow> word5"
where "get_operand_w5 (W5 r) = r"

primrec get_operand_w30::"inst_operand \<Rightarrow> word30"
where "get_operand_w30 (W30 r) = r"

primrec get_operand_w22::"inst_operand \<Rightarrow> word22"
where "get_operand_w22 (W22 r) = r"

primrec get_operand_cond::"inst_operand \<Rightarrow> word4"
where "get_operand_cond (Cond r) = r"

primrec get_operand_flag::"inst_operand \<Rightarrow> word1"
where "get_operand_flag (Flag r) = r"

primrec get_operand_asi::"inst_operand \<Rightarrow> asi_type"
where "get_operand_asi (Asi r) = r"

primrec get_operand_simm13::"inst_operand \<Rightarrow> word13"
where "get_operand_simm13 (Simm13 r) = r"

primrec get_operand_opf::"inst_operand \<Rightarrow> word9"
where "get_operand_opf (Opf r) = r"

primrec get_operand_imm7:: "inst_operand \<Rightarrow> word7"
where "get_operand_imm7 (Imm7 r) = r"

type_synonym instruction = "(sparc_operation \<times> inst_operand list)"

definition get_op::"word32 \<Rightarrow> int"
where "get_op w \<equiv> uint (w >> 30)"

definition get_op2::"word32 \<Rightarrow> int"
where "get_op2 w \<equiv> 
  let mask_op2 = 0b00000001110000000000000000000000 in
  uint ((bitAND mask_op2 w) >> 22)"

definition get_op3::"word32 \<Rightarrow> int"
where "get_op3 w \<equiv> 
  let mask_op3 = 0b00000001111110000000000000000000 in 
  uint ((bitAND mask_op3 w) >> 19)"

definition get_disp30::"word32 \<Rightarrow> int"
where "get_disp30 w \<equiv> 
  let mask_disp30 = 0b00111111111111111111111111111111 in
  uint (bitAND mask_disp30 w)"

definition get_a::"word32 \<Rightarrow> int"
where "get_a w \<equiv>
  let mask_a = 0b00100000000000000000000000000000 in
  uint ((bitAND mask_a w) >> 29)"

definition get_cond::"word32 \<Rightarrow> int"
where "get_cond w \<equiv>
  let mask_cond = 0b00011110000000000000000000000000 in
  uint ((bitAND mask_cond w) >> 25)"

definition get_disp_imm22::"word32 \<Rightarrow> int"
where "get_disp_imm22 w \<equiv>
  let mask_disp_imm22 = 0b00000000001111111111111111111111 in
  uint (bitAND mask_disp_imm22 w)"

definition get_rd::"word32 \<Rightarrow> int"
where "get_rd w \<equiv>
  let mask_rd = 0b00111110000000000000000000000000 in
  uint ((bitAND mask_rd w) >> 25)"

definition get_rs1::"word32 \<Rightarrow> int"
where "get_rs1 w \<equiv>
  let mask_rs1 = 0b00000000000001111100000000000000 in
  uint ((bitAND mask_rs1 w) >> 14)"

definition get_i::"word32 \<Rightarrow> int"
where "get_i w \<equiv>
  let mask_i = 0b00000000000000000010000000000000 in
  uint ((bitAND mask_i w) >> 13)"

definition get_opf::"word32 \<Rightarrow> int"
where "get_opf w \<equiv> 
  let mask_opf = 0b00000000000000000011111111100000 in
  uint ((bitAND mask_opf w) >> 5)"

definition get_rs2::"word32 \<Rightarrow> int"
where "get_rs2 w \<equiv>
  let mask_rs2 = 0b00000000000000000000000000011111 in
  uint (bitAND mask_rs2 w)"

definition get_simm13::"word32 \<Rightarrow> int"
where "get_simm13 w \<equiv>
  let mask_simm13 = 0b00000000000000000001111111111111 in
  uint (bitAND mask_simm13 w)"

definition get_asi::"word32 \<Rightarrow> int"
where "get_asi w \<equiv>
  let mask_asi = 0b00000000000000000001111111100000 in
  uint ((bitAND mask_asi w) >> 5)"

definition get_trap_cond:: "word32 \<Rightarrow> int"
where "get_trap_cond w \<equiv>
  let mask_cond = 0b00011110000000000000000000000000 in
  uint ((bitAND mask_cond w) >> 25)"

definition get_trap_imm7:: "word32 \<Rightarrow> int"
where "get_trap_imm7 w \<equiv>
  let mask_imm7 = 0b00000000000000000000000001111111 in
  uint (bitAND mask_imm7 w)"

definition parse_instr_f1::"word32 \<Rightarrow> 
  (Exception list + instruction)"
where (* CALL, with a single operand disp30+"00" *)
"parse_instr_f1 w \<equiv>                                                     
  Inr (call_type CALL,[W30 (word_of_int (get_disp30 w))])"

definition parse_instr_f2::"word32 \<Rightarrow> 
  (Exception list + instruction)"
where "parse_instr_f2 w \<equiv>
  let op2 = get_op2 w in
  if op2 = uint(0b100::word3) then (* SETHI or NOP *)
    let rd = get_rd w in
    let imm22 = get_disp_imm22 w in
    if rd = 0 \<and> imm22 = 0 then (* NOP *)
      Inr (nop_type NOP,[])
    else (* SETHI, with operands [imm22,rd] *)
      Inr (sethi_type SETHI,[(W22 (word_of_int imm22)),
                   (W5 (word_of_int rd))])
  else if op2 = uint(0b010::word3) then (* Bicc, with operands [a,disp22]  *)
    let cond = get_cond w in
    let flaga = Flag (word_of_int (get_a w)) in
    let disp22 = W22 (word_of_int (get_disp_imm22 w)) in
    if cond = uint(0b0001::word4) then (* BE *)
      Inr (bicc_type BE,[flaga,disp22])
    else if cond = uint(0b1001::word4) then (* BNE *)
      Inr (bicc_type BNE,[flaga,disp22])
    else if cond = uint(0b1100::word4) then (* BGU *)
      Inr (bicc_type BGU,[flaga,disp22])
    else if cond = uint(0b0010::word4) then (* BLE *)
      Inr (bicc_type BLE,[flaga,disp22])
    else if cond = uint(0b0011::word4) then (* BL *)
      Inr (bicc_type BL,[flaga,disp22])
    else if cond = uint(0b1011::word4) then (* BGE *)
      Inr (bicc_type BGE,[flaga,disp22])
    else if cond = uint(0b0110::word4) then (* BNEG *)
      Inr (bicc_type BNEG,[flaga,disp22])
    else if cond = uint(0b1010::word4) then (* BG *)
      Inr (bicc_type BG,[flaga,disp22])
    else if cond = uint(0b0101::word4) then (* BCS *)
      Inr (bicc_type BCS,[flaga,disp22])
    else if cond = uint(0b0100::word4) then (* BLEU *)
      Inr (bicc_type BLEU,[flaga,disp22])
    else if cond = uint(0b1101::word4) then (* BCC *)
      Inr (bicc_type BCC,[flaga,disp22])
    else if cond = uint(0b1000::word4) then (* BA *)
      Inr (bicc_type BA,[flaga,disp22])
    else if cond = uint(0b0000::word4) then (* BN *)
      Inr (bicc_type BN,[flaga,disp22])
    else if cond = uint(0b1110::word4) then (* BPOS *)
      Inr (bicc_type BPOS,[flaga,disp22])
    else if cond = uint(0b1111::word4) then (* BVC *)
      Inr (bicc_type BVC,[flaga,disp22])
    else if cond = uint(0b0111::word4) then (* BVS *)
      Inr (bicc_type BVS,[flaga,disp22])
    else Inl [invalid_cond_f2]
  else Inl [invalid_op2_f2]
"

text {* We don't consider floating-point operations, 
        so we don't consider the third type of format 3. *}
definition parse_instr_f3::"word32 \<Rightarrow> (Exception list + instruction)"
where "parse_instr_f3 w \<equiv>
  let this_op = get_op w in
  let rd = get_rd w in
  let op3 = get_op3 w in
  let rs1 = get_rs1 w in
  let flagi = get_i w in
  let asi = get_asi w in
  let rs2 = get_rs2 w in
  let simm13 = get_simm13 w in
  if this_op = uint(0b11::word2) then (* Load and Store *)
  (* If an instruction accesses alternative space but flagi = 1, 
     may need to throw a trap. *)
    if op3 = uint(0b001001::word6) then (* LDSB *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDSB,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDSB,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011001::word6) then (* LDSBA *) 
       Inr (load_store_type LDSBA,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (Asi (word_of_int asi)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b001010::word6) then (* LDSH *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDSH,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDSH,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011010::word6) then (* LDSHA *) 
       Inr (load_store_type LDSHA,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (Asi (word_of_int asi)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b000001::word6) then (* LDUB *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDUB,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDUB,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010001::word6) then (* LDUBA *) 
       Inr (load_store_type LDUBA,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (Asi (word_of_int asi)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b000010::word6) then (* LDUH *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDUH,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDUH,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010010::word6) then (* LDUHA *) 
       Inr (load_store_type LDUHA,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (Asi (word_of_int asi)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b000000::word6) then (* LD *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LD,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (Simm13 (word_of_int simm13)),
                      (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LD,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (W5 (word_of_int rs2)),
                      (W5 (word_of_int rd))])
    else if op3 = uint(0b010000::word6) then (* LDA *)
       Inr (load_store_type LDA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000011::word6) then (* LDD *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010011::word6) then (* LDDA *) 
       Inr (load_store_type LDDA,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (Asi (word_of_int asi)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b001101::word6) then (* LDSTUB *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type LDSTUB,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (Simm13 (word_of_int simm13)),
                      (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type LDSTUB,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (W5 (word_of_int rs2)),
                      (W5 (word_of_int rd))])
    else if op3 = uint(0b011101::word6) then (* LDSTUBA *)
       Inr (load_store_type LDSTUBA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000101::word6) then (* STB *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type STB,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type STB,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010101::word6) then (* STBA *)
       Inr (load_store_type STBA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000110::word6) then (* STH *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type STH,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type STH,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010110::word6) then (* STHA *)
       Inr (load_store_type STHA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000100::word6) then (* ST *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type ST,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (Simm13 (word_of_int simm13)),
                      (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type ST,[(Flag (word_of_int flagi)),
                      (W5 (word_of_int rs1)),
                      (W5 (word_of_int rs2)),
                      (W5 (word_of_int rd))])
    else if op3 = uint(0b010100::word6) then (* STA *)
       Inr (load_store_type STA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000111::word6) then (* STD *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type STD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type STD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010111::word6) then (* STDA *)
       Inr (load_store_type STDA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b001111::word6) then (* SWAP *)
      if flagi = 1 then (* Operant list is [i,rs1,simm13,rd] *)
         Inr (load_store_type SWAP,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
      else (* Operant list is [i,rs1,rs2,rd] *)
         Inr (load_store_type SWAP,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b011111::word6) then (* SWAPA *)
       Inr (load_store_type SWAPA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (Asi (word_of_int asi)),
                       (W5 (word_of_int rd))])
    else Inl [invalid_op3_f3_op11]
  else if this_op = uint(0b10::word2) then (* Others *)
    if op3 = uint(0b111000::word6) then (* JMPL *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (ctrl_type JMPL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (ctrl_type JMPL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b111001::word6) then (* RETT *)
      if flagi = 0 then (* return [i,rs1,rs2] *)
         Inr (ctrl_type RETT,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2))])
      else (* return [i,rs1,simm13]*)
         Inr (ctrl_type RETT,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13))])
    (* The following are Read and Write instructions, 
       only return [rs1,rd] as operand. *)
    else if op3 = uint(0b101000::word6) \<and> rs1 \<noteq> 0 then (* RDASR *)
      if rs1 = uint(0b01111::word6) \<and> rd = 0 then (* STBAR is a special case of RDASR *)
        Inr (load_store_type STBAR,[])
      else Inr (sreg_type RDASR,[(W5 (word_of_int rs1)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b101000::word6) \<and> rs1 = 0 then (* RDY *)
       Inr (sreg_type RDY,[(W5 (word_of_int rs1)),
                     (W5 (word_of_int rd))])
    else if op3 = uint(0b101001::word6) then (* RDPSR *)
       Inr (sreg_type RDPSR,[(W5 (word_of_int rs1)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b101010::word6) then (* RDWIM *)
       Inr (sreg_type RDWIM,[(W5 (word_of_int rs1)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b101011::word6) then (* RDTBR *)
       Inr (sreg_type RDTBR,[(W5 (word_of_int rs1)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b110000::word6) \<and> rd \<noteq> 0 then (* WRASR *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (sreg_type WRASR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd] *)
         Inr (sreg_type WRASR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b110000::word6) \<and> rd = 0 then (* WRY *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (sreg_type WRY,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd] *)
         Inr (sreg_type WRY,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b110001::word6) then (* WRPSR *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (sreg_type WRPSR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd] *)
         Inr (sreg_type WRPSR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b110010::word6) then (* WRWIM *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (sreg_type WRWIM,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd] *)
         Inr (sreg_type WRWIM,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b110011::word6) then (* WRTBR *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (sreg_type WRTBR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd] *)
         Inr (sreg_type WRTBR,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    (* FLUSH instruction *)
    else if op3 = uint(0b111011::word6) then (* FLUSH *)
      if flagi = 0 then (* return [1,rs1,rs2] *)
         Inr (load_store_type FLUSH,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2))])
      else (* return [i,rs1,simm13] *)
         Inr (load_store_type FLUSH,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13))])
    (* The following are arithmetic instructions. *)
    else if op3 = uint(0b000001::word6) then (* AND *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ANDs,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ANDs,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010001::word6) then (* ANDcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ANDcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ANDcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b000101::word6) then (* ANDN *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ANDN,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ANDN,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010101::word6) then (* ANDNcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ANDNcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (W5 (word_of_int rs2)),
                          (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ANDNcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (Simm13 (word_of_int simm13)),
                          (W5 (word_of_int rd))])
    else if op3 = uint(0b000010::word6) then (* OR *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ORs,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ORs,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010010::word6) then (* ORcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ORcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ORcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b000110::word6) then (* ORN *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ORN,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ORN,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010110::word6) then (* ORNcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type ORNcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type ORNcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000011::word6) then (* XORs *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type XORs,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type XORs,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010011::word6) then (* XORcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type XORcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type XORcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000111::word6) then (* XNOR *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type XNOR,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type XNOR,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b010111::word6) then (* XNORcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (logic_type XNORcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (logic_type XNORcc,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b100101::word6) then (* SLL *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (shift_type SLL,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,shcnt,rd]*)
        let shcnt = rs2 in
         Inr (shift_type SLL,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int shcnt)),
                       (W5 (word_of_int rd))])
    else if op3 = uint (0b100110::word6) then (* SRL *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (shift_type SRL,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,shcnt,rd]*)
        let shcnt = rs2 in
         Inr (shift_type SRL,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int shcnt)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b100111::word6) then (* SRA *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (shift_type SRA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,shcnt,rd]*)
        let shcnt = rs2 in
         Inr (shift_type SRA,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int shcnt)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b000000::word6) then (* ADD *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type ADD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type ADD,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010000::word6) then (* ADDcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type ADDcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type ADDcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b001000::word6) then (* ADDX *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type ADDX,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type ADDX,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011000::word6) then (* ADDXcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type ADDXcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type ADDXcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b100000::word6) then (* TADDcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type TADDcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type TADDcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b100010::word6) then (* TADDccTV *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type TADDccTV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type TADDccTV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b000100::word6) then (* SUB *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SUB,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (W5 (word_of_int rs2)),
                       (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SUB,[(Flag (word_of_int flagi)),
                       (W5 (word_of_int rs1)),
                       (Simm13 (word_of_int simm13)),
                       (W5 (word_of_int rd))])
    else if op3 = uint(0b010100::word6) then (* SUBcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SUBcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (W5 (word_of_int rs2)),
                         (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SUBcc,[(Flag (word_of_int flagi)),
                         (W5 (word_of_int rs1)),
                         (Simm13 (word_of_int simm13)),
                         (W5 (word_of_int rd))])
    else if op3 = uint(0b001100::word6) then (* SUBX *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SUBX,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SUBX,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011100::word6) then (* SUBXcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SUBXcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SUBXcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b100001::word6) then (* TSUBcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type TSUBcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type TSUBcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b100011::word6) then (* TSUBccTV *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type TSUBccTV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type TSUBccTV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b100100::word6) then (* MULScc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type MULScc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type MULScc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b001010::word6) then (* UMUL *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type UMUL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type UMUL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011010::word6) then (* UMULcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type UMULcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type UMULcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b001011::word6) then (* SMUL *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SMUL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SMUL,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011011::word6) then (* SMULcc*)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SMULcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (W5 (word_of_int rs2)),
                          (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SMULcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (Simm13 (word_of_int simm13)),
                          (W5 (word_of_int rd))])
    else if op3 = uint(0b001110::word6) then (* UDIV *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type UDIV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type UDIV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011110::word6) then (* UDIVcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type UDIVcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (W5 (word_of_int rs2)),
                          (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type UDIVcc,[(Flag (word_of_int flagi)),
                          (W5 (word_of_int rs1)),
                          (Simm13 (word_of_int simm13)),
                          (W5 (word_of_int rd))])
    else if op3 = uint(0b001111::word6) then (* SDIV *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SDIV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SDIV,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b011111::word6) then (* SDIVcc *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (arith_type SDIVcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (arith_type SDIVcc,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b111100::word6) then (* SAVE *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (ctrl_type SAVE,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (W5 (word_of_int rs2)),
                        (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (ctrl_type SAVE,[(Flag (word_of_int flagi)),
                        (W5 (word_of_int rs1)),
                        (Simm13 (word_of_int simm13)),
                        (W5 (word_of_int rd))])
    else if op3 = uint(0b111101::word6) then (* RESTORE *)
      if flagi = 0 then (* return [i,rs1,rs2,rd] *)
         Inr (ctrl_type RESTORE,[(Flag (word_of_int flagi)),
                           (W5 (word_of_int rs1)),
                           (W5 (word_of_int rs2)),
                           (W5 (word_of_int rd))])
      else (* return [i,rs1,simm13,rd]*)
         Inr (ctrl_type RESTORE,[(Flag (word_of_int flagi)),
                           (W5 (word_of_int rs1)),
                           (Simm13 (word_of_int simm13)),
                           (W5 (word_of_int rd))])
    else if op3 = uint(0b111010::word6) then (* Ticc *)
      let trap_cond = get_trap_cond w in
      let trap_imm7 = get_trap_imm7 w in
      if trap_cond = uint(0b1000::word4) then (* TA *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TA,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TA,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0000::word4) then (* TN *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TN,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TN,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1001::word4) then (* TNE *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TNE,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TNE,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0001::word4) then (* TE *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TE,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TE,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1010::word4) then (* TG *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TG,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TG,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0010::word4) then (* TLE *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TLE,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TLE,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1011::word4) then (* TGE *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TGE,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TGE,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0011::word4) then (* TL *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TL,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TL,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1100::word4) then (* TGU *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TGU,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TGU,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0100::word4) then (* TLEU *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TLEU,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TLEU,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1101::word4) then (* TCC *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TCC,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TCC,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0101::word4) then (* TCS *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TCS,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TCS,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1110::word4) then (* TPOS *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TPOS,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TPOS,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0110::word4) then (* TNEG *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TNEG,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TNEG,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b1111::word4) then (* TVC *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TVC,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TVC,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else if trap_cond = uint(0b0111::word4) then (* TVS *)
        if flagi = 0 then (* return [i,rs1,rs2] *)
          Inr (ticc_type TVS,[(Flag (word_of_int flagi)),
                   (W5 (word_of_int rs1)),
                   (W5 (word_of_int rs2))])
        else (* return [i,rs1,trap_imm7] *)
          Inr (ticc_type TVS,[(Flag (word_of_int flagi)),
                    (W5 (word_of_int rs1)),
                    (Imm7 (word_of_int trap_imm7))])
      else Inl [invalid_trap_cond]     
    else Inl [invalid_op3_f3_op10]
  else Inl [invalid_op_f3]
"

text {* Read the word32 value from the Program Counter in the current state. 
        Find the instruction in the memory address of the word32 value. 
        Return a word32 value of the insturction. *}
definition fetch_instruction::"('a) sparc_state \<Rightarrow>
  (Exception list + word32)"
where "fetch_instruction s \<equiv> 
  (* pc_val is the 32-bit memory address of the instruction. *)
  let pc_val = cpu_reg_val PC s;
      psr_val = cpu_reg_val PSR s;
      s_val = get_S psr_val;
      asi = if s_val = 0 then word_of_int 8 else word_of_int 9
  in
  (* Check if pc_val is aligned to 4-byte (32-bit) boundary. 
     That is, check if the least significant two bits of 
     pc_val are 0s. *)
    if uint(bitAND (0b00000000000000000000000000000011) pc_val) = 0 then
    (* Get the 32-bit value from the address of pc_val 
       to the address of pc_val+3 *)
        let (mem_result,n_s) = memory_read asi pc_val s in
        case mem_result of 
         None \<Rightarrow> Inl [fetch_instruction_error]
        |Some v \<Rightarrow> Inr v
    else Inl [fetch_instruction_error]
"

text {* Decode the word32 value of an instruction into 
        the name of the instruction and its operands. *}
definition decode_instruction::"word32 \<Rightarrow> 
  Exception list + instruction"
where "decode_instruction w \<equiv> 
  let this_op = get_op w in 
  if this_op = uint(0b01::word2) then (* Instruction format 1 *)
    parse_instr_f1 w
  else if this_op = uint(0b00::word2) then (* Instruction format 2 *)
    parse_instr_f2 w
  else (* op = 11 0r 10, instructionrett format 3 *)
    parse_instr_f3 w
"

text {* Get the current window from the PSR *}
definition get_curr_win::"unit \<Rightarrow> ('a,('a::len0 window_size)) sparc_state_monad"
where "get_curr_win _ \<equiv> 
  do
    curr_win \<leftarrow> gets (\<lambda>s. (ucast (get_CWP (cpu_reg_val PSR s))));
    return curr_win 
  od"

text {* Operational semantics for CALL *}
definition call_instr::"instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "call_instr instr \<equiv>
  let op_list = snd instr;
      mem_addr = ((ucast (get_operand_w30 (op_list!0)))::word32) << 2
  in
  do
    curr_win \<leftarrow> get_curr_win();
    pc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PC s));
    npc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val nPC s));
    write_reg pc_val curr_win (word_of_int 15);
    write_cpu npc_val PC;
    write_cpu (pc_val + mem_addr) nPC;
    return ()
  od"

text{* Evaluate icc based on the bits N, Z, V, C in PSR 
       and the type of branching instruction. 
       See Sparcv8 manual Page 178. *}
definition eval_icc::"sparc_operation \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> int"
where
"eval_icc instr_name n_val z_val v_val c_val \<equiv>
    if instr_name = bicc_type BNE then
      if z_val = 0 then 1 else 0
    else if instr_name = bicc_type BE then 
      if z_val = 1 then 1 else 0
    else if instr_name = bicc_type BG then
      if (bitOR z_val (n_val XOR v_val)) = 0 then 1 else 0
    else if instr_name = bicc_type BLE then
      if (bitOR z_val (n_val XOR v_val)) = 1 then 1 else 0
    else if instr_name = bicc_type BGE then
      if (n_val XOR v_val) = 0 then 1 else 0
    else if instr_name = bicc_type BL then
      if (n_val XOR v_val) = 1 then 1 else 0
    else if instr_name = bicc_type BGU then
      if (c_val = 0 \<and> z_val = 0) then 1 else 0
    else if instr_name = bicc_type BLEU then
      if (c_val = 1 \<or> z_val = 1) then 1 else 0
    else if instr_name = bicc_type BCC then
      if c_val = 0 then 1 else 0
    else if instr_name = bicc_type BCS then
      if c_val = 1 then 1 else 0
    else if instr_name = bicc_type BNEG then
      if n_val = 1 then 1 else 0
    else if instr_name = bicc_type BA then 1
    else if instr_name = bicc_type BN then 0
    else if instr_name = bicc_type BPOS then
      if n_val = 0 then 1 else 0
    else if instr_name = bicc_type BVC then
      if v_val = 0 then 1 else 0
    else if instr_name = bicc_type BVS then
      if v_val = 1 then 1 else 0
    else -1
"

definition branch_instr_sub1:: "sparc_operation \<Rightarrow> ('a) sparc_state \<Rightarrow> int"
where "branch_instr_sub1 instr_name s \<equiv>
  let n_val = get_icc_N ((cpu_reg s) PSR);
      z_val = get_icc_Z ((cpu_reg s) PSR);
      v_val = get_icc_V ((cpu_reg s) PSR);
      c_val = get_icc_C ((cpu_reg s) PSR)
  in
  eval_icc instr_name n_val z_val v_val c_val"

text {* Operational semantics for Branching insturctions. 
        Return exception or a bool value for annulment. 
        If the bool value is 1, then the delay instruciton 
        is not executed, otherwise the delay instruction
        is executed. *}
definition branch_instr::"instruction \<Rightarrow> ('a,unit) sparc_state_monad"
where "branch_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      disp22 = get_operand_w22 (op_list!1);
      flaga = get_operand_flag (op_list!0)
  in
  do
    icc_val \<leftarrow> gets( \<lambda>s. (branch_instr_sub1 instr_name s));
    npc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val nPC s));
    pc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PC s));
    write_cpu npc_val PC;    
    if icc_val = 1 then 
      do
        write_cpu (pc_val + (sign_ext24 (((ucast(disp22))::word24) << 2))) nPC;
        if (instr_name = bicc_type BA) \<and> (flaga = 1) then 
          do
            set_annul True;
            return ()
          od
        else
          return ()
      od
    else (* icc_val = 0 *) 
      do
        write_cpu (npc_val + 4) nPC;
        if flaga = 1 then
          do                
            set_annul True;
            return ()
          od
        else return ()
      od
  od"

text {* Operational semantics for NOP *}
definition nop_instr::"instruction \<Rightarrow> ('a,unit) sparc_state_monad"
where "nop_instr instr \<equiv> return ()"

text {* Operational semantics for SETHI *}
definition sethi_instr::"instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "sethi_instr instr \<equiv>
  let op_list = snd instr;
      imm22 = get_operand_w22 (op_list!0); 
      rd = get_operand_w5 (op_list!1)
  in
  if rd \<noteq> 0 then
    do
      curr_win \<leftarrow> get_curr_win();
      write_reg (((ucast(imm22))::word32) << 10) curr_win rd;
      return ()
    od
  else return ()
"

text {* Get operand2 based on the flag i, rs1, rs2, and simm13. 
        If i = 0 then operand2 = r[rs2],
        else operand2 = sign\_ext13(simm13). 
        op\_list should be [i,rs1,rs2,...] or [i,rs1,simm13,...]. *}
definition get_operand2::"inst_operand list \<Rightarrow> ('a::len0) sparc_state
  \<Rightarrow> virtua_address"
where "get_operand2 op_list s \<equiv>
  let flagi = get_operand_flag (op_list!0);
      curr_win = ucast (get_CWP (cpu_reg_val PSR s))
  in
  if flagi = 0 then
    let rs2 = get_operand_w5 (op_list!2);
        rs2_val = user_reg_val curr_win rs2 s
    in rs2_val
  else
    let ext_simm13 = sign_ext13 (get_operand_simm13 (op_list!2)) in
    ext_simm13
"

text {* Get operand2\_val based on the flag i, rs1, rs2, and simm13. 
        If i = 0 then operand2\_val = uint r[rs2],
        else operand2\_val = sint sign\_ext13(simm13). 
        op\_list should be [i,rs1,rs2,...] or [i,rs1,simm13,...].         
*}
definition get_operand2_val::"inst_operand list \<Rightarrow> ('a::len0) sparc_state \<Rightarrow> int"
where "get_operand2_val op_list s \<equiv>
  let flagi = get_operand_flag (op_list!0);
      curr_win = ucast (get_CWP (cpu_reg_val PSR s))
  in
  if flagi = 0 then
    let rs2 = get_operand_w5 (op_list!2);
        rs2_val = user_reg_val curr_win rs2 s
    in sint rs2_val
  else
    let ext_simm13 = sign_ext13 (get_operand_simm13 (op_list!2)) in
    sint ext_simm13
"

text {* Get the address based on the flag i, rs1, rs2, and simm13. 
        If i = 0 then addr = r[rs1] + r[rs2],
        else addr = r[rs1] + sign\_ext13(simm13). 
        op\_list should be [i,rs1,rs2,...] or [i,rs1,simm13,...]. *}
definition get_addr::"inst_operand list \<Rightarrow> ('a::len0) sparc_state \<Rightarrow> virtua_address"
where "get_addr op_list s \<equiv>
  let rs1 = get_operand_w5 (op_list!1);
      curr_win = ucast (get_CWP (cpu_reg_val PSR s));
      rs1_val = user_reg_val curr_win rs1 s;
      op2 = get_operand2 op_list s
  in
  (rs1_val + op2)
"

text {* Operational semantics for JMPL *}
definition jmpl_instr::"instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "jmpl_instr instr \<equiv>
  let op_list = snd instr;
      rd = get_operand_w5 (op_list!3)      
  in
  do
    curr_win \<leftarrow> get_curr_win();
    jmp_addr \<leftarrow> gets (\<lambda>s. (get_addr op_list s));
    if (bitAND jmp_addr 0b00000000000000000000000000000011) \<noteq> 0 then
      do
        raise_trap mem_address_not_aligned;
        return ()
      od
    else
      do
        rd_next_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then
                                    (cpu_reg_val PC s)
                                  else 
                                    user_reg_val curr_win rd s));
        write_reg rd_next_val curr_win rd;
        npc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val nPC s));
        write_cpu npc_val PC;
        write_cpu jmp_addr nPC;
        return ()
      od
  od"

text {* Operational semantics for RETT *}
definition rett_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "rett_instr instr \<equiv>
  let op_list = snd instr in
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    curr_win \<leftarrow> gets (\<lambda>s. (get_CWP (cpu_reg_val PSR s)));
    new_cwp \<leftarrow> gets (\<lambda>s. (word_of_int (((uint curr_win) + 1) mod NWINDOWS)));
    new_cwp_int \<leftarrow> gets (\<lambda>s. ((uint curr_win) + 1) mod NWINDOWS);
    addr \<leftarrow> gets (\<lambda>s. (get_addr op_list s));
    et_val \<leftarrow> gets (\<lambda>s. ((ucast (get_ET psr_val))::word1));
    s_val \<leftarrow> gets (\<lambda>s. ((ucast (get_S psr_val))::word1));
    ps_val \<leftarrow> gets (\<lambda>s. ((ucast (get_PS psr_val))::word1));
    wim_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val WIM s));
    npc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val nPC s));
    if et_val = 1 then
      if s_val = 0 then 
        do
          raise_trap privileged_instruction;
          return ()
        od
      else
        do
          raise_trap illegal_instruction;
          return ()
        od
    else if s_val = 0 then
      do 
        write_cpu_tt (0b00000011::word8);
        set_exe_mode False;
        set_err_mode True;
        raise_trap privileged_instruction;
        fail ()
      od
    else if (get_WIM_bit (nat new_cwp_int) wim_val) \<noteq> 0 then
      do
        write_cpu_tt (0b00000110::word8);
        set_exe_mode False;
        set_err_mode True;
        raise_trap window_underflow;
        fail ()
      od
    else if (bitAND addr (0b00000000000000000000000000000011::word32)) \<noteq> 0 then
      do
        write_cpu_tt (0b00000111::word8);
        set_exe_mode False;
        set_err_mode True;
        raise_trap mem_address_not_aligned;
        fail ()
      od
    else
      do
        write_cpu npc_val PC;
        write_cpu addr nPC;
        new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_rett new_cwp 1 ps_val psr_val));
        write_cpu new_psr_val PSR;
        return ()
      od
  od"

definition save_retore_sub1 :: "word32 \<Rightarrow> word5 \<Rightarrow> word5 \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "save_retore_sub1 result new_cwp rd \<equiv>
  do
  psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
  new_psr_val \<leftarrow> gets (\<lambda>s. (update_CWP new_cwp psr_val));
  write_cpu new_psr_val PSR; (* Change CWP to the new window value. *)
  write_reg result (ucast new_cwp) rd; (* Write result in rd of the new window. *)
  return ()
  od"

text {* Operational semantics for SAVE and RESTORE. *}
definition save_restore_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "save_restore_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rd = get_operand_w5 (op_list!3)
  in
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    curr_win \<leftarrow> get_curr_win();
    wim_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val WIM s));
    if instr_name = ctrl_type SAVE then 
      do
        new_cwp \<leftarrow> gets (\<lambda>s. ((word_of_int (((uint curr_win) - 1) mod NWINDOWS)))::word5);
        if (get_WIM_bit (unat new_cwp) wim_val) \<noteq> 0 then 
          do
            raise_trap window_overflow;
            return ()
          od
        else
          do
            result \<leftarrow> gets (\<lambda>s. (get_addr op_list s)); (* operands are from the old window. *)            
            save_retore_sub1 result new_cwp rd
          od
      od
    else (* instr_name = RESTORE *)
      do
        new_cwp \<leftarrow> gets (\<lambda>s. ((word_of_int (((uint curr_win) + 1) mod NWINDOWS)))::word5);
        if (get_WIM_bit (unat new_cwp) wim_val) \<noteq> 0 then 
          do
            raise_trap window_underflow;
            return ()
          od
        else
          do
            result \<leftarrow> gets (\<lambda>s. (get_addr op_list s)); (* operands are from the old window. *)
            save_retore_sub1 result new_cwp rd
          od
      od
  od"

definition flush_cache_line :: "word32 \<Rightarrow> ('a,unit) sparc_state_monad"
where "flush_cache_line \<equiv> undefined"

definition flush_Ibuf_and_pipeline :: "word32 \<Rightarrow> ('a,unit) sparc_state_monad"
where "flush_Ibuf_and_pipeline \<equiv> undefined"

text {* Operational semantics for FLUSH. 
        Flush the all the caches. *}
definition flush_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "flush_instr instr \<equiv>
  let op_list = snd instr in
  do
    addr \<leftarrow> gets (\<lambda>s. (get_addr op_list s));
    modify (\<lambda>s. (flush_cache_all s));
(*    flush_cache_line(addr);*)
(*    flush_Ibuf_and_pipeline(addr);*)
    return ()
  od"

text {* Operational semantics for read state register instructions. 
        We do not consider RDASR here. *}
definition read_state_reg_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "read_state_reg_instr instr \<equiv> 
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!0);
      rd = get_operand_w5 (op_list!1)
  in
  do  
    curr_win \<leftarrow> get_curr_win();
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    if (instr_name \<in> {sreg_type RDPSR,sreg_type RDWIM,sreg_type RDTBR} \<or> 
        (instr_name = sreg_type RDASR \<and> privileged_ASR rs1)) 
       \<and> ((ucast s_val)::word1) = 0 then
      do
        raise_trap privileged_instruction;
        return ()
      od
    else if illegal_instruction_ASR rs1 then 
      do
        raise_trap illegal_instruction;
        return ()
      od
    else if rd \<noteq> 0 then
      if instr_name = sreg_type RDY then
        do
          y_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val Y s));
          write_reg y_val curr_win rd;
          return ()
        od
      else if instr_name = sreg_type RDASR then
        do
          asr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val (ASR rs1) s));
          write_reg asr_val curr_win rd;
          return ()
        od
      else if instr_name = sreg_type RDPSR then
        do
          write_reg psr_val curr_win rd;
          return ()
        od
      else if instr_name = sreg_type RDWIM then
        do
          wim_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val WIM s));
          write_reg wim_val curr_win rd;
          return ()
        od
      else (* Must be RDTBR. *)
        do
          tbr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val TBR s));
          write_reg tbr_val curr_win rd;
          return ()
        od      
    else return ()  
  od"

text {* Operational semantics for write state register instructions. 
        We do not consider WRASR here. *}
definition write_state_reg_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "write_state_reg_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    curr_win \<leftarrow> get_curr_win();
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    op2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    result \<leftarrow> gets (\<lambda>s. (bitXOR rs1_val op2));
    if instr_name = sreg_type WRY then
      do
        modify (\<lambda>s. (delayed_pool_add (DELAYNUM, result, Y) s));
        return ()
      od 
    else if instr_name = sreg_type WRASR then
        if privileged_ASR rd \<and> s_val = 0 then
          do
            raise_trap privileged_instruction;
            return ()
          od
        else if illegal_instruction_ASR rd then
          do
            raise_trap illegal_instruction;
            return ()
          od
        else 
          do
            modify (\<lambda>s. (delayed_pool_add (DELAYNUM, result, (ASR rd)) s));
            return ()
          od
    else if instr_name = sreg_type WRPSR then
      if s_val = 0 then
        do
          raise_trap privileged_instruction;
          return ()
        od
      else if (uint ((ucast result)::word5)) \<ge> NWINDOWS then
        do
          raise_trap illegal_instruction;
          return ()
        od
      else 
        do (* ET and PIL appear to be written IMMEDIATELY w.r.t. interrupts. *)
          pil_val \<leftarrow> gets (\<lambda>s. (get_PIL result));
          et_val \<leftarrow> gets (\<lambda>s. (get_ET result));
          new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_et_pil et_val pil_val psr_val));
          write_cpu new_psr_val PSR;
          modify (\<lambda>s. (delayed_pool_add (DELAYNUM, result, PSR) s));
          return ()
        od
    else if instr_name = sreg_type WRWIM then
      if s_val = 0 then
        do
          raise_trap privileged_instruction;
          return ()
        od
      else 
        do (* Don't write bits corresponding to non-existent windows. *)
          result_f \<leftarrow> gets (\<lambda>s. ((result << nat (32 - NWINDOWS)) >> nat (32 - NWINDOWS)));
          modify (\<lambda>s. (delayed_pool_add (DELAYNUM, result_f, WIM) s));
          return ()
        od
    else  (* Must be WRTBR *)
      if s_val = 0 then
        do
          raise_trap privileged_instruction;
          return ()
        od
      else 
        do (* Only write the bits <31:12> of the result to TBR. *)
          tbr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val TBR s));
          tbr_val_11_0 \<leftarrow> gets (\<lambda>s. (bitAND tbr_val 0b00000000000000000000111111111111));
          result_tmp \<leftarrow> gets (\<lambda>s. (bitAND result 0b11111111111111111111000000000000));
          result_f \<leftarrow> gets (\<lambda>s. (bitOR tbr_val_11_0 result_tmp));
          modify (\<lambda>s. (delayed_pool_add (DELAYNUM, result_f, TBR) s));
          return ()
        od
  od"

definition logical_result :: "sparc_operation \<Rightarrow> word32 \<Rightarrow> word32 \<Rightarrow> word32"
where "logical_result instr_name rs1_val operand2 \<equiv>
  if (instr_name = logic_type ANDs) \<or> 
                            (instr_name = logic_type ANDcc) then
                          bitAND rs1_val operand2     
                         else if (instr_name = logic_type ANDN) \<or> 
                                 (instr_name = logic_type ANDNcc) then
                          bitAND rs1_val (bitNOT operand2)
                         else if (instr_name = logic_type ORs) \<or> 
                                 (instr_name = logic_type ORcc) then
                          bitOR rs1_val operand2
                         else if instr_name \<in> {logic_type ORN,logic_type ORNcc} then 
                          bitOR rs1_val (bitNOT operand2)
                         else if instr_name \<in> {logic_type XORs,logic_type XORcc} then 
                          bitXOR rs1_val operand2
                         else (* Must be XNOR or XNORcc *)
                          bitXOR rs1_val (bitNOT operand2)
"

definition logical_new_psr_val :: "word32 \<Rightarrow> ('a) sparc_state \<Rightarrow> word32"
where "logical_new_psr_val result s \<equiv>
  let psr_val = cpu_reg_val PSR s;
        n_val = (ucast (result >> 31))::word1;
        z_val = if (result = 0) then 1 else 0;
        v_val = 0;
        c_val = 0
  in
  update_PSR_icc n_val z_val v_val c_val psr_val
"

definition logical_instr_sub1 :: "sparc_operation \<Rightarrow> word32 \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where
"logical_instr_sub1 instr_name result \<equiv>
  if instr_name \<in> {logic_type ANDcc,logic_type ANDNcc,logic_type ORcc,
      logic_type ORNcc,logic_type XORcc,logic_type XNORcc} then
      do
        new_psr_val \<leftarrow> gets (\<lambda>s. (logical_new_psr_val result s));
        write_cpu new_psr_val PSR;
        return ()
      od
    else return () 
"

text {* Operational semantics for logical instructions. *}
definition logical_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "logical_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    result \<leftarrow> gets (\<lambda>s. (logical_result instr_name rs1_val operand2));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    logical_instr_sub1 instr_name result
  od"

text {* Operational semantics for shift instructions. *}
definition shift_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "shift_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      flagi = get_operand_flag (op_list!0);
      rs1 = get_operand_w5 (op_list!1);
      rs2_shcnt = get_operand_w5 (op_list!2);
      rd = get_operand_w5 (op_list!3)
  in
  do
    curr_win \<leftarrow> get_curr_win();
    shift_count \<leftarrow> gets (\<lambda>s. (if flagi = 0 then 
                                ucast (user_reg_val curr_win rs2_shcnt s) 
                              else rs2_shcnt));
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    if (instr_name = shift_type SLL) \<and> (rd \<noteq> 0) then 
      do
        rd_val \<leftarrow> gets (\<lambda>s. (rs1_val << (unat shift_count)));
        write_reg rd_val curr_win rd;
        return ()
      od
    else if (instr_name = shift_type SRL) \<and> (rd \<noteq> 0) then
      do
        rd_val \<leftarrow> gets (\<lambda>s. (rs1_val >> (unat shift_count)));
        write_reg rd_val curr_win rd;
        return ()
      od
    else if (instr_name = shift_type SRA) \<and> (rd \<noteq> 0) then
      do
        rd_val \<leftarrow> gets (\<lambda>s. (rs1_val >>> (unat shift_count)));
        write_reg rd_val curr_win rd;
        return ()
      od
    else return ()
  od"

definition add_instr_sub1 :: "sparc_operation \<Rightarrow> word32 \<Rightarrow> word32 \<Rightarrow> word32
  \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "add_instr_sub1 instr_name result rs1_val operand2 \<equiv>
  if instr_name \<in> {arith_type ADDcc,arith_type ADDXcc} then
      do
        psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
        result_31 \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
        rs1_val_31 \<leftarrow> gets (\<lambda>s. ((ucast (rs1_val >> 31))::word1));
        operand2_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand2 >> 31))::word1));
        new_n_val \<leftarrow> gets (\<lambda>s. (result_31));
        new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1::word1 else 0::word1));
        new_v_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND rs1_val_31 
                                              (bitAND operand2_31 
                                                      (bitNOT result_31))) 
                                      (bitAND (bitNOT rs1_val_31) 
                                              (bitAND (bitNOT operand2_31) 
                                                      result_31))));
        new_c_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND rs1_val_31 
                                              operand2_31) 
                                      (bitAND (bitNOT result_31) 
                                              (bitOR rs1_val_31 
                                                     operand2_31))));
        new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                                 new_z_val 
                                                 new_v_val 
                                                 new_c_val psr_val));
        write_cpu new_psr_val PSR;
        return ()
      od
    else return ()
"

text {* Operational semantics for add instructions. 
        These include ADD, ADDcc, ADDX. *}
definition add_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "add_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    c_val \<leftarrow> gets (\<lambda>s. (get_icc_C psr_val));
    result \<leftarrow> gets (\<lambda>s. (if (instr_name = arith_type ADD) \<or> 
                            (instr_name = arith_type ADDcc) then
                          rs1_val + operand2
                         else (* Must be ADDX or ADDXcc *) 
                          rs1_val + operand2 + (ucast c_val)));
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    add_instr_sub1 instr_name result rs1_val operand2
  od"

definition sub_instr_sub1 :: "sparc_operation \<Rightarrow> word32 \<Rightarrow> word32 \<Rightarrow> word32
  \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "sub_instr_sub1 instr_name result rs1_val operand2 \<equiv>
  if instr_name \<in> {arith_type SUBcc,arith_type SUBXcc} then
      do
        psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
        result_31 \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
        rs1_val_31 \<leftarrow> gets (\<lambda>s. ((ucast (rs1_val >> 31))::word1));
        operand2_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand2 >> 31))::word1));
        new_n_val \<leftarrow> gets (\<lambda>s. (result_31));
        new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1::word1 else 0::word1));
        new_v_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND rs1_val_31 
                                              (bitAND (bitNOT operand2_31) 
                                                      (bitNOT result_31))) 
                                      (bitAND (bitNOT rs1_val_31) 
                                              (bitAND operand2_31 
                                                      result_31))));
        new_c_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND (bitNOT rs1_val_31) 
                                              operand2_31) 
                                      (bitAND result_31 
                                              (bitOR (bitNOT rs1_val_31) 
                                                     operand2_31))));
        new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                                 new_z_val 
                                                 new_v_val 
                                                 new_c_val psr_val));
        write_cpu new_psr_val PSR;
        return ()
      od
    else return ()
"

text {* Operational semantics for subtract instructions. 
        These include SUB, SUBcc, SUBX. *}
definition sub_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "sub_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    c_val \<leftarrow> gets (\<lambda>s. (get_icc_C psr_val));
    result \<leftarrow> gets (\<lambda>s. (if (instr_name = arith_type SUB) \<or> 
                            (instr_name = arith_type SUBcc) then
                          rs1_val - operand2
                         else (* Must be SUBX or SUBXcc *) 
                          rs1_val - operand2 - (ucast c_val)));
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    sub_instr_sub1 instr_name result rs1_val operand2
  od"

definition mul_instr_sub1 :: "sparc_operation \<Rightarrow> word32 \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "mul_instr_sub1 instr_name result \<equiv>
  if instr_name \<in> {arith_type SMULcc,arith_type UMULcc} then
      do
        psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
        new_n_val \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
        new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1 else 0));
        new_v_val \<leftarrow> gets (\<lambda>s. 0);
        new_c_val \<leftarrow> gets (\<lambda>s. 0);
        new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                                 new_z_val 
                                                 new_v_val 
                                                 new_c_val psr_val));
        write_cpu new_psr_val PSR;
        return ()
      od
    else return ()
"

text {* Operational semantics for multiply instructions. *}
definition mul_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "mul_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    result0 \<leftarrow> gets (\<lambda>s. (if instr_name \<in> {arith_type UMUL,arith_type UMULcc} then 
                            (word_of_int ((uint rs1_val) * 
                                          (uint operand2)))::word64
                          else (* Must be SMUL or SMULcc *)
                            (word_of_int ((sint rs1_val) * 
                                          (sint operand2)))::word64));
    (* whether to use ucast or scast does not matter below. *)
    y_val \<leftarrow> gets (\<lambda>s. ((ucast (result0 >> 32))::word32));
    write_cpu y_val Y;
    result \<leftarrow> gets (\<lambda>s. ((ucast result0)::word32));
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    mul_instr_sub1 instr_name result
  od"

definition div_comp_temp_64bit :: "instruction \<Rightarrow> word64 \<Rightarrow> 
  virtua_address \<Rightarrow> word64"
where "div_comp_temp_64bit i y_rs1 operand2 \<equiv> 
  if ((fst i) = arith_type UDIV) \<or> ((fst i) = arith_type UDIVcc) then 
    (word_of_int ((uint y_rs1) div (uint operand2)))::word64
  else (* Must be SDIV or SDIVcc. *) 
    (* Due to Isabelle's rounding method is not nearest to zero, 
       we have to implement division in a different way. *)
    let sop1 = sint y_rs1;
        sop2 = sint operand2;
        pop1 = abs sop1;
        pop2 = abs sop2
    in
    if sop1 > 0 \<and> sop2 > 0 then 
      (word_of_int (sop1 div sop2))
    else if sop1 > 0 \<and> sop2 < 0 then
      (word_of_int (- (sop1 div pop2)))
    else if sop1 < 0 \<and> sop2 > 0 then
      (word_of_int (- (pop1 div sop2)))
    else (* sop1 < 0 \<and> sop2 < 0 *)
      (word_of_int (pop1 div pop2))"

definition div_comp_temp_V :: "instruction \<Rightarrow> word32 \<Rightarrow> word33 \<Rightarrow> word1"
where "div_comp_temp_V i w32 w33 \<equiv> 
  if ((fst i) = arith_type UDIV) \<or> ((fst i) = arith_type UDIVcc) then
    if w32 = 0 then 0 else 1
  else (* Must be SDIV or SDIVcc. *) 
    if (w33 = 0) \<or> (w33 = (0b111111111111111111111111111111111::word33)) 
    then 0 else 1"

definition div_comp_result :: "instruction \<Rightarrow> word1 \<Rightarrow> word64 \<Rightarrow> word32"
where "div_comp_result i temp_V temp_64bit \<equiv>
  if temp_V = 1 then
    if ((fst i) = arith_type UDIV) \<or> ((fst i) = arith_type UDIVcc) then
      (0b11111111111111111111111111111111::word32)
    else if (fst i) \<in> {arith_type SDIV,arith_type SDIVcc} then  
      if temp_64bit > 0 then 
        (0b01111111111111111111111111111111::word32)
      else ((word_of_int (0 - (uint (0b10000000000000000000000000000000::word32))))::word32)
    else ((ucast temp_64bit)::word32)
  else ((ucast temp_64bit)::word32)"

definition div_write_new_val :: "instruction \<Rightarrow> word32 \<Rightarrow> word1 \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "div_write_new_val i result temp_V \<equiv>
  if (fst i) \<in> {arith_type UDIVcc,arith_type SDIVcc} then
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    new_n_val \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
    new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1 else 0));
    new_v_val \<leftarrow> gets (\<lambda>s. temp_V);
    new_c_val \<leftarrow> gets (\<lambda>s. 0);
    new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                             new_z_val 
                                             new_v_val 
                                             new_c_val psr_val));
    write_cpu new_psr_val PSR;
    return ()
  od
  else return ()"

definition div_comp :: "instruction \<Rightarrow> word5 \<Rightarrow> word5 \<Rightarrow> virtua_address \<Rightarrow>
  ('a::len0,unit) sparc_state_monad"
where "div_comp instr rs1 rd operand2 \<equiv>
  do
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    
    y_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val Y s));
    y_rs1 \<leftarrow> gets (\<lambda>s. ((word_cat y_val rs1_val)::word64));
    temp_64bit \<leftarrow> gets (\<lambda>s. (div_comp_temp_64bit instr y_rs1 operand2));
    (*result \<leftarrow>  gets (\<lambda>s. ((ucast temp_64bit)::word32));*)
    temp_high32 \<leftarrow> gets (\<lambda>s. ((ucast (temp_64bit >> 32))::word32));
    temp_high33 \<leftarrow> gets (\<lambda>s. ((ucast (temp_64bit >> 31))::word33));
    temp_V \<leftarrow> gets (\<lambda>s. (div_comp_temp_V instr temp_high32 temp_high33));
    result \<leftarrow> gets (\<lambda>s. (div_comp_result instr temp_V temp_64bit));
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    div_write_new_val instr result temp_V 
  od"

text {* Operational semantics for divide instructions. *}
definition div_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "div_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    if (uint operand2) = 0 then 
      do
        raise_trap division_by_zero;
        return ()
      od
    else
      div_comp instr rs1 rd operand2
  od"

definition ld_word0 :: "instruction \<Rightarrow> word32 \<Rightarrow> virtua_address \<Rightarrow>  word32"
where "ld_word0 instr data_word address \<equiv>
  if (fst instr) \<in> {load_store_type LDSB,load_store_type LDUB,
    load_store_type LDUBA,load_store_type LDSBA} then                                     
    let byte = if (uint ((ucast address)::word2)) = 0 then
                 (ucast (data_word >> 24))::word8
               else if (uint ((ucast address)::word2)) = 1 then
                 (ucast (data_word >> 16))::word8
               else if (uint ((ucast address)::word2)) = 2 then
                 (ucast (data_word >> 8))::word8
               else (* Must be 3. *) 
                 (ucast data_word)::word8
    in
    if (fst instr) = load_store_type LDSB \<or> (fst instr) = load_store_type LDSBA then
      sign_ext8 byte
    else 
      zero_ext8 byte
  else if (fst instr) = load_store_type LDUH \<or> (fst instr) = load_store_type LDSH \<or> 
          (fst instr) = load_store_type LDSHA \<or> (fst instr) = load_store_type LDUHA
       then  
    let halfword = if (uint ((ucast address)::word2)) = 0 then
                     (ucast (data_word >> 16))::word16
                   else (* Must be 2. *) 
                     (ucast data_word)::word16
    in
    if (fst instr) = load_store_type LDSH \<or> (fst instr) = load_store_type LDSHA then
      sign_ext16 halfword
    else
      zero_ext16 halfword
  else (* Must be LDD*) 
    data_word
"

definition ld_asi :: "instruction \<Rightarrow> word1 \<Rightarrow> asi_type"
where "ld_asi instr s_val \<equiv>
  if (fst instr) \<in> {load_store_type LDD,load_store_type LD,load_store_type LDUH,
    load_store_type LDSB,load_store_type LDUB,load_store_type LDSH} then
    if s_val = 0 then (word_of_int 10)::asi_type
    else (word_of_int 11)::asi_type
  else (* Must be LDA, LDUBA, LDSBA, LDSHA, LDUHA, or LDDA. *)
    get_operand_asi ((snd instr)!3)
"

definition load_sub2 :: "virtua_address \<Rightarrow> asi_type \<Rightarrow> word5 \<Rightarrow> 
  ('a::len0) window_size \<Rightarrow> word32 \<Rightarrow> ('a,unit) sparc_state_monad"
where "load_sub2 address asi rd curr_win word0 \<equiv>
  do
    write_reg word0 curr_win (bitAND rd 0b11110);
    (result1,new_state1) \<leftarrow> gets (\<lambda>s. (memory_read asi (address + 4) s));
    if result1 = None then
    do
      raise_trap data_access_exception;
      return ()
    od
    else
    do
      word1 \<leftarrow> gets (\<lambda>s. (case result1 of Some v \<Rightarrow> v));
      modify (\<lambda>s. (new_state1));
      write_reg word1 curr_win (bitOR rd 1);
      return ()                                       
    od
  od"

definition load_sub3 :: "instruction \<Rightarrow> ('a::len0) window_size \<Rightarrow>
  word5 \<Rightarrow> asi_type \<Rightarrow> virtua_address \<Rightarrow>
  ('a::len0,unit) sparc_state_monad"
where "load_sub3 instr curr_win rd asi address \<equiv>
  do
    (result,new_state) \<leftarrow> gets (\<lambda>s. (memory_read asi address s));
    if result = None then
    do
      raise_trap data_access_exception;
      return ()
    od
    else
    do
      data_word \<leftarrow> gets (\<lambda>s. (case result of Some v \<Rightarrow> v));
      modify (\<lambda>s. (new_state));
      word0 \<leftarrow> gets (\<lambda>s. (ld_word0 instr data_word address));
      if rd \<noteq> 0 \<and> (fst instr) \<in> {load_store_type LD,load_store_type LDA,
        load_store_type LDUH,load_store_type LDSB,load_store_type LDUB,
        load_store_type LDUBA,load_store_type LDSH,load_store_type LDSHA,
        load_store_type LDUHA,load_store_type LDSBA} then
      do
        write_reg word0 curr_win rd;
        return ()
      od
      else (* Must be LDD or LDDA *)
        load_sub2 address asi rd curr_win word0
    od
  od"

definition load_sub1 :: "instruction \<Rightarrow> word5 \<Rightarrow> word1 \<Rightarrow>
  ('a::len0,unit) sparc_state_monad"
where "load_sub1 instr rd s_val \<equiv>
  do
    curr_win \<leftarrow> get_curr_win();
    address \<leftarrow> gets (\<lambda>s. (get_addr (snd instr) s));
    asi \<leftarrow> gets (\<lambda>s. (ld_asi instr s_val));
    if (((fst instr) = load_store_type LDD \<or> (fst instr) = load_store_type LDDA) 
       \<and> ((ucast address)::word3) \<noteq> 0) 
         \<or> ((fst instr) \<in> {load_store_type LD,load_store_type LDA} 
            \<and> ((ucast address)::word2) \<noteq> 0)
         \<or> (((fst instr) = load_store_type LDUH \<or> (fst instr) = load_store_type LDUHA 
             \<or> (fst instr) = load_store_type LDSH \<or> (fst instr) = load_store_type LDSHA) 
            \<and> ((ucast address)::word1) \<noteq> 0)
    then
    do
      raise_trap mem_address_not_aligned;
      return ()
    od
    else
      load_sub3 instr curr_win rd asi address
  od"

text {* Operational semantics for Load instructions. *}
definition load_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "load_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      flagi = get_operand_flag (op_list!0);
      rd = if instr_name \<in> {load_store_type LDUBA,load_store_type LDA,
        load_store_type LDSBA,load_store_type LDSHA,
        load_store_type LDSHA,load_store_type LDDA} then (* rd is member 4 *)
            get_operand_w5 (op_list!4)
           else (* rd is member 3*)      
            get_operand_w5 (op_list!3)
  in  
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    if instr_name \<in> {load_store_type LDA,load_store_type LDUBA,
      load_store_type LDSBA,load_store_type LDSHA,
      load_store_type LDUHA,load_store_type LDDA} \<and> s_val = 0 then 
      do
        raise_trap privileged_instruction;
        return ()
      od
    else if instr_name \<in> {load_store_type LDA,load_store_type LDUBA,
      load_store_type LDSBA,load_store_type LDSHA,load_store_type LDUHA,
      load_store_type LDDA} \<and> flagi = 1 then
      do
        raise_trap illegal_instruction;
        return ()
      od
    else
      load_sub1 instr rd s_val        
  od"

definition st_asi :: "instruction \<Rightarrow> word1 \<Rightarrow> asi_type"
where "st_asi instr s_val \<equiv>
  if (fst instr) \<in> {load_store_type STD,load_store_type ST,
    load_store_type STH,load_store_type STB} then
    if s_val = 0 then (word_of_int 10)::asi_type
    else (word_of_int 11)::asi_type
  else (* Must be STA, STBA, STHA, STDA. *)
    get_operand_asi ((snd instr)!3)
"

definition st_byte_mask :: "instruction \<Rightarrow> virtua_address \<Rightarrow> word4"
where "st_byte_mask instr address \<equiv>
  if (fst instr) \<in> {load_store_type STD,load_store_type ST,
    load_store_type STA,load_store_type STDA} then 
    (0b1111::word4)
  else if (fst instr) \<in> {load_store_type STH,load_store_type STHA} then
    if ((ucast address)::word2) = 0 then
      (0b1100::word4)
    else (* Must be 2 . *)
      (0b0011::word4)
  else (* Must be STB or STBA. *)
    if ((ucast address)::word2) = 0 then 
      (0b1000::word4)
    else if ((ucast address)::word2) = 1 then 
      (0b0100::word4)
    else if ((ucast address)::word2) = 2 then 
      (0b0010::word4)
    else (* Must be 3. *)
      (0b0001::word4)
"

definition st_data0 :: "instruction \<Rightarrow> ('a::len0) window_size \<Rightarrow> 
  word5 \<Rightarrow> virtua_address \<Rightarrow> ('a) sparc_state \<Rightarrow> reg_type"
where "st_data0 instr curr_win rd address s \<equiv>
  if (fst instr) \<in> {load_store_type STD,load_store_type STDA} then 
    user_reg_val curr_win (bitAND rd 0b11110) s
  else if (fst instr) \<in> {load_store_type ST,load_store_type STA} then 
    user_reg_val curr_win rd s
  else if (fst instr) \<in> {load_store_type STH,load_store_type STHA} then
    if ((ucast address)::word2) = 0 then 
      (user_reg_val curr_win rd s) << 16
    else (* Must be 2. *)
      user_reg_val curr_win rd s
  else (* Must be STB or STBA. *)
    if ((ucast address)::word2) = 0 then 
       (user_reg_val curr_win rd s) << 24
    else if ((ucast address)::word2) = 1 then
       (user_reg_val curr_win rd s) << 16
    else if ((ucast address)::word2) = 2 then
        (user_reg_val curr_win rd s) << 8
    else (* Must be 3. *) 
        user_reg_val curr_win rd s
"

definition store_sub2 :: "instruction \<Rightarrow> ('a::len0) window_size \<Rightarrow>
  word5 \<Rightarrow> asi_type \<Rightarrow> virtua_address \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "store_sub2 instr curr_win rd asi address \<equiv>
  do
    byte_mask \<leftarrow> gets (\<lambda>s. (st_byte_mask instr address));
    data0 \<leftarrow> gets (\<lambda>s. (st_data0 instr curr_win rd address s));
    result0 \<leftarrow> gets (\<lambda>s. (memory_write asi address byte_mask data0 s));
    if result0 = None then
    do
      raise_trap data_access_exception;
      return ()
    od
    else 
    do
      new_state \<leftarrow> gets (\<lambda>s. (case result0 of Some v \<Rightarrow> v));
      modify (\<lambda>s. (new_state));
      if (fst instr) \<in> {load_store_type STD,load_store_type STDA} then  
      do
        data1 \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win (bitOR rd 0b00001) s));
        result1 \<leftarrow> gets (\<lambda>s. (memory_write asi (address + 4) (0b1111::word4) data1 s));
        if result1 = None then
        do
          raise_trap data_access_exception;
          return ()
        od
        else 
          do
          new_state1 \<leftarrow> gets (\<lambda>s. (case result1 of Some v \<Rightarrow> v));
          modify (\<lambda>s. (new_state1));
          return ()
          od
      od
      else
        return ()
    od
  od"

definition store_sub1 :: "instruction \<Rightarrow> word5 \<Rightarrow> word1 \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "store_sub1 instr rd s_val \<equiv>
  do
    curr_win \<leftarrow> get_curr_win();
    address \<leftarrow> gets (\<lambda>s. (get_addr (snd instr) s));
    asi \<leftarrow> gets (\<lambda>s. (st_asi instr s_val));
    (* The following code is intentionally long to match the definitions in SPARCv8. *)
    if ((fst instr) = load_store_type STH \<or> (fst instr) = load_store_type STHA) 
       \<and> ((ucast address)::word1) \<noteq> 0 then
    do  
      raise_trap mem_address_not_aligned;
      return ()
    od
    else if (fst instr) \<in> {load_store_type ST,load_store_type STA} 
            \<and> ((ucast address)::word2) \<noteq> 0 then
    do  
      raise_trap mem_address_not_aligned;
      return ()
    od
    else if (fst instr) \<in> {load_store_type STD,load_store_type STDA} 
            \<and> ((ucast address)::word3) \<noteq> 0 then
    do  
      raise_trap mem_address_not_aligned;
      return ()
    od
    else 
      store_sub2 instr curr_win rd asi address
  od"

text {* Operational semantics for Store instructions. *}
definition store_instr :: "instruction \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "store_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      flagi = get_operand_flag (op_list!0);
      rd = if instr_name \<in> {load_store_type STA,load_store_type STBA,
            load_store_type STHA,load_store_type STDA} then (* rd is member 4 *)
            get_operand_w5 (op_list!4)
           else (* rd is member 3*)      
            get_operand_w5 (op_list!3)
  in
  do   
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    if instr_name \<in> {load_store_type STA,load_store_type STDA,
      load_store_type STHA,load_store_type STBA} \<and> s_val = 0 then
      do
        raise_trap privileged_instruction;
        return ()
      od
    else if instr_name \<in> {load_store_type STA,load_store_type STDA,
      load_store_type STHA,load_store_type STBA} \<and> flagi = 1 then
      do
        raise_trap illegal_instruction;
        return ()
      od
    else
      store_sub1 instr rd s_val
  od"

text {* The instructions below are not used by Xtratum and they are 
  not tested. *}

definition ldst_asi :: "instruction \<Rightarrow> word1 \<Rightarrow> asi_type"
where "ldst_asi instr s_val \<equiv>
  if (fst instr) \<in> {load_store_type LDSTUB} then
    if s_val = 0 then (word_of_int 10)::asi_type
    else (word_of_int 11)::asi_type
  else (* Must be LDSTUBA. *)
    get_operand_asi ((snd instr)!3)
"

definition ldst_word0 :: "instruction \<Rightarrow> word32 \<Rightarrow> virtua_address \<Rightarrow>  word32"
where "ldst_word0 instr data_word address \<equiv>                                 
  let byte = if (uint ((ucast address)::word2)) = 0 then
                 (ucast (data_word >> 24))::word8
               else if (uint ((ucast address)::word2)) = 1 then
                 (ucast (data_word >> 16))::word8
               else if (uint ((ucast address)::word2)) = 2 then
                 (ucast (data_word >> 8))::word8
               else (* Must be 3. *) 
                 (ucast data_word)::word8
  in
  zero_ext8 byte
"

definition ldst_byte_mask :: "instruction \<Rightarrow> virtua_address \<Rightarrow> word4"
where "ldst_byte_mask instr address \<equiv>
    if ((ucast address)::word2) = 0 then 
      (0b1000::word4)
    else if ((ucast address)::word2) = 1 then 
      (0b0100::word4)
    else if ((ucast address)::word2) = 2 then 
      (0b0010::word4)
    else (* Must be 3. *)
      (0b0001::word4)
"

definition load_store_sub1 :: "instruction \<Rightarrow> word5 \<Rightarrow> word1 \<Rightarrow>
  ('a::len0,unit) sparc_state_monad"
where "load_store_sub1 instr rd s_val \<equiv>
  do
    curr_win \<leftarrow> get_curr_win();
    address \<leftarrow> gets (\<lambda>s. (get_addr (snd instr) s));
    asi \<leftarrow> gets (\<lambda>s. (ldst_asi instr s_val));
    (* wait for locks to be lifted. *)
    (* an implementation actually need only block when another LDSTUB or SWAP
      is pending on the same byte in memory as the one addressed by this LDSTUB*)
    (* Should wait when block_type = 1 \<or> block_word = 1 *)
    (* until another processes write both to be 0. *)
    (* We implement this as setting pc as npc when the instruction 
      is blocked. This way, in the next iteration, we will still execution
      the current instruction. *)
    block_byte \<leftarrow> gets (\<lambda>s. (pb_block_ldst_byte_val address s));
    block_word \<leftarrow> gets (\<lambda>s. (pb_block_ldst_word_val address s));
    if block_byte \<or> block_word then 
    do
      pc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PC s));
      write_cpu pc_val nPC;
      return ()
    od  
    else 
    do
      modify (\<lambda>s. (pb_block_ldst_byte_mod address True s));
      (result,new_state) \<leftarrow> gets (\<lambda>s. (memory_read asi address s));
      if result = None then
      do
        raise_trap data_access_exception;
        return ()
      od
      else
      do
        data_word \<leftarrow> gets (\<lambda>s. (case result of Some v \<Rightarrow> v));
        modify (\<lambda>s. (new_state));
        byte_mask \<leftarrow> gets (\<lambda>s. (ldst_byte_mask instr address));
        data0 \<leftarrow> gets (\<lambda>s. (0b11111111111111111111111111111111::word32));
        result0 \<leftarrow> gets (\<lambda>s. (memory_write asi address byte_mask data0 s));  
        modify (\<lambda>s. (pb_block_ldst_byte_mod address False s));
        if result0 = None then
        do
          raise_trap data_access_exception;
          return ()
        od
        else
        do
          new_state1 \<leftarrow> gets (\<lambda>s. (case result0 of Some v \<Rightarrow> v));
          modify (\<lambda>s. (new_state1));
          word0 \<leftarrow> gets (\<lambda>s. (ldst_word0 instr data_word address));
          if rd \<noteq> 0 then
          do
            write_reg word0 curr_win rd;
            return ()
          od
          else 
            return ()
        od
      od
    od
  od"

text {* Operational semantics for atomic load-store. *}
definition load_store_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "load_store_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      flagi = get_operand_flag (op_list!0);
      rd = if instr_name \<in> {load_store_type LDSTUBA} then (* rd is member 4 *)
            get_operand_w5 (op_list!4)
           else (* rd is member 3*)      
            get_operand_w5 (op_list!3)
  in
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    if instr_name \<in> {load_store_type LDSTUBA} \<and> s_val = 0 then 
      do
        raise_trap privileged_instruction;
        return ()
      od
    else if instr_name \<in> {load_store_type LDSTUBA} \<and> flagi = 1 then
      do
        raise_trap illegal_instruction;
        return ()
      od
    else
      load_store_sub1 instr rd s_val
  od"

definition swap_sub1 :: "instruction \<Rightarrow> word5 \<Rightarrow> word1 \<Rightarrow>
  ('a::len0,unit) sparc_state_monad"
where "swap_sub1 instr rd s_val \<equiv>
  do
    curr_win \<leftarrow> get_curr_win();
    address \<leftarrow> gets (\<lambda>s. (get_addr (snd instr) s));
    asi \<leftarrow> gets (\<lambda>s. (ldst_asi instr s_val));    
    temp \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    (* wait for locks to be lifted. *)
    (* an implementation actually need only block when another LDSTUB or SWAP
      is pending on the same byte in memory as the one addressed by this LDSTUB*)
    (* Should wait when block_type = 1 \<or> block_word = 1 *)
    (* until another processes write both to be 0. *)
    (* We implement this as setting pc as npc when the instruction 
      is blocked. This way, in the next iteration, we will still execution
      the current instruction. *)
    block_byte \<leftarrow> gets (\<lambda>s. (pb_block_ldst_byte_val address s));
    block_word \<leftarrow> gets (\<lambda>s. (pb_block_ldst_word_val address s));
    if block_byte \<or> block_word then 
    do
      pc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PC s));
      write_cpu pc_val nPC;
      return ()
    od  
    else 
    do  
      modify (\<lambda>s. (pb_block_ldst_word_mod address True s));
      (result,new_state) \<leftarrow> gets (\<lambda>s. (memory_read asi address s));
      if result = None then
      do
        raise_trap data_access_exception;
        return ()
      od
      else
      do
        word \<leftarrow> gets (\<lambda>s. (case result of Some v \<Rightarrow> v));
        modify (\<lambda>s. (new_state));
        byte_mask \<leftarrow> gets (\<lambda>s. (0b1111::word4));
        result0 \<leftarrow> gets (\<lambda>s. (memory_write asi address byte_mask temp s)); 
        modify (\<lambda>s. (pb_block_ldst_word_mod address False s));
        if result0 = None then
        do
          raise_trap data_access_exception;
          return ()
        od
        else
        do
          new_state1 \<leftarrow> gets (\<lambda>s. (case result0 of Some v \<Rightarrow> v));
          modify (\<lambda>s. (new_state1));
          if rd \<noteq> 0 then
          do
            write_reg word curr_win rd;
            return ()
          od
          else 
            return ()
        od
      od
    od
  od"

text {* Operational semantics for swap. *}
definition swap_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "swap_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      flagi = get_operand_flag (op_list!0);
      rd = if instr_name \<in> {load_store_type SWAPA} then (* rd is member 4 *)
            get_operand_w5 (op_list!4)
           else (* rd is member 3*)      
            get_operand_w5 (op_list!3)
  in
  do
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    s_val \<leftarrow> gets (\<lambda>s. (get_S psr_val));
    if instr_name \<in> {load_store_type SWAPA} \<and> s_val = 0 then 
      do
        raise_trap privileged_instruction;
        return ()
      od
    else if instr_name \<in> {load_store_type SWAPA} \<and> flagi = 1 then
      do
        raise_trap illegal_instruction;
        return ()
      od
    else
      swap_sub1 instr rd s_val
  od"

definition bit2_zero :: "word2 \<Rightarrow> word1"
where "bit2_zero w2 \<equiv> if w2 \<noteq> 0 then 1 else 0"

text {* Operational semantics for tagged add instructions. *}
definition tadd_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "tadd_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    c_val \<leftarrow> gets (\<lambda>s. (get_icc_C psr_val));
    result \<leftarrow> gets (\<lambda>s. (rs1_val + operand2));
    result_31 \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
    rs1_val_31 \<leftarrow> gets (\<lambda>s. ((ucast (rs1_val >> 31))::word1));
    operand2_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand2 >> 31))::word1));
    rs1_val_2 \<leftarrow> gets (\<lambda>s. (bit2_zero ((ucast rs1_val)::word2)));
    operand2_2 \<leftarrow> gets (\<lambda>s. (bit2_zero ((ucast operand2)::word2)));
    temp_V \<leftarrow> gets (\<lambda>s. (bitOR (bitOR (bitAND rs1_val_31 
                                              (bitAND operand2_31 
                                                      (bitNOT result_31))) 
                                      (bitAND (bitNOT rs1_val_31) 
                                              (bitAND (bitNOT operand2_31) 
                                                      result_31)))
                               (bitOR rs1_val_2 operand2_2)));
    if instr_name = arith_type TADDccTV \<and> temp_V = 1 then 
    do
      raise_trap tag_overflow;
      return ()
    od
    else 
    do
      rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
      new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
      write_reg new_rd_val curr_win rd;      
      new_n_val \<leftarrow> gets (\<lambda>s. (result_31));
      new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1::word1 else 0::word1));
      new_v_val \<leftarrow> gets (\<lambda>s. temp_V);
      new_c_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND rs1_val_31 
                                              operand2_31) 
                                      (bitAND (bitNOT result_31) 
                                              (bitOR rs1_val_31 
                                                     operand2_31))));
      new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                                 new_z_val 
                                                 new_v_val 
                                                 new_c_val psr_val));
      write_cpu new_psr_val PSR;
      rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
      new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
      write_reg new_rd_val curr_win rd;
      return ()
    od
  od"

text {* Operational semantics for tagged add instructions. *}
definition tsub_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "tsub_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    operand2 \<leftarrow> gets (\<lambda>s. (get_operand2 op_list s));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    c_val \<leftarrow> gets (\<lambda>s. (get_icc_C psr_val));
    result \<leftarrow> gets (\<lambda>s. (rs1_val - operand2));
    result_31 \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
    rs1_val_31 \<leftarrow> gets (\<lambda>s. ((ucast (rs1_val >> 31))::word1));
    operand2_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand2 >> 31))::word1));
    rs1_val_2 \<leftarrow> gets (\<lambda>s. (bit2_zero ((ucast rs1_val)::word2)));
    operand2_2 \<leftarrow> gets (\<lambda>s. (bit2_zero ((ucast operand2)::word2)));
    temp_V \<leftarrow> gets (\<lambda>s. (bitOR (bitOR (bitAND rs1_val_31 
                                              (bitAND operand2_31 
                                                      (bitNOT result_31))) 
                                      (bitAND (bitNOT rs1_val_31) 
                                              (bitAND (bitNOT operand2_31) 
                                                      result_31)))
                               (bitOR rs1_val_2 operand2_2)));
    if instr_name = arith_type TSUBccTV \<and> temp_V = 1 then 
    do
      raise_trap tag_overflow;
      return ()
    od
    else 
    do
      rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
      new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
      write_reg new_rd_val curr_win rd;      
      new_n_val \<leftarrow> gets (\<lambda>s. (result_31));
      new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1::word1 else 0::word1));
      new_v_val \<leftarrow> gets (\<lambda>s. temp_V);
      new_c_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND rs1_val_31 
                                              operand2_31) 
                                      (bitAND (bitNOT result_31) 
                                              (bitOR rs1_val_31 
                                                     operand2_31))));
      new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                                 new_z_val 
                                                 new_v_val 
                                                 new_c_val psr_val));
      write_cpu new_psr_val PSR;
      rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
      new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
      write_reg new_rd_val curr_win rd;
      return ()
    od
  od"

definition muls_op2 :: "inst_operand list \<Rightarrow> ('a::len0) sparc_state \<Rightarrow> word32"
where "muls_op2 op_list s \<equiv>
  let y_val = cpu_reg_val Y s in
  if ((ucast y_val)::word1) = 0 then 0
  else get_operand2 op_list s
"

text {* Operational semantics for multiply step instruction. *}
definition muls_instr :: "instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "muls_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1);
      rd = get_operand_w5 (op_list!3)
  in
  do
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    psr_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PSR s));
    n_val \<leftarrow> gets (\<lambda>s. (get_icc_N psr_val));
    v_val \<leftarrow> gets (\<lambda>s. (get_icc_V psr_val));
    c_val \<leftarrow> gets (\<lambda>s. (get_icc_C psr_val));
    y_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val Y s));
    operand1 \<leftarrow> gets (\<lambda>s. (word_cat (bitXOR n_val v_val) 
                                    ((ucast (rs1_val >> 1))::word31)));
    operand2 \<leftarrow> gets (\<lambda>s. (muls_op2 op_list s));    
    result \<leftarrow> gets (\<lambda>s. (operand1 + operand2));
    new_y_val \<leftarrow> gets (\<lambda>s. (word_cat ((ucast rs1_val)::word1) ((ucast (y_val >> 1))::word31)));
    write_cpu new_y_val Y;
    rd_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rd s));
    new_rd_val \<leftarrow> gets (\<lambda>s. (if rd \<noteq> 0 then result else rd_val));
    write_reg new_rd_val curr_win rd;
    result_31 \<leftarrow> gets (\<lambda>s. ((ucast (result >> 31))::word1));
    operand1_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand1 >> 31))::word1));
    operand2_31 \<leftarrow> gets (\<lambda>s. ((ucast (operand2 >> 31))::word1));
    new_n_val \<leftarrow> gets (\<lambda>s. (result_31));
    new_z_val \<leftarrow> gets (\<lambda>s. (if result = 0 then 1::word1 else 0::word1));
    new_v_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND operand1_31 
                                  (bitAND operand2_31 
                                     (bitNOT result_31))) 
                                  (bitAND (bitNOT operand1_31) 
                                     (bitAND (bitNOT operand2_31) 
                                             result_31))));
    new_c_val \<leftarrow> gets (\<lambda>s. (bitOR (bitAND operand1_31 
                                          operand2_31) 
                                  (bitAND (bitNOT result_31) 
                                          (bitOR operand1_31 
                                                 operand2_31))));
    new_psr_val \<leftarrow> gets (\<lambda>s. (update_PSR_icc new_n_val 
                                             new_z_val 
                                             new_v_val 
                                             new_c_val psr_val));
    write_cpu new_psr_val PSR;
    return ()
  od"

text{* Evaluate icc based on the bits N, Z, V, C in PSR 
       and the type of ticc instruction. 
       See Sparcv8 manual Page 182. *}
definition trap_eval_icc::"sparc_operation \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> word1 \<Rightarrow> int"
where "trap_eval_icc instr_name n_val z_val v_val c_val \<equiv>
    if instr_name = ticc_type TNE then
      if z_val = 0 then 1 else 0
    else if instr_name = ticc_type TE then 
      if z_val = 1 then 1 else 0
    else if instr_name = ticc_type TG then
      if (bitOR z_val (n_val XOR v_val)) = 0 then 1 else 0
    else if instr_name = ticc_type TLE then
      if (bitOR z_val (n_val XOR v_val)) = 1 then 1 else 0
    else if instr_name = ticc_type TGE then
      if (n_val XOR v_val) = 0 then 1 else 0
    else if instr_name = ticc_type TL then
      if (n_val XOR v_val) = 1 then 1 else 0
    else if instr_name = ticc_type TGU then
      if (c_val = 0 \<and> z_val = 0) then 1 else 0
    else if instr_name = ticc_type TLEU then
      if (c_val = 1 \<or> z_val = 1) then 1 else 0
    else if instr_name = ticc_type TCC then
      if c_val = 0 then 1 else 0
    else if instr_name = ticc_type TCS then
      if c_val = 1 then 1 else 0
    else if instr_name = ticc_type TPOS then
      if n_val = 0 then 1 else 0
    else if instr_name = ticc_type TNEG then
      if n_val = 1 then 1 else 0
    else if instr_name = ticc_type TVC then
      if v_val = 0 then 1 else 0
    else if instr_name = ticc_type TVS then
      if v_val = 1 then 1 else 0
    else if instr_name = ticc_type TA then 1
    else if instr_name = ticc_type TN then 0    
    else -1
"

text {* Get operand2 for ticc based on the flag i, rs1, rs2, and trap\_imm7. 
        If i = 0 then operand2 = r[rs2],
        else operand2 = sign\_ext7(trap\_imm7). 
        op\_list should be [i,rs1,rs2] or [i,rs1,trap\_imm7]. *}
definition get_trap_op2::"inst_operand list \<Rightarrow> ('a::len0) sparc_state
  \<Rightarrow> virtua_address"
where "get_trap_op2 op_list s \<equiv>
  let flagi = get_operand_flag (op_list!0);
      curr_win = ucast (get_CWP (cpu_reg_val PSR s))
  in
  if flagi = 0 then
    let rs2 = get_operand_w5 (op_list!2);
        rs2_val = user_reg_val curr_win rs2 s
    in rs2_val
  else
    let ext_simm7 = sign_ext7 (get_operand_imm7 (op_list!2)) in
    ext_simm7
"

text {* Operational semantics for Ticc insturctions. *}
definition ticc_instr::"instruction \<Rightarrow> 
  ('a::len0,unit) sparc_state_monad"
where "ticc_instr instr \<equiv>
  let instr_name = fst instr;
      op_list = snd instr;
      rs1 = get_operand_w5 (op_list!1)
  in
  do
    n_val \<leftarrow> gets (\<lambda>s. get_icc_N ((cpu_reg s) PSR));
    z_val \<leftarrow> gets (\<lambda>s. get_icc_Z ((cpu_reg s) PSR));
    v_val \<leftarrow> gets (\<lambda>s. get_icc_V ((cpu_reg s) PSR));
    c_val \<leftarrow> gets (\<lambda>s. get_icc_C ((cpu_reg s) PSR));
    icc_val \<leftarrow> gets(\<lambda>s. (trap_eval_icc instr_name n_val z_val v_val c_val));
    curr_win \<leftarrow> get_curr_win();
    rs1_val \<leftarrow> gets (\<lambda>s. (user_reg_val curr_win rs1 s));
    trap_number \<leftarrow> gets (\<lambda>s. (rs1_val + (get_trap_op2 op_list s)));
    npc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val nPC s));
    pc_val \<leftarrow> gets (\<lambda>s. (cpu_reg_val PC s));  
    if icc_val = 1 then 
      do
        raise_trap trap_instruction;
        trap_number7 \<leftarrow> gets (\<lambda>s. ((ucast trap_number)::word7));
        modify (\<lambda>s. (ticc_trap_type_mod trap_number7 s)); 
        return ()
      od
    else (* icc_val = 0 *) 
      do
        write_cpu npc_val PC;
        write_cpu (npc_val + 4) nPC;
        return ()
      od
  od"

text {* Operational semantics for store barrier. *}
definition store_barrier_instr::"instruction \<Rightarrow> ('a::len0,unit) sparc_state_monad"
where "store_barrier_instr instr \<equiv>
  do
    modify (\<lambda>s. (store_barrier_pending_mod True s));
    return ()
  od"

end