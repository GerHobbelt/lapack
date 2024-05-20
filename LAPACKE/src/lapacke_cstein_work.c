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
* Contents: Native middle-level C interface to LAPACK function cstein
* Author: Intel Corporation
*****************************************************************************/

#include "lapacke_utils.h"

lapack_int API_SUFFIX(LAPACKE_cstein_work)( int matrix_layout, lapack_int n, const float* d,
                                const float* e, lapack_int m, const float* w,
                                const lapack_int* iblock,
                                const lapack_int* isplit,
                                lapack_complex_float* z, lapack_int ldz,
                                float* work, lapack_int* iwork,
                                lapack_int* ifailv )
{
    lapack_int info = 0;
    if( matrix_layout == LAPACK_COL_MAJOR ) {
        /* Call LAPACK function and adjust info */
        LAPACK_cstein( &n, d, e, &m, w, iblock, isplit, z, &ldz, work, iwork,
                       ifailv, &info );
        if( info < 0 ) {
            info = info - 1;
        }
    } else if( matrix_layout == LAPACK_ROW_MAJOR ) {
        lapack_int ldz_t = MAX(1,n);
        lapack_complex_float* z_t = NULL;
        /* Check leading dimension(s) */
        if( ldz < m ) {
            info = -10;
            API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_cstein_work", info );
            return info;
        }
        /* Allocate memory for temporary array(s) */
        z_t = (lapack_complex_float*)
            LAPACKE_malloc( sizeof(lapack_complex_float) * ldz_t * MAX(1,m) );
        if( z_t == NULL ) {
            info = LAPACK_TRANSPOSE_MEMORY_ERROR;
            goto exit_level_0;
        }
        /* Call LAPACK function and adjust info */
        LAPACK_cstein( &n, d, e, &m, w, iblock, isplit, z_t, &ldz_t, work,
                       iwork, ifailv, &info );
        if( info < 0 ) {
            info = info - 1;
        }
        /* Transpose output matrices */
        API_SUFFIX(LAPACKE_cge_trans)( LAPACK_COL_MAJOR, n, m, z_t, ldz_t, z, ldz );
        /* Release memory and exit */
        LAPACKE_free( z_t );
exit_level_0:
        if( info == LAPACK_TRANSPOSE_MEMORY_ERROR ) {
            API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_cstein_work", info );
        }
    } else {
        info = -1;
        API_SUFFIX(LAPACKE_xerbla)( "LAPACKE_cstein_work", info );
    }
    return info;
}
