.//============================================================================
.// $RCSfile: q.oal.act_blk.arc,v $
.//
.// Description:
.// This function provides indirection and a single point of turning for
.// fragment versus OAL instance based code generation.
.//
.// Notice:
.// (C) Copyright 1998-2013 Mentor Graphics Corporation
.//     All rights reserved.
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.//
.//
.// This function produces the code for an action given the outer
.// block.  It traverses each statement in order and generates for it.
.//
.// If the statement is a control statement, then there are two
.// buffers of generated code, otherwise there is only one.
.//
.function blck_xlate .// string
  .param boolean trace
  .param inst_ref te_blk
  .assign code = ""
  .if ( "" != te_blk.declaration )
    .assign code = ( te_blk.indentation + te_blk.declaration ) +  "\n"
  .end if
  .select any act_smt related by te_blk->ACT_BLK[R2016]->ACT_SMT[R602]
  .if ( not_empty act_smt )
    .// We have statements in this block.
    .// Get empty handles into scope.
    .select one current_act_if related by act_smt->ACT_IF[R603] where ( false )
    .select one empty_act_smt related by current_act_if->ACT_SMT[R603] where ( false )
    .// Be sure we have the first statement in the block.
    .while ( not_empty act_smt )
      .// CDS - Note that R661 is wacky.
      .select one s related by act_smt->ACT_SMT[R661.'succeeds']
      .if ( empty s )
        .break while
      .end if
      .assign act_smt = s
    .end while
    .while ( not_empty act_smt )
      .assign next = empty_act_smt
      .select one te_smt related by act_smt->TE_SMT[R2038]
      .if ( "" != te_smt.OAL )
        .assign statement_comment = ( ( te_blk.indentation + "/" ) + ( "* " + te_smt.OAL ) ) + ( " *" + "/\n" )
        .assign code = code + statement_comment
        .if ( trace )
          .assign statement_trace = ( ( te_blk.indentation + "XTUML_OAL_STMT_TRACE( " ) + ( "$t{te_blk.depth}" + ", &quot;" ) ) + ( te_smt.OAL + "&quot; );\n" )
          .assign code = code + statement_trace
        .end if
      .end if
      .assign code = code + te_smt.buffer
      .select one for_te_blk related by act_smt->ACT_FOR[R603]->ACT_BLK[R605]->TE_BLK[R2016]
      .if ( not_empty for_te_blk )
        .invoke r = blck_xlate( trace, for_te_blk )
        .assign code = code + r.result
      .else
      .select one whl_te_blk related by act_smt->ACT_WHL[R603]->ACT_BLK[R608]->TE_BLK[R2016]
      .if ( not_empty whl_te_blk )
        .invoke r = blck_xlate( trace, whl_te_blk )
        .assign code = code + r.result
      .else
      .select one act_if related by act_smt->ACT_IF[R603]
      .if ( not_empty act_if )
        .assign current_act_if = act_if
        .select one if_te_blk related by act_if->ACT_BLK[R607]->TE_BLK[R2016]
        .if ( not_empty if_te_blk )
          .invoke r = blck_xlate( trace, if_te_blk )
          .assign code = code + r.result
        .end if
        .// ELIF and ELSE are not linked across R661.  So, get the next
        .// one from here.
        .// CDS Note:  This depends upon the generator storing these in order!
        .select any next related by act_if->ACT_EL[R682]->ACT_SMT[R603]
        .if ( empty next )
          .select one next related by act_if->ACT_E[R683]->ACT_SMT[R603]
        .end if
      .else
      .select one eli_te_blk related by act_smt->ACT_EL[R603]->ACT_BLK[R658]->TE_BLK[R2016]
      .if ( not_empty eli_te_blk )
        .invoke r = blck_xlate( trace, eli_te_blk )
        .assign code = code + r.result
        .// CDS Note:  This depends upon the generator storing these in order!
        .select any next related by current_act_if->ACT_EL[R682]->ACT_SMT[R603] where ( selected.LineNumber > act_smt.LineNumber )
        .if ( empty next )
          .select one next related by current_act_if->ACT_E[R683]->ACT_SMT[R603]
          .if ( empty next )
            .select one next related by current_act_if->ACT_SMT[R603]->ACT_SMT[R661.'precedes']
          .end if
        .end if
      .else
      .select one else_te_blk related by act_smt->ACT_E[R603]->ACT_BLK[R606]->TE_BLK[R2016]
      .if ( not_empty else_te_blk )
        .invoke r = blck_xlate( trace, else_te_blk )
        .assign code = code + r.result
        .select one next related by current_act_if->ACT_SMT[R603]->ACT_SMT[R661.'precedes']
      .end if
      .end if
      .end if
      .end if
      .end if
      .if ( "" != te_smt.buffer2 )
        .assign code = ( code + te_smt.buffer2 ) + "\n"
      .end if
      .if ( empty next )
        .select one next related by act_smt->ACT_SMT[R661.'precedes']
      .end if
      .assign act_smt = next
    .end while
    .if ( "" != te_blk.deallocation )
      .assign block_deallocation = ( te_blk.indentation + te_blk.deallocation ) + "\n"
      .assign code = code + block_deallocation
    .end if
  .end if
  .assign attr_result = code
.end function
