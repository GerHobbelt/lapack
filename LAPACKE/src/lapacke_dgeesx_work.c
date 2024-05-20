/*****************************************************************************
  Copyright (c) 2014, Intel Corp.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Intel Corporation nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
  THE POSSIBILITY OF SUCH DAMAGE.
*****************************************************************************
* Contents: Native middle-level C interface to LAPACK function dgeesx
* Author: Intel Corporation
*****************************************************************************/

#include "lapacke_utils.h"

lapack_int API_SUFFIX(LAPACKE_dgeesx_work)( int matrix_layout, char jobvs, char sort,
                                LAPACK_D_SELECT2 select, char sense,
                                lapack_int n, double* a, lapack_int lda,
                                lapack_int* sdim, double* wr, double* wi,
                                double* vs, lapack_int ldvs, double* rconde,
                                double* rcondv, double* work, lapack_int lwork,
                                lapack_int* iwork, lapack_int liwork,
                                lapack_logical* bwork )
{
    lapack_int info = 0;
    if( matrix_layout == LAPACK_COL_MAJOR ) {
        /* Call LAPACK function and adjust info */
        LAPACK_dgeesx( &jobvs, &sort, select, &sense, &n, a, &lda, sdim, wr, wi,
                       vs, &ldvs, rconde, rcondv, work, &lwork, iwork, &liwork,
                       bwork, &info );
        if( info < 0 ) {
            info = info - 1;
        }
    } else if( matrix_layout == LAPACK_ROW_MAJOR ) {
        lapack_int lda_t = MAX(1,n);
        lapack_int ldvs_t = MAX(1,n);
        double* a_t = NULL;
        double* vs_t = NULL;
        /* Check leading dimension(s) */
        if( lda < n ) {
            info = -8;
            API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_dgeesx_work", info );
            return info;
        }
        if( ldvs < n ) {
            info = -13;
            API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_dgeesx_work", info );
            return info;
        }
        /* Query optimal working array(s) size if requested */
        if( liwork == -1 || lwork == -1 ) {
            LAPACK_dgeesx( &jobvs, &sort, select, &sense, &n, a, &lda_t, sdim,
                           wr, wi, vs, &ldvs_t, rconde, rcondv, work, &lwork,
                           iwork, &liwork, bwork, &info );
            return (info < 0) ? (info - 1) : info;
        }
        /* Allocate memory for temporary array(s) */
        a_t = (double*)LAPACKE_malloc( sizeof(double) * lda_t * MAX(1,n) );
        if( a_t == NULL ) {
            info = LAPACK_TRANSPOSE_MEMORY_ERROR;
            goto exit_level_0;
        }
        if( API_SUFFIX(LAPACKE_lsame)( jobvs, 'v' ) ) {
            vs_t = (double*)
                LAPACKE_malloc( sizeof(double) * ldvs_t * MAX(1,n) );
            if( vs_t == NULL ) {
                info = LAPACK_TRANSPOSE_MEMORY_ERROR;
                goto exit_level_1;
            }
        }
        /* Transpose input matrices */
        API_SUFFIX(LAPACKE_dge_trans)( matrix_layout, n, n, a, lda, a_t, lda_t );
        /* Call LAPACK function and adjust info */
        LAPACK_dgeesx( &jobvs, &sort, select, &sense, &n, a_t, &lda_t, sdim, wr,
                       wi, vs_t, &ldvs_t, rconde, rcondv, work, &lwork, iwork,
                       &liwork, bwork, &info );
        if( info < 0 ) {
            info = info - 1;
        }
        /* Transpose output matrices */
        API_SUFFIX(LAPACKE_dge_trans)( LAPACK_COL_MAJOR, n, n, a_t, lda_t, a, lda );
        if( API_SUFFIX(LAPACKE_lsame)( jobvs, 'v' ) ) {
            API_SUFFIX(LAPACKE_dge_trans)( LAPACK_COL_MAJOR, n, n, vs_t, ldvs_t, vs, ldvs );
        }
        /* Release memory and exit */
        if( API_SUFFIX(LAPACKE_lsame)( jobvs, 'v' ) ) {
            LAPACKE_free( vs_t );
        }
exit_level_1:
        LAPACKE_free( a_t );
exit_level_0:
        if( info == LAPACK_TRANSPOSE_MEMORY_ERROR ) {
            API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_dgeesx_work", info );
        }
    } else {
        info = -1;
        API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_dgeesx_work", info );
    }
    return info;
}
