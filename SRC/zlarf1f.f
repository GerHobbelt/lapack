*> \brief \b ZLARF1F applies an elementary reflector to a general rectangular
*              matrix assuming v(1) = 1.
*
*  =========== DOCUMENTATION ===========
*
* Online html documentation available at
*            http://www.netlib.org/lapack/explore-html/
*
*> \htmlonly
*> Download DLARF + dependencies
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.tgz?format=tgz&filename=/lapack/lapack_routine/dlarf.f">
*> [TGZ]</a>
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.zip?format=zip&filename=/lapack/lapack_routine/dlarf.f">
*> [ZIP]</a>
*> <a href="http://www.netlib.org/cgi-bin/netlibfiles.txt?format=txt&filename=/lapack/lapack_routine/dlarf.f">
*> [TXT]</a>
*> \endhtmlonly
*
*  Definition:
*  ===========
*
*       SUBROUTINE ZLARF1F( SIDE, M, N, V, INCV, TAU, C, LDC, WORK )
*
*       .. Scalar Arguments ..
*       CHARACTER          SIDE
*       INTEGER            INCV, LDC, M, N
*       COMPLEX*16         TAU
*       ..
*       .. Array Arguments ..
*       COMPLEX*16         C( LDC, * ), V( * ), WORK( * )
*       ..
*
*
*> \par Purpose:
*  =============
*>
*> \verbatim
*>
*> ZLARF1F applies a complex elementary reflector H to a real m by n matrix
*> C, from either the left or the right. H is represented in the form
*>
*>       H = I - tau * v * v**T
*>
*> where tau is a complex scalar and v is a complex vector.
*>
*> If tau = 0, then H is taken to be the unit matrix.
*>
*> To apply H**H, supply conjg(tau) instead
*> tau.
*> \endverbatim
*
*  Arguments:
*  ==========
*
*> \param[in] SIDE
*> \verbatim
*>          SIDE is CHARACTER*1
*>          = 'L': form  H * C
*>          = 'R': form  C * H
*> \endverbatim
*>
*> \param[in] M
*> \verbatim
*>          M is INTEGER
*>          The number of rows of the matrix C.
*> \endverbatim
*>
*> \param[in] N
*> \verbatim
*>          N is INTEGER
*>          The number of columns of the matrix C.
*> \endverbatim
*>
*> \param[in] V
*> \verbatim
*>          V is COMPLEX*16 array, dimension
*>                     (1 + (M-1)*abs(INCV)) if SIDE = 'L'
*>                  or (1 + (N-1)*abs(INCV)) if SIDE = 'R'
*>          The vector v in the representation of H. V is not used if
*>          TAU = 0.
*> \endverbatim
*>
*> \param[in] INCV
*> \verbatim
*>          INCV is INTEGER
*>          The increment between elements of v. INCV <> 0.
*> \endverbatim
*>
*> \param[in] TAU
*> \verbatim
*>          TAU is COMPLEX*16
*>          The value tau in the representation of H.
*> \endverbatim
*>
*> \param[in,out] C
*> \verbatim
*>          C is COMPLEX*16 array, dimension (LDC,N)
*>          On entry, the m by n matrix C.
*>          On exit, C is overwritten by the matrix H * C if SIDE = 'L',
*>          or C * H if SIDE = 'R'.
*> \endverbatim
*>
*> \param[in] LDC
*> \verbatim
*>          LDC is INTEGER
*>          The leading dimension of the array C. LDC >= max(1,M).
*> \endverbatim
*>
*> \param[out] WORK
*> \verbatim
*>          WORK is COMPLEX*16 array, dimension
*>                         (N) if SIDE = 'L'
*>                      or (M) if SIDE = 'R'
*> \endverbatim
*
*  Authors:
*  ========
*
*> \author Univ. of Tennessee
*> \author Univ. of California Berkeley
*> \author Univ. of Colorado Denver
*> \author NAG Ltd.
*
*> \ingroup larf
*
*  =====================================================================
      SUBROUTINE ZLARF1F( SIDE, M, N, V, INCV, TAU, C, LDC, WORK )
*
*  -- LAPACK auxiliary routine --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*
*     .. Scalar Arguments ..
      CHARACTER          SIDE
      INTEGER            INCV, LDC, M, N
      COMPLEX*16         TAU
*     ..
*     .. Array Arguments ..
      COMPLEX*16         C( LDC, * ), V( * ), WORK( * )
*     ..
*
*  =====================================================================
*
*     .. Parameters ..
      COMPLEX*16         ONE, ZERO
      PARAMETER          ( ONE = ( 1.0D+0, 0.0D+0 ),
     $                   ZERO = ( 0.0D+0, 0.0D+0 ) )
      INTEGER            IONE
      PARAMETER          ( IONE = 1 )
*     ..
*     .. Local Scalars ..
      LOGICAL            APPLYLEFT
      INTEGER            I, LASTV, LASTC, J
*     ..
*     .. External Subroutines ..
      EXTERNAL           ZGEMV, ZGERC
*     ..
*     .. External Functions ..
      LOGICAL            LSAME
      INTEGER            ILADLR, ILADLC
      EXTERNAL           LSAME, ILADLR, ILADLC
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          DCONJG
*     ..
*     .. Executable Statements ..
*
      APPLYLEFT = LSAME( SIDE, 'L' )
      LASTV = 0
      LASTC = 0
      IF( TAU.NE.ZERO ) THEN
!     Set up variables for scanning V.  LASTV begins pointing to the end
!     of V.
         IF( APPLYLEFT ) THEN
            LASTV = M
         ELSE
            LASTV = N
         END IF
         IF( INCV.GT.0 ) THEN
            I = 1 + (LASTV-1) * INCV
         ELSE
            I = 1
         END IF
!     Look for the last non-zero row in V.
         DO WHILE( LASTV.GT.0 .AND. V( I ).EQ.ZERO )
            LASTV = LASTV - 1
            I = I - INCV
         END DO
         IF( APPLYLEFT ) THEN
!     Scan for the last non-zero column in C(1:lastv,:).
            LASTC = ILADLC(LASTV, N, C, LDC)
         ELSE
!     Scan for the last non-zero row in C(:,1:lastv).
            LASTC = ILADLR(M, LASTV, C, LDC)
         END IF
      END IF
      IF( LASTC.EQ.0 .OR. LASTV.EQ.0 ) THEN
         RETURN
      END IF
      IF( APPLYLEFT ) THEN
*
*        Form  H * C
*
         IF( LASTV.GT.0 ) THEN
            ! Check if m = 1. This means v = 1, So we just need to compute
            ! C := HC = (1-\tau)C.
            IF( M.EQ.1 .OR. LASTV.EQ.1) THEN
               CALL ZSCAL(LASTC, ONE - TAU, C, LDC)
            ELSE
*
*              w(1:lastc,1) := C(1:lastv,1:lastc)**H * v(1:lastv,1)
*
               ! w(1:lastc,1) := C(2:lastv,1:lastc)**H * v(2:lastv,1)
               CALL ZGEMV( 'Conj', LASTV-1, LASTC, ONE, C(1+1,1), LDC,
     $                     V(1+INCV), INCV, ZERO, WORK, 1)
               ! w(1:lastc,1) += C(1,1:lastc) * v(1,1) = C(1,1:lastc)
               DO I = 1, LASTC 
                  WORK(I) = WORK(I) + DCONJG(C(1,I))
               END DO
*
*           C(1:lastv,1:lastc) := C(...) - tau * v(1:lastv,1) * w(1:lastc,1)**T
*
            ! C(1, 1:lastc)   := C(...) - tau * v(1,1) * w(1:lastc,1)**T
            !                  = C(...) - tau * w(1:lastc,1)
               CALL ZAXPY(LASTC, -TAU, WORK, 1, C, LDC)
               ! C(2:lastv,1:lastc) := C(...) - tau * v(2:lastv,1)*w(1:lastc,1)**T
               CALL ZGERC(LASTV-1, LASTC, -TAU, V(1+INCV), INCV, WORK,
     $                     1, C(1+1,1), LDC)
            END IF
         END IF
      ELSE
*
*        Form  C * H
*
         IF( LASTV.GT.0 ) THEN
            ! Check if n = 1. This means v = 1, so we just need to compute
            ! C := CH = C(1-\tau).
            IF( N.EQ.1 .OR. LASTV.EQ.1) THEN
               CALL ZSCAL(LASTC, ONE - TAU, C, 1)
            ELSE
*
*              w(1:lastc,1) := C(1:lastc,1:lastv) * v(1:lastv,1)
*
               ! w(1:lastc,1) := C(1:lastc,2:lastv) * v(2:lastv,1)
               CALL ZGEMV( 'No transpose', LASTC, LASTV-1, ONE, 
     $            C(1,1+1), LDC, V(1+INCV), INCV, ZERO, WORK, 1 )
               ! w(1:lastc,1) += C(1:lastc,1) v(1,1) = C(1:lastc,1)
               CALL ZAXPY(LASTC, ONE, C, 1, WORK, 1)
*
*              C(1:lastc,1:lastv) := C(...) - tau * w(1:lastc,1) * v(1:lastv,1)**T
*
               ! C(1:lastc,1)     := C(...) - tau * w(1:lastc,1) * v(1,1)**T
               !                   = C(...) - tau * w(1:lastc,1)
               CALL ZAXPY(LASTC, -TAU, WORK, 1, C, 1)
               ! C(1:lastc,2:lastv) := C(...) - tau * w(1:lastc,1) * v(2:lastv)**T
               CALL ZGERC( LASTC, LASTV-1, -TAU, WORK, 1, V(1+INCV),
     $                     INCV, C(1,1+1), LDC )
            END IF
         END IF
      END IF
      RETURN
*
*     End of DLARF
*
      END
