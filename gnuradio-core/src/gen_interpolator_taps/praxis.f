C
C Copyright 2002 Free Software Foundation, Inc.
C
C This file is part of GNU Radio
C
C GNU Radio is free software; you can redistribute it and/or modify
C it under the terms of the GNU General Public License as published by
C the Free Software Foundation; either version 2, or (at your option)
C any later version.
C
C GNU Radio is distributed in the hope that it will be useful,
C but WITHOUT ANY WARRANTY; without even the implied warranty of
C MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C GNU General Public License for more details.
C
C You should have received a copy of the GNU General Public License
C along with GNU Radio; see the file COPYING.  If not, write to
C the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
C Boston, MA 02111-1307, USA.
C
      DOUBLE PRECISION FUNCTION PRAX2(F,INITV,NDIM,OUT)
      DOUBLE PRECISION INITV(128),OUT(128), F
      INTEGER NDIM
      EXTERNAL F
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH

C
      N=NDIM
      do 10 I=1,N
 10      X(I) = INITV(I)

C
      call praset

C -1 produces no diagnostic output
      jprint = -1
      nfmax = 3000
C tighter tolerance
      T=1.0D-6
C
      call praxis(f)
C
      do 30 I=1,N
 30      OUT(I) = X(I)
C
      prax2 = fx
      return
      end


      SUBROUTINE PRASET
C
C  PRASET 1.0           JUNE 1995
C
C  SET INITIAL VALUES FOR SOME QUANTITIES USED IN SUBROUTINE PRAXIS.
C  THE USER CAN RESET THESE, IF DESIRED,
C  AFTER CALLING PRASET AND BEFORE CALLING PRAXIS.
C
C  J. P. CHANDLER, COMPUTER SCIENCE DEPARTMENT,
C     OKLAHOMA STATE UNIVERSITY
C
C  ON MANY MACHINES, SUBROUTINE PRAXIS WILL CAUSE UNDERFLOW AND/OR
C  DIVIDE CHECK WHEN COMPUTING EPSMCH**4 AND EPSMCH**(-4).
C  IN THAT CASE, SET EPSMCH=1.0D-9 (OR POSSIBLY EPSMCH=1.0D-8)
C  AFTER CALLING SUBROUTINE PRASET.
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER J
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION A,B,XMID,XPLUS,RZERO,UNITR,RTWO
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      RZERO=0.0D0
      UNITR=1.0D0
      RTWO=2.0D0
C
C  NMAX IS THE DIMENSION OF THE ARRAYS V(*,*), X(*), D(*),
C  Q0(*), AND Q1(*).
C
      NMAX=128
C
C  NFMAX IS THE MAXIMUM NUMBER OF FUNCTION EVALUATIONS PERMITTED.
C
      NFMAX=100000
C
C  LP IS THE LOGICAL UNIT NUMBER FOR PRINTED OUTPUT.
C
      LP=6
C
C  T IS A CONVERGENCE TOLERANCE USED IN SUBROUTINE PRAXIS.
C
      T=1.0D-5
C
C  JPRINT CONTROLS PRINTED OUTPUT IN PRAXIS.
C
      JPRINT=4
C
C  H IS AN ESTIMATE OF THE DISTANCE FROM THE INITIAL POINT
C  TO THE SOLUTION.
C
      H=1.0D0
C
C  USE BISECTION TO COMPUTE THE VALUE OF EPSMCH, "MACHINE EPSILON".
C  EPSMCH IS THE SMALLEST FLOATING POINT (REAL OR DOUBLE PRECISION)
C  NUMBER WHICH, WHEN ADDED TO ONE, GIVES A RESULT GREATER THAN ONE.
C
      A=RZERO
      B=UNITR
   10 XMID=A+(B-A)/RTWO
      IF(XMID.LE.A .OR. XMID.GE.B) GO TO 20
      XPLUS=UNITR+XMID
      IF(XPLUS.GT.UNITR) THEN
         B=XMID
      ELSE
         A=XMID
      ENDIF
      GO TO 10
C
   20 EPSMCH=B
C
      DO 30 J=1,NMAX
         X(J)=RZERO
   30 CONTINUE
C
C  JRANCH = 1 TO USE BRENT'S RANDOM,
C  JRANCH = 2 TO USE FUNCTION DRANDM.
C
      JRANCH=1
C
      CALL RANINI(4.0D0)
C
C  DSEED IS AN INITIAL SEED FOR DRANDM,
C  A SUBROUTINE THAT GENERATES PSEUDORANDOM NUMBERS
C  UNIFORMLY DISTRIBUTED ON (0,1).
C
      DSEED=1234567.0D0
C
C  SCBD IS AN UPPER BOUND ON THE SCALE FACTORS IN PRAXIS.
C  IF THE AXES MAY BE BADLY SCALED (WHICH IS TO BE AVOIDED IF
C  POSSIBLE) THEN SET SCBD = 10, OTHERWISE 1.
C
      SCBD=1.0D0
C
C  ILLCIN IS THE INITIAL VALUE OF ILLC,
C  THE FLAG THAT SIGNALS AN ILL-CONDITIONED PROBLEM.
C  IF THE PROBLEM IS KNOWN TO BE ILL-CONDITIONED SET ILLCIN=1,
C  OTHERWISE 0.
C
      ILLCIN=0
C
C  KTM IS A CONVERGENCE SWITCH USED IN PRAXIS.
C  KTM+1 IS THE NUMBER OF ITERATIONS WITHOUT IMPROVEMENT
C  BEFORE THE ALGORITHM TERMINATES.
C  KTM=4 IS VERY CAUTIOUS.
C  USUALLY KTM=1 IS SATISFACTORY.
C
      KTM=1
C
      RETURN
C
C  END PRASET
C
      END
      SUBROUTINE PRAXIS(F)
C
C  PRAXIS 2.0        JUNE 1995
C
C  THE PRAXIS PACKAGE MINIMIZES THE FUNCTION F(X,N) OF N
C  VARIABLES X(1),...,X(N), USING THE PRINCIPAL AXIS METHOD.
C  F MUST BE A SMOOTH (CONTINUOUSLY DIFFERENTIABLE) FUNCTION.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C     RICHARD P. BRENT, PRENTICE-HALL 1973 (ISBN 0-13-022335-2),
C     PAGES 156-167
C
C  TRANSLATED FROM ALGOL W TO A.N.S.I. 1966 STANDARD BASIC FORTRAN
C     BY ROSALEE TAYLOR AND SUE PINSKI, COMPUTER SCIENCE DEPARTMENT,
C     OKLAHOMA STATE UNIVERSITY (DECEMBER 1973).
C
C  UPDATED TO A.N.S.I. STANDARD FORTRAN 77 BY J. P. CHANDLER
C     COMPUTER SCIENCE DEPARTMENT, OKLAHOMA STATE UNIVERSITY
C
C
C  SUBROUTINE PRAXIS CALLS SUBPROGRAMS
C     F, MINX, RANDOM (OR DRANDM), QUAD, MINFIT, SORT.
C
C  SUBROUTINE QUAD CALLS MINX.
C
C  SUBROUTINE MINX CALLS FLIN.
C
C  SUBROUTINE FLIN CALLS F.
C
C
C  INPUT QUANTITIES (SET IN THE CALLING PROGRAM)...
C
C     F        FUNCTION F(X,N) TO BE MINIMIZED
C
C     X(*)     INITIAL GUESS OF MINIMUM
C
C     N        DIMENSION OF X  (NOTE...  N MUST BE .GE. 2)
C
C     H        MAXIMUM STEP SIZE
C
C     T        TOLERANCE
C
C     EPSMCH   MACHINE PRECISION
C
C     JPRINT   PRINT SWITCH
C
C
C  OUTPUT QUANTITIES...
C
C     X(*)     ESTIMATED POINT OF MINIMUM
C
C     FX       VALUE OF F AT X
C
C     NL       NUMBER OF LINEAR SEARCHES
C
C     NF       NUMBER OF FUNCTION EVALUATIONS
C
C     V(*,*)   EIGENVECTORS OF A
C                 NEW DIRECTIONS
C
C     D(*)     EIGENVALUES OF A
C                 NEW D
C
C     Z(*)     SCALE FACTORS
C
C
C  ON ENTRY X(*) HOLDS A GUESS.  ON RETURN IT HOLDS THE ESTIMATED
C  POINT OF MINIMUM, WITH (HOPEFULLY)
C  ABS(ERROR) LESS THAN SQRT(EPSMCH)*ABS(X) + T, WHERE
C  EPSMCH IS THE MACHINE PRECISION, THE SMALLEST NUMBER SUCH THAT
C  (1 + EPSMCH) IS GREATER THAN 1.
C
C  T IS A TOLERANCE.
C
C  H IS THE MAXIMUM STEP SIZE, SET TO ABOUT THE MAXIMUM EXPECTED
C  DISTANCE FROM THE GUESS TO THE MINIMUM.  IF H IS SET TOO
C  SMALL OR TOO LARGE THEN THE INITIAL RATE OF CONVERGENCE WILL
C  BE SLOW.
C
C  THE USER SHOULD OBSERVE THE COMMENT ON HEURISTIC NUMBERS
C  AT THE BEGINNING OF THE SUBROUTINE.
C
C  JPRINT CONTROLS THE PRINTING OF INTERMEDIATE RESULTS.
C  IT USES SUBROUTINES FLIN, MINX, QUAD, SORT, AND MINFIT.
C  IF JPRINT = 1, F IS PRINTED AFTER EVERY N+1 OR N+2 LINEAR
C  MINIMIZATIONS, AND FINAL X IS PRINTED, BUT INTERMEDIATE
C  X ONLY IF N IS LESS THAN OR EQUAL TO 4.
C  IF JPRINT = 2, EIGENVALUES OF A AND SCALE FACTORS ARE ALSO PRINTED.
C  IF JPRINT = 3, F AND X ARE PRINTED AFTER EVERY FEW LINEAR
C  MINIMIZATIONS.
C  IF JPRINT = 4, EIGENVECTORS ARE ALSO PRINTED.
C  IF JPRINT = 5, ADDITIONAL DEBUGGING INFORMATION IS ALSO PRINTED.
C
C  RANDOM RETURNS A RANDOM NUMBER UNIFORMLY DISTRIBUTED IN (0, 1).
C
C  THIS SUBROUTINE IS MACHINE-INDEPENDENT, APART FROM THE
C  SPECIFICATION OF EPSMCH.  WE ASSUME THAT EPSMCH**(-4) DOES NOT
C  OVERFLOW (IF IT DOES THEN EPSMCH MUST BE INCREASED), AND THAT ON
C  FLOATING-POINT UNDERFLOW THE RESULT IS SET TO ZERO.
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER ILLC,I,IK,IM,IMU,J,K,KL,KM1,KT,K2
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION F,   Y,Z,E,   DABS,DSQRT,ZABS,ZSQRT,DRANDM,
     *   HUNDRD,HUNDTH,ONE,PT9,RHALF,TEN,TENTH,TWO,ZERO,
     *   DF,DLDFAC,DN,F1,XF,XL,T2,RANVAL,ARG,
     *   VLARGE,VSMALL,XLARGE,XLDS,FXVALU,F1VALU,S,SF,SL
C
      EXTERNAL F
C
      DIMENSION Y(128),Z(128),E(128)
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      ZABS(ARG)=DABS(ARG)
      ZSQRT(ARG)=DSQRT(ARG)
C
C  INITIALIZATION...
C
      RHALF=0.5D0
      ONE=1.0D0
      TENTH=0.1D0
      HUNDTH=0.01D0
      HUNDRD=100.0D0
      ZERO=0.0D0
      PT9=0.9D0
      TEN=10.0D0
      TWO=2.0D0
C
C  MACHINE DEPENDENT NUMBERS...
C
C  ON MANY COMPUTERS, VSMALL WILL UNDERFLOW,
C  AND COMPUTING XLARGE MAY CAUSE A DIVISION BY ZERO.
C  IN THAT CASE, EPSMCH SHOULD BE SET EQUAL TO 1.0D-9
C  (OR POSSIBLY 1.0D-8) BEFORE CALLING PRAXIS.
C
      SMALL=EPSMCH*EPSMCH
      VSMALL=SMALL*SMALL
      XLARGE=ONE/SMALL
      VLARGE=ONE/VSMALL
      XM2=ZSQRT(EPSMCH)
      XM4=ZSQRT(XM2)
C
C  HEURISTIC NUMBERS...
C
C  IF THE AXES MAY BE BADLY SCALED (WHICH IS TO BE AVOIDED IF
C  POSSIBLE) THEN SET SCBD = 10, OTHERWISE 1.
C
C  IF THE PROBLEM IS KNOWN TO BE ILL-CONDITIONED SET ILLC = 1,
C  OTHERWISE 0.
C
C  KTM+1 IS THE NUMBER OF ITERATIONS WITHOUT IMPROVEMENT
C  BEFORE THE ALGORITHM TERMINATES.
C  KTM=4 IS VERY CAUTIOUS.
C  USUALLY KTM=1 IS SATISFACTORY.
C
C  BRENT RECOMMENDED THE FOLLOWING VALUES FOR MOST PROBLEMS...
C
C                    SCBD=1.0
C                    ILLC=0
C                    KTM=1
C
C  SCBD, ILLCIN, AND KTM ARE NOW IN COMMON.
C  THEY ARE INITIALIZED IN SUBROUTINE PRASET,
C  AND CAN BE RESET BY THE USER AFTER CALLING PRASET.
C
      ILLC=ILLCIN
C
      IF(ILLC.EQ.1) THEN
         DLDFAC=TENTH
      ELSE
         DLDFAC=HUNDTH
      ENDIF
C
      KT=0
      NL=0
      NF=1
      FX=F(X,N)
      QF1=FX
      T=SMALL+ZABS(T)
      T2=T
      DMIN=SMALL
      IF(H.LT.HUNDRD*T) H=HUNDRD*T
      XLDT=H
C
      DO 20 I=1,N
         DO 10 J=1,N
            V(I,J)=ZERO
   10    CONTINUE
         V(I,I)=ONE
   20 CONTINUE
C
      QD0=ZERO
      D(1)=ZERO
C
C  Q0(*) AND Q1(*) ARE PREVIOUS X(*) POINTS,
C  INITIALIZED IN PRAXIS, USED IN FLIN,
C  AND CHANGED IN QUAD.
C
      DO 30 I=1,N
         Q1(I)=X(I)
C
C  Q0(*) WAS NOT INITIALIZED IN BRENT'S ALGOL PROCEDURE.
C
         Q0(I)=X(I)
   30 CONTINUE
C
      IF(JPRINT.GT.0) THEN
         WRITE(LP,40)NL,NF,FX
   40    FORMAT(/' NL =',I10,5X,'NF =',I10/5X,'FX =',1PG15.7)
C
         IF(N.LE.4 .OR. JPRINT.GT.2) THEN
            WRITE(LP,50)(X(I),I=1,N)
   50       FORMAT(/8X,'X'/(1X,1PG15.7,4G15.7))
         ENDIF
      ENDIF
C
C  MAIN LOOP...
C  LABEL L0...
C
   60 SF=D(1)
      S=ZERO
      D(1)=ZERO
C
C  MINIMIZE ALONG THE FIRST DIRECTION.
C
      IF(JPRINT.GE.5) WRITE(LP,70)D(1),S,FX
   70 FORMAT(/' CALL NO. 1 TO MINX.'/
     *   5X,'D(1) =',1PG15.7,5X,'S =',G15.7,5X,'FX =',G15.7)
C
      FXVALU=FX
      CALL MINX(1,2,D(1),S,FXVALU,0,F)
C
      IF(S.LE.ZERO) THEN
         DO 80 I=1,N
            V(I,1)=-V(I,1)
   80    CONTINUE
      ENDIF
C
      IF(SF.LE.PT9*D(1) .OR. PT9*SF.GE.D(1)) THEN
C
         IF(N.GE.2) THEN
            DO 90 I=2,N
               D(I)=ZERO
   90       CONTINUE
         ENDIF
C
      ENDIF
C
      IF(N.LT.2) GO TO 320
      DO 310 K=2,N
C
         DO 100 I=1,N
            Y(I)=X(I)
  100    CONTINUE
C
         SF=FX
         IF(KT.GT.0) ILLC=1
C
C  LABEL L1...
C
  110    KL=K
         DF=ZERO
C
         IF(ILLC.EQ.1) THEN
C
C  TAKE A RANDOM STEP TO GET OUT OF A RESOLUTION VALLEY.
C
C  PRAXIS ASSUMES THAT RANDOM (OR DRANDM) RETURNS
C  A PSEUDORANDOM NUMBER UNIFORMLY DISTRIBUTED IN (0,1),
C  AND THAT ANY INITIALIZATION OF THE RANDOM NUMBER GENERATOR
C  HAS ALREADY BEEN DONE.
C
            DO 130 I=1,N
C
               IF(JRANCH.EQ.1) THEN
                  CALL RANDOM(RANVAL)
               ELSE
                  RANVAL=DRANDM(DSEED)
               ENDIF
C
               S=(TENTH*XLDT+T2*TEN**KT)*(RANVAL-RHALF)
               Z(I)=S
C
               DO 120 J=1,N
                  X(J)=X(J)+S*V(J,I)
  120          CONTINUE
  130       CONTINUE
C
            FX=F(X,N)
            NF=NF+1
C
            IF(JPRINT.GE.1) WRITE(LP,140)NF,SF,FX
  140       FORMAT(/' *****  RANDOM STEP IN PRAXIS.   NF =',I11/
     *         5X,'SF =',1PG15.7,5X,'FX =',G15.7)
         ENDIF
C
         IF(K.GT.N) GO TO 170
         DO 160 K2=K,N
            SL=FX
            S=ZERO
C
C  MINIMIZE ALONG NON-CONJUGATE DIRECTIONS.
C
            IF(JPRINT.GE.5) WRITE(LP,150)K2,D(K2),S,FX
  150       FORMAT(/' CALL NO. 2 TO MINX.'/
     *         5X,'K2 =',I4,5X,'D(K2) =',1PG15.7,5X,
     *         'S =',G15.7/5X,'FX =',G15.7)
C
            FXVALU=FX
            CALL MINX(K2,2,D(K2),S,FXVALU,0,F)
C
            IF(ILLC.EQ.1) THEN
               S=D(K2)*(S+Z(K2))**2
            ELSE
               S=SL-FX
            ENDIF
C
            IF(DF.LT.S) THEN
               DF=S
               KL=K2
            ENDIF
  160    CONTINUE
C
  170    IF(ILLC.EQ.0 .AND. DF.LT.ZABS(HUNDRD*EPSMCH*FX)) THEN
C
C  NO SUCCESS WITH ILLC=0, SO TRY ONCE WITH ILLC=1 .
C
            ILLC=1
C
C  GO TO L1.
C
            GO TO 110
         ENDIF
C
         IF(K.EQ.2 .AND. JPRINT.GT.1) THEN
            WRITE(LP,180)(D(I),I=1,N)
  180       FORMAT(/' NEW D'/(1X,1PG15.7,4G15.7))
         ENDIF
C
         KM1=K-1
         IF(KM1.LT.1) GO TO 210
         DO 200 K2=1,KM1
C
C  MINIMIZE ALONG CONJUGATE DIRECTIONS.
C
            IF(JPRINT.GE.5) WRITE(LP,190)K2,D(K2),S,FX
  190       FORMAT(/' CALL NO. 3 TO MINX.'/
     *         5X,'K2 =',I4,5X,'D(K2) =',1PG15.7,5X,
     *         'S =',G15.7/5X,'FX =',G15.7)
C
            S=ZERO
            FXVALU=FX
            CALL MINX(K2,2,D(K2),S,FXVALU,0,F)
  200    CONTINUE
C
  210    F1=FX
         FX=SF
C
         XLDS=ZERO
         DO 220 I=1,N
            SL=X(I)
            X(I)=Y(I)
            SL=SL-Y(I)
            Y(I)=SL
            XLDS=XLDS+SL*SL
  220    CONTINUE
C
         XLDS=ZSQRT(XLDS)
         IF(XLDS.GT.SMALL) THEN
C
C  THROW AWAY THE DIRECTION KL AND MINIMIZE ALONG
C  THE NEW CONJUGATE DIRECTION.
C
            IK=KL-1
            IF(K.GT.IK) GO TO 250
            DO 240 IM=K,IK
               I=IK-IM+K
C
               DO 230 J=1,N
                  V(J,I+1)=V(J,I)
  230          CONTINUE
C
               D(I+1)=D(I)
  240       CONTINUE
C
  250       D(K)=ZERO
C
            DO 260 I=1,N
               V(I,K)=Y(I)/XLDS
  260       CONTINUE
C
            IF(JPRINT.GE.5) WRITE(LP,270)K,D(K),XLDS,F1
  270       FORMAT(/' CALL NO. 4 TO MINX.'/
     *         5X,'K =',I4,5X,'D(K) =',1PG15.7,5X,
     *         'XLDS =',G15.7/5X,'F1 =',G15.7)
C
            F1VALU=F1
            CALL MINX(K,4,D(K),XLDS,F1VALU,1,F)
C
            IF(XLDS.LE.ZERO) THEN
               XLDS=-XLDS
C
               DO 280 I=1,N
                  V(I,K)=-V(I,K)
  280          CONTINUE
            ENDIF
         ENDIF
C
         XLDT=DLDFAC*XLDT
         IF(XLDT.LT.XLDS) XLDT=XLDS
C
         IF(JPRINT.GT.0) THEN
            WRITE(LP,40)NL,NF,FX
            IF(N.LE.4 .OR. JPRINT.GT.2) THEN
               WRITE(LP,50)(X(I),I=1,N)
            ENDIF
         ENDIF
C
         T2=ZERO
         DO 290 I=1,N
            T2=T2+X(I)**2
  290    CONTINUE
         T2=XM2*ZSQRT(T2)+T
C
C  SEE IF THE STEP LENGTH EXCEEDS HALF THE TOLERANCE.
C
         IF(XLDT.GT.RHALF*T2) THEN
            KT=0
         ELSE
            KT=KT+1
         ENDIF
C
C  IF(...) GO TO L2
C
         IF(KT.GT.KTM) GO TO 550
C
         IF(NF.GE.NFMAX) THEN
            WRITE(LP,300)NFMAX
  300       FORMAT(/' IN PRAXIS, NF REACHED THE LIMIT NFMAX =',I11/
     *         5X,'THIS IS AN ABNORMAL TERMINATION.'/
     *         5X,'THE FUNCTION HAS NOT BEEN MINIMIZED AND',
     *         ' THE RESULTING X(*) VECTOR SHOULD NOT BE USED.')
            GO TO 550
         ENDIF
C
  310 CONTINUE
C
C  TRY QUADRATIC EXTRAPOLATION IN CASE WE ARE STUCK IN A CURVED VALLEY.
C
  320 CALL QUAD(F)
C
      DN=ZERO
      DO 330 I=1,N
         D(I)=ONE/ZSQRT(D(I))
         IF(DN.LT.D(I)) DN=D(I)
  330 CONTINUE
C
      IF(JPRINT.GT.3) THEN
C
         WRITE(LP,340)
  340    FORMAT(/' NEW DIRECTIONS')
C
         DO 360 I=1,N
            WRITE(LP,350)I,(V(I,J),J=1,N)
  350       FORMAT(1X,I5,4X,1PG15.7,4G15.7/(10X,5G15.7))
  360    CONTINUE
      ENDIF
C
      DO 380 J=1,N
C
         S=D(J)/DN
         DO 370 I=1,N
            V(I,J)=S*V(I,J)
  370    CONTINUE
  380 CONTINUE
C
      IF(SCBD.GT.ONE) THEN
C
C  SCALE THE AXES TO TRY TO REDUCE THE CONDITION NUMBER.
C
         S=VLARGE
         DO 400 I=1,N
C
            SL=ZERO
            DO 390 J=1,N
               SL=SL+V(I,J)**2
  390       CONTINUE
C
            Z(I)=ZSQRT(SL)
            IF(Z(I).LT.XM4) Z(I)=XM4
            IF(S.GT.Z(I)) S=Z(I)
  400    CONTINUE
C
         DO 410 I=1,N
            SL=S/Z(I)
            Z(I)=ONE/SL
C
            IF(Z(I).GT.SCBD) THEN
               SL=ONE/SCBD
               Z(I)=SCBD
            ENDIF
C
C  IT APPEARS THAT THERE ARE TWO MISSING END; STATEMENTS
C  AT THIS POINT IN BRENT'S LISTING.
C
  410    CONTINUE
      ENDIF
C
C  TRANSPOSE V FOR MINFIT.
C
      IF(N.LT.2) GO TO 440
      DO 430 I=2,N
C
         IMU=I-1
         DO 420 J=1,IMU
            S=V(I,J)
            V(I,J)=V(J,I)
            V(J,I)=S
  420    CONTINUE
  430 CONTINUE
C
C  FIND THE SINGULAR VALUE DECOMPOSITION OF V.
C  THIS GIVES THE EIGENVALUES AND PRINCIPAL AXES
C  OF THE APPROXIMATING QUADRATIC FORM
C  WITHOUT SQUARING THE CONDITION NUMBER.
C
  440 CALL MINFIT(N,EPSMCH,VSMALL,V,D,E,NMAX,LP)
C
      IF(SCBD.GT.ONE) THEN
C
C  UNSCALING...
C
         DO 460 I=1,N
C
            S=Z(I)
            DO 450 J=1,N
               V(I,J)=S*V(I,J)
  450       CONTINUE
  460    CONTINUE
C
         DO 490 I=1,N
C
            S=ZERO
            DO 470 J=1,N
               S=S+V(J,I)**2
  470       CONTINUE
            S=ZSQRT(S)
C
            D(I)=S*D(I)
C
            S=ONE/S
            DO 480 J=1,N
               V(J,I)=S*V(J,I)
  480       CONTINUE
  490    CONTINUE
      ENDIF
C
      DO 500 I=1,N
C
         IF(DN*D(I).GT.XLARGE) THEN
            D(I)=VSMALL
         ELSE IF(DN*D(I).LT.SMALL) THEN
            D(I)=VLARGE
         ELSE
            D(I)=ONE/(DN*D(I))**2
         ENDIF
  500 CONTINUE
C
C  SORT THE NEW EIGENVALUES AND EIGENVECTORS.
C
      CALL SORT
C
      DMIN=D(N)
      IF(DMIN.LT.SMALL) DMIN=SMALL
C
      IF(XM2*D(1).GT.DMIN) THEN
         ILLC=1
      ELSE
         ILLC=0
      ENDIF
C
      IF(JPRINT.GT.1 .AND. SCBD.GT.ONE) THEN
         WRITE(LP,510)(Z(I),I=1,N)
  510    FORMAT(/' SCALE FACTORS'/(1X,1PG15.7,4G15.7))
      ENDIF
C
      IF(JPRINT.GT.1) THEN
         WRITE(LP,520)(D(I),I=1,N)
  520    FORMAT(/' EIGENVALUES OF A'/(1X,1PG15.7,4G15.7))
      ENDIF
C
      IF(JPRINT.GT.3) THEN
C
         WRITE(LP,530)
  530    FORMAT(/' EIGENVECTORS OF A')
C
         DO 540 I=1,N
            WRITE(LP,350)I,(V(I,J),J=1,N)
  540    CONTINUE
      ENDIF
C
C  GO BACK TO THE MAIN LOOP.
C  GO TO L0
C
C  HANDLE THE CASE N .EQ. 1 IN AN AD HOC WAY.
C  (BRENT DID NOT PROVIDE FOR THIS CASE.)
C
      IF(N.GE.2) GO TO 60
C
C  LABEL L2...
C
  550 IF(JPRINT.GT.0) THEN
         WRITE(LP,560)(X(I),I=1,N)
  560    FORMAT(//7X,'X'/(1X,1PG15.7,4G15.7))
      ENDIF
C
      FX=F(X,N)
C
      IF(JPRINT.GE.0) WRITE(LP,570)FX,NL,NF
  570 FORMAT(/' EXIT PRAXIS.   FX =',1PG25.17,5X,'NL =',I8,
     *   5X,'NF =',I9)
C
      RETURN
C
C  END PRAXIS
C
      END
      SUBROUTINE QUAD(F)
C
C  THIS SUBROUTINE LOOKS FOR THE MINIMUM ALONG
C  A CURVE DEFINED BY Q0, Q1, AND X.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGE 161
C
C  SUBROUTINE QUAD IS CALLED BY SUBROUTINE PRAXIS.
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER I
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION F,   DSQRT,ZSQRT,ARG,
     *   ONE,QA,QB,QC,S,TWO,XL,ZERO,QF1VAL
C
      EXTERNAL F
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      ZSQRT(ARG)=DSQRT(ARG)
C
      ZERO=0.0D0
      ONE=1.0D0
C
      S=FX
      FX=QF1
      QF1=S
      QD1=ZERO
C
      DO 10 I=1,N
         S=X(I)
         XL=Q1(I)
         X(I)=XL
         Q1(I)=S
         QD1=QD1+(S-XL)**2
   10 CONTINUE
C
      QD1=ZSQRT(QD1)
      XL=QD1
      S=ZERO
C
      IF(QD0.GT.ZERO .AND. QD1.GT.ZERO .AND. NL.GE.3*N*N) THEN
C
         IF(JPRINT.GE.1) WRITE(LP,20)NF,QD0,QD1,FX,QF1
   20    FORMAT(/' *****  CALL MINX FROM QUAD.   NF =',I11/
     *      5X,'QD0 =',1PG15.7,5X,'QD1 =',G15.7/
     *      5X,'FX  =',G15.7,5X,'QF1 =',G15.7)
C
         QF1VAL=QF1
         CALL MINX(0,2,S,XL,QF1VAL,1,F)
         QA=XL*(XL-QD1)/(QD0*(QD0+QD1))
         QB=(XL+QD0)*(QD1-XL)/(QD0*QD1)
         QC=XL*(XL+QD0)/(QD1*(QD0+QD1))
      ELSE
         FX=QF1
         QA=ZERO
         QB=ZERO
         QC=ONE
      ENDIF
C
      QD0=QD1
C
      DO 30 I=1,N
         S=Q0(I)
         Q0(I)=X(I)
         X(I)=QA*S+QB*X(I)+QC*Q1(I)
   30 CONTINUE
C
      RETURN
C
C  END QUAD
C
      END
      SUBROUTINE MINX(J,NITS,D2,X1,F1,IFK,F)
C
C  SUBROUTINE MINX MINIMIZES F FROM X IN THE DIRECTION V(*,J)
C  UNLESS J IS LESS THAN 1, WHEN A QUADRATIC SEARCH IS DONE IN
C  THE PLANE DEFINED BY Q0, Q1, AND X.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 159-160
C
C  SUBROUTINE MINX IS CALLED BY SUBROUTINES PRAXIS AND QUAD.
C
C  D2 AND X1 RETURN RESULTS.
C  J, NITS, F1 AND IFK ARE VALUE PARAMETERS THAT RETURN NOTHING.
C  DO NOT SEND A COMMON VARIABLE TO MINX FOR PARAMETER F1.
C
C
C  D2 IS AN APPROXIMATION TO HALF OF
C  THE SECOND DERIVATIVE OF F (OR ZERO).
C
C  X1 IS AN ESTIMATE OF DISTANCE TO MINIMUM,
C  RETURNED AS THE DISTANCE FOUND.
C
C  IF IFK = 1 THEN F1 IS FLIN(X1), OTHERWISE X1 AND F1 ARE
C  IGNORED ON ENTRY UNLESS FINAL FX IS GREATER THAN F1.
C
C  NITS CONTROLS THE NUMBER OF TIMES AN ATTEMPT IS MADE TO
C  HALVE THE INTERVAL.
C
      EXTERNAL F
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER IFK,J,NITS,     I,IDZ,K
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION D2,X1,
     *   DABS,DSQRT,ZABS,ZSQRT,ARG,
     *   HUNDTH,RHALF,TWO,ZERO,
     *   DENOM,D1,FM,F0,F1,F2,S,SF1,SX1,T2,XM,X2
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      ZSQRT(ARG)=DSQRT(ARG)
      ZABS(ARG)=DABS(ARG)
C
      HUNDTH=0.01D0
      ZERO=0.0D0
      TWO=2.0D0
      RHALF=0.5D0
C
      SF1=F1
      SX1=X1
      K=0
      XM=ZERO
      FM=FX
      F0=FX
C
      IF(D2.LT.EPSMCH) THEN
         IDZ=1
      ELSE
         IDZ=0
      ENDIF
C
C  FIND THE STEP SIZE.
C
      S=ZERO
      DO 10 I=1,N
         S=S+X(I)**2
   10 CONTINUE
      S=ZSQRT(S)
C
      IF(IDZ.EQ.1) THEN
         DENOM=DMIN
      ELSE
         DENOM=D2
      ENDIF
C
      T2=XM4*ZSQRT(ZABS(FX)/DENOM+S*XLDT)+XM2*XLDT
      S=XM4*S+T
      IF(IDZ.EQ.1 .AND. T2.GT.S) T2=S
      IF(T2.LT.SMALL) T2=SMALL
      IF(T2.GT.HUNDTH*H) T2=HUNDTH*H
C
      IF(IFK.EQ.1 .AND. F1.LE.FM) THEN
         XM=X1
         FM=F1
      ENDIF
C
      IF(IFK.EQ.0 .OR. ZABS(X1).LT.T2) THEN
C
         IF(X1.GE.ZERO) THEN
            X1=T2
         ELSE
            X1=-T2
         ENDIF
C
         CALL FLIN(X1,J,F,F1)
      ENDIF
C
      IF(F1.LT.FM) THEN
         XM=X1
         FM=F1
      ENDIF
C
C  LABEL L0...
C
   20 IF(IDZ.EQ.1) THEN
C
C  EVALUATE FLIN AT ANOTHER POINT,
C  AND ESTIMATE THE SECOND DERIVATIVE.
C
         IF(F0.LT.F1) THEN
            X2=-X1
         ELSE
            X2=TWO*X1
         ENDIF
C
         CALL FLIN(X2,J,F,F2)
C
         IF(F2.LE.FM) THEN
            XM=X2
            FM=F2
         ENDIF
C
         D2=(X2*(F1-F0)-X1*(F2-F0))/(X1*X2*(X1-X2))
C
         IF(JPRINT.GE.5) WRITE(LP,30)X1,X2,F0,F1,F2,D2
   30    FORMAT(/' COMPUTE D2 IN SUBROUTINE MINX.'/
     *      5X,'X1 =',1PG15.7,5X,'X2 =',G15.7/
     *      5X,'F0 =',G15.7,5X,'F1 =',G15.7,5X,'F2 =',G15.7/
     *      5X,'D2 =',G15.7)
      ENDIF
C
C  ESTIMATE THE FIRST DERIVATIVE AT 0.
C
      D1=(F1-F0)/X1-X1*D2
      IDZ=1
C
C  PREDICT THE MINIMUM.
C
      IF(D2.LE.SMALL) THEN
C
         IF(D1.LT.ZERO) THEN
            X2=H
         ELSE
            X2=-H
         ENDIF
C
      ELSE
         X2=-RHALF*D1/D2
      ENDIF
C
      IF(ZABS(X2).GT.H) THEN
C
         IF(X2.GT.ZERO) THEN
            X2=H
         ELSE
            X2=-H
         ENDIF
      ENDIF
C
C  EVALUATE F AT THE PREDICTED MINIMUM.
C  LABEL L1...
C
   40 CALL FLIN(X2,J,F,F2)
C
      IF(K.LT.NITS .AND. F2.GT.F0) THEN
C
C  NO SUCCESS, SO TRY AGAIN.
C
         K=K+1
C
C  IF(...) GO TO L0
C
         IF(F0.LT.F1 .AND. X1*X2.GT.ZERO) GO TO 20
         X2=X2/TWO
C
C  GO TO L1
C
         GO TO 40
C
      ENDIF
C
C  INCREMENT THE ONE-DIMENSIONAL SEARCH COUNTER.
C
      NL=NL+1
C
      IF(F2.GT.FM) THEN
         X2=XM
      ELSE
         FM=F2
      ENDIF
C
C  GET A NEW ESTIMATE OF THE SECOND DERIVATIVE.
C
      IF(ZABS(X2*(X2-X1)).GT.SMALL) THEN
         D2=(X2*(F1-F0)-X1*(FM-F0))/(X1*X2*(X1-X2))
C
         IF(JPRINT.GE.5) WRITE(LP,50)X1,X2,F0,FM,F1,D2
   50    FORMAT(/' RECOMPUTE D2 IN SUBROUTINE MINX.'/
     *      5X,'X1 =',1PG15.7,5X,'X2 =',G15.7/
     *      5X,'F0 =',G15.7,5X,'FM =',G15.7,5X,'F1 =',G15.7/
     *      5X,'D2 =',G15.7)
C
      ELSE IF(K.GT.0) THEN
         D2=ZERO
C
         IF(JPRINT.GE.5) WRITE(LP,60)
   60    FORMAT(/' SET D2=0 IN SUBROUTINE MINX.')
      ELSE
         D2=D2
      ENDIF
C
      IF(D2.LE.SMALL) THEN
         D2=SMALL
C
         IF(JPRINT.GE.5) WRITE(LP,70)D2
   70    FORMAT(/' SET D2=SMALL=',1PG15.7,' IN SUBROUTINE MINX.')
      ENDIF
C
      IF(JPRINT.GE.5) WRITE(LP,80)X1,X2,FX,FM,SF1
   80 FORMAT(/' SUBROUTINE MINX.   X1 =',1PG15.7,5X,'X2 =',G15.7/
     *   5X,'FX =',G15.7,5X,'FM =',G15.7,5X,'SF1 =',G15.7)
C
      X1=X2
      FX=FM
      IF(SF1.LT.FX) THEN
         FX=SF1
         X1=SX1
      ENDIF
C
C  UPDATE X FOR A LINEAR SEARCH BUT NOT FOR A PARABOLIC SEARCH.
C
      IF(J.GT.0) THEN
C
         DO 90 I=1,N
            X(I)=X(I)+X1*V(I,J)
   90    CONTINUE
      ENDIF
C
      IF(JPRINT.GE.5) WRITE(LP,100)D2,X1,F1,FX
  100 FORMAT(/' LEAVE SUBROUTINE MINX.'/
     *   5X,'D2 =',1PG15.7,5X,'X1 =',G15.7,5X,'F1 =',G15.7/
     *   5X,'FX =',G15.7)
C
      RETURN
C
C  END MINX
C
      END
      SUBROUTINE FLIN(XL,J,F,FLN)
C
C  FLIN IS A FUNCTION OF ONE VARIABLE XL WHICH IS MINIMIZED BY
C  SUBROUTINE MINX.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 159-160
C
C  SUBROUTINE FLIN IS CALLED BY SUBROUTINE MINX.
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER J,   I
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION XL,F,FLN,   TT,   QA,QB,QC
C
      DIMENSION TT(128)
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      IF(J.GT.0) THEN
C
C  LINEAR SEARCH...
C
         DO 10 I=1,N
            TT(I)=X(I)+XL*V(I,J)
   10    CONTINUE
C
      ELSE
C
C  SEARCH ALONG A PARABOLIC SPACE CURVE.
C
         QA=XL*(XL-QD1)/(QD0*(QD0+QD1))
         QB=(XL+QD0)*(QD1-XL)/(QD0*QD1)
         QC=XL*(XL+QD0)/(QD1*(QD0+QD1))
C
         DO 20 I=1,N
            TT(I)=QA*Q0(I)+QB*X(I)+QC*Q1(I)
   20    CONTINUE
      ENDIF
C
C  INCREMENT FUNCTION EVALUATION COUNTER.
C
      NF=NF+1
      FLN=F(TT,N)
C
      RETURN
C
C  END FLIN
C
      END
      SUBROUTINE MINFIT(N,EPS,TOL,AB,Q,E,NMAX,LP)
C
C  AN IMPROVED VERSION OF MINFIT, RESTRICTED TO M=N, P=0.
C  SEE GOLUB AND REINSCH (1970).
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 156-158
C
C  G. H. GOLUB AND C. REINSCH,
C  "SINGULAR VALUE DECOMPOSITION AND LEAST SQUARES SOLUTIONS',
C  NUMERISCHE MATHEMATIK 14 (1970) PAGES 403-420
C
C  THE SINGULAR VALUES OF THE ARRAY AB ARE RETURNED IN Q,
C  AND AB IS OVERWRITTEN WITH THE ORTHOGONAL MATRIX V SUCH THAT
C  U.DIAG(Q)=AB.V, WHERE U IS ANOTHER ORTHOGONAL MATRIX.
C
C  SUBROUTINE MINFIT IS CALLED BY SUBROUTINE PRAXIS.
C
      INTEGER N,NMAX,LP,
     *   I,II,J,JTHIRT,K,KK,KT,L,LL2,LPI,L2
C
      DOUBLE PRECISION EPS,TOL,AB,Q,E,
     *   DABS,DSQRT,ZABS,ZSQRT,ARG,
     *   C,DENOM,F,G,H,ONE,X,Y,Z,ZERO,S,TWO
C
      DIMENSION AB(NMAX,N),Q(N),E(N)
C
      ZABS(ARG)=DABS(ARG)
      ZSQRT(ARG)=DSQRT(ARG)
C
      JTHIRT=30
C
      ZERO=0.0D0
      ONE=1.0D0
      TWO=2.0D0
C
C  HOUSEHOLDER'S REDUCTION TO BIDIAGONAL FORM...
C
      X=ZERO
      G=ZERO
C
      DO 140 I=1,N
         E(I)=G
         S=ZERO
         L=I+1
C
         DO 10 J=I,N
            S=S+AB(J,I)**2
   10    CONTINUE
C
         IF(S.LT.TOL) THEN
            G=ZERO
         ELSE
            F=AB(I,I)
C
            IF(F.LT.ZERO) THEN
               G=ZSQRT(S)
            ELSE
               G=-ZSQRT(S)
            ENDIF
C
            H=F*G-S
            AB(I,I)=F-G
C
            IF(L.GT.N) GO TO 60
            DO 50 J=L,N
C
               F=ZERO
               IF(I.GT.N) GO TO 30
               DO 20 K=I,N
                  F=F+AB(K,I)*AB(K,J)
   20          CONTINUE
   30          F=F/H
C
               IF(I.GT.N) GO TO 50
               DO 40 K=I,N
                  AB(K,J)=AB(K,J)+F*AB(K,I)
   40          CONTINUE
   50       CONTINUE
         ENDIF
C
   60    Q(I)=G
         S=ZERO
C
         IF(I.LE.N) THEN
C
            IF(L.GT.N) GO TO 80
            DO 70 J=L,N
               S=S+AB(I,J)**2
   70       CONTINUE
         ENDIF
C
   80    IF(S.LT.TOL) THEN
            G=ZERO
         ELSE
            F=AB(I,I+1)
C
            IF(F.LT.ZERO) THEN
               G=ZSQRT(S)
            ELSE
               G=-ZSQRT(S)
            ENDIF
C
            H=F*G-S
            AB(I,I+1)=F-G
            IF(L.GT.N) GO TO 130
            DO 90 J=L,N
               E(J)=AB(I,J)/H
   90       CONTINUE
C
            DO 120 J=L,N
C
               S=ZERO
               DO 100 K=L,N
                  S=S+AB(J,K)*AB(I,K)
  100          CONTINUE
C
               DO 110 K=L,N
                  AB(J,K)=AB(J,K)+S*E(K)
  110          CONTINUE
  120       CONTINUE
         ENDIF
C
  130    Y=ZABS(Q(I))+ZABS(E(I))
C
         IF(Y.GT.X) X=Y
  140 CONTINUE
C
C  ACCUMULATION OF RIGHT-HAND TRANSFORMATIONS...
C
      DO 210 II=1,N
         I=N-II+1
C
         IF(G.NE.ZERO) THEN
            H=AB(I,I+1)*G
C
            IF(L.GT.N) GO TO 200
            DO 150 J=L,N
               AB(J,I)=AB(I,J)/H
  150       CONTINUE
C
            DO 180 J=L,N
C
               S=ZERO
               DO 160 K=L,N
                  S=S+AB(I,K)*AB(K,J)
  160          CONTINUE
C
               DO 170 K=L,N
                  AB(K,J)=AB(K,J)+S*AB(K,I)
  170          CONTINUE
  180       CONTINUE
         ENDIF
C
         IF(L.GT.N) GO TO 200
         DO 190 J=L,N
            AB(J,I)=ZERO
            AB(I,J)=ZERO
  190    CONTINUE
C
  200    AB(I,I)=ONE
         G=E(I)
         L=I
  210 CONTINUE
C
C  DIAGONALIZATION OF THE BIDIAGONAL FORM...
C
      EPS=EPS*X
      DO 330 KK=1,N
         K=N-KK+1
         KT=0
C
C  LABEL TESTFSPLITTING...
C
  220    KT=KT+1
C
         IF(KT.GT.JTHIRT) THEN
            E(K)=ZERO
            WRITE(LP,230)
  230       FORMAT(' QR FAILED.')
         ENDIF
C
         DO 240 LL2=1,K
            L2=K-LL2+1
            L=L2
C
C  IF(...) GO TO TESTFCONVERGENCE
C
            IF(ZABS(E(L)).LE.EPS) GO TO 270
C
C  IF(...) GO TO CANCELLATION
C
            IF(ZABS(Q(L-1)).LE.EPS) GO TO 250
  240    CONTINUE
C
C  CANCELLATION OF E(L) IF L IS GREATER THAN 1...
C  LABEL CANCELLATION...
C
  250    C=ZERO
         S=ONE
         IF(L.GT.K) GO TO 270
         DO 260 I=L,K
            F=S*E(I)
            E(I)=C*E(I)
C
C  IF(...) GO TO TESTFCONVERGENCE
C
            IF(ZABS(F).LE.EPS) GO TO 270
            G=Q(I)
C
            IF(ZABS(F).LT.ZABS(G)) THEN
               H=ZABS(G)*ZSQRT(ONE+(F/G)**2)
            ELSE IF(F.NE.ZERO) THEN
               H=ZABS(F)*ZSQRT(ONE+(G/F)**2)
            ELSE
               H=ZERO
            ENDIF
C
            Q(I)=H
C
            IF(H.EQ.ZERO) THEN
               H=ONE
               G=ONE
            ENDIF
C
C  THE ABOVE REPLACES Q(I) AND H BY SQUARE ROOT OF (G*G+F*F)
C  WHICH MAY GIVE INCORRECT RESULTS IF THE SQUARES UNDERFLOW OR IF
C  F = G = 0 .
C
            C=G/H
            S=-F/H
  260    CONTINUE
C
C  LABEL TESTFCONVERGENCE...
C
  270    Z=Q(K)
C
C  IF(...) GO TO CONVERGENCE
C
         IF(L.EQ.K) GO TO 310
C
C  SHIFT FROM BOTTOM 2*2 MINOR.
C
         X=Q(L)
         Y=Q(K-1)
         G=E(K-1)
         H=E(K)
         F=((Y-Z)*(Y+Z)+(G-H)*(G+H))/(TWO*H*Y)
         G=ZSQRT(F*F+ONE)
C
         IF(F.LT.ZERO) THEN
            DENOM=F-G
         ELSE
            DENOM=F+G
         ENDIF
C
         F=((X-Z)*(X+Z)+H*(Y/DENOM-H))/X
C
C  NEXT QR TRANSFORMATION...
C
         S=ONE
         C=ONE
         LPI=L+1
         IF(LPI.GT.K) GO TO 300
         DO 290 I=LPI,K
            G=E(I)
            Y=Q(I)
            H=S*G
            G=G*C
C
            IF(ZABS(F).LT.ZABS(H)) THEN
               Z=ZABS(H)*ZSQRT(ONE+(F/H)**2)
            ELSE IF(F.NE.ZERO) THEN
               Z=ZABS(F)*ZSQRT(ONE+(H/F)**2)
            ELSE
               Z=ZERO
            ENDIF
C
            E(I-1)=Z
C
            IF(Z.EQ.ZERO) THEN
               F=ONE
               Z=ONE
            ENDIF
C
            C=F/Z
            S=H/Z
            F=X*C+G*S
            G=-X*S+G*C
            H=Y*S
            Y=Y*C
C
            DO 280 J=1,N
               X=AB(J,I-1)
               Z=AB(J,I)
               AB(J,I-1)=X*C+Z*S
               AB(J,I)=-X*S+Z*C
  280       CONTINUE
C
            IF(ZABS(F).LT.ZABS(H)) THEN
               Z=ZABS(H)*ZSQRT(ONE+(F/H)**2)
            ELSE IF(F.NE.ZERO) THEN
               Z=ZABS(F)*ZSQRT(ONE+(H/F)**2)
            ELSE
               Z=ZERO
            ENDIF
C
            Q(I-1)=Z
C
            IF(Z.EQ.ZERO) THEN
               F=ONE
               Z=ONE
            ENDIF
C
            C=F/Z
            S=H/Z
            F=C*G+S*Y
            X=-S*G+C*Y
  290    CONTINUE
C
  300    E(L)=ZERO
         E(K)=F
         Q(K)=X
C
C  GO TO TESTFSPLITTING
C
         GO TO 220
C
C  LABEL CONVERGENCE...
C
  310    IF(Z.LT.ZERO) THEN
C
C  Q(K) IS MADE NON-NEGATIVE.
C
            Q(K)=-Z
            DO 320 J=1,N
               AB(J,K)=-AB(J,K)
  320       CONTINUE
         ENDIF
  330 CONTINUE
C
      RETURN
C
C  END MINFIT
C
      END
      SUBROUTINE SORT
C
C  THIS SUBROUTINE SORTS THE ELEMENTS OF D
C  AND THE CORRESPONDING COLUMNS OF V INTO DESCENDING ORDER.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 158-159
C
      INTEGER N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
      INTEGER I,IPI,J,K,NMI
C
      DOUBLE PRECISION V,X,D,Q0,Q1,DMIN,EPSMCH,FX,H,QD0,QD1,QF1,
     *   SMALL,T,XLDT,XM2,XM4,DSEED,SCBD
      DOUBLE PRECISION S
C
      COMMON /CPRAX/ V(128,128),X(128),D(128),Q0(128),Q1(128),
     *   DMIN,EPSMCH,FX,H,QD0,QD1,QF1,SMALL,T,XLDT,XM2,XM4,DSEED,SCBD,
     *   N,NL,NF,LP,JPRINT,NMAX,ILLCIN,KTM,NFMAX,JRANCH
C
      NMI=N-1
      IF(NMI.LT.1) GO TO 50
      DO 40 I=1,NMI
         K=I
         S=D(I)
         IPI=I+1
         IF(IPI.GT.N) GO TO 20
C
         DO 10 J=IPI,N
C
            IF(D(J).GT.S) THEN
               K=J
               S=D(J)
            ENDIF
   10    CONTINUE
C
   20    IF(K.GT.I) THEN
            D(K)=D(I)
            D(I)=S
C
            DO 30 J=1,N
               S=V(J,I)
               V(J,I)=V(J,K)
               V(J,K)=S
   30       CONTINUE
         ENDIF
   40 CONTINUE
C
   50 RETURN
C
C  END SORT
C
      END
      SUBROUTINE RANINI(RVALUE)
C
C  SUBROUTINE RANINI PERFORMS INITIALIZATION FOR SUBROUTINE RANDOM.
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 163-164
C
      INTEGER JRAN2,I
C
      DOUBLE PRECISION RVALUE,R,RAN3,DMOD,DABS,RAN1
C
      COMMON /COMRAN/ RAN3(127),RAN1,JRAN2
C
      R=DMOD(DABS(RVALUE),8190.0D0)+1
      JRAN2=127
C
   10 IF(JRAN2.GT.0) THEN
         JRAN2=JRAN2-1
         RAN1=-2.0D0**55
C
         DO 20 I=1,7
            R=DMOD(1756.0D0*R,8191.0D0)
            RAN1=(RAN1+(R-DMOD(R,32.0D0))/32.0D0)/256.0D0
   20    CONTINUE
C
         RAN3(JRAN2+1)=RAN1
         GO TO 10
      ENDIF
C
      RETURN
C
C  END RANINI
C
      END
      SUBROUTINE RANDOM(RANVAL)
C
C  SUBROUTINE RANDOM RETURNS A DOUBLE PRECISION PSEUDORANDOM NUMBER
C  UNIFORMLY DISTRIBUTED IN (0,1) (INCLUDING 0 BUT NOT 1).
C
C  "ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES",
C  RICHARD P. BRENT, PRENTICE-HALL 1973, PAGES 163-164
C
C  BEFORE THE FIRST CALL TO RANDOM, THE USER MUST
C  CALL RANINI(R) ONCE (ONLY) WITH R A DOUBLE PRECISION NUMBER
C  EQUAL TO ANY INTEGER VALUE.
C  BRENT (PAGE 166) USED THE EQUIVALENT OF
C     CALL RANINI(4.0D0) .
C
C  THE ALGORITHM USED IN SUBROUTINE RANDOM RETURNS X(N)/2**56,
C  WHERE   X(N) = X(N-1) + X(N-127)  (MOD 2**56) .
C  SINCE (1 + X + X**127) IS PRIMITIVE (MOD 2),
C  THE PERIOD IS AT LEAST (2**127 - 1), WHICH EXCEEDS 10**38.
C
C  SEE "SEMINUMERICAL ALGORITHMS", VOLUME 2 OF
C  "THE ART OF COMPUTER PROGRAMMING" BY DONALD E. KNUTH,
C  ADDISON-WESLEY 1969, PAGES 26, 34, AND 464.
C
C  X(N) IS STORED IN DOUBLE PRECISION AS  RAN3 = X(N)/2**56 - 1/2,
C  AND ALL DOUBLE PRECISION ARITHMETIC IS EXACT.
C
      INTEGER JRAN2
C
      DOUBLE PRECISION RANVAL,RAN3,RAN1
C
      COMMON /COMRAN/ RAN3(127),RAN1,JRAN2
C
      IF(JRAN2.EQ.0) THEN
         JRAN2=126
      ELSE
         JRAN2=JRAN2-1
      ENDIF
C
      RAN1=RAN1+RAN3(JRAN2+1)
      IF(RAN1.LT.0.0D0) THEN
         RAN1=RAN1+0.5D0
      ELSE
         RAN1=RAN1-0.5D0
      ENDIF
C
      RAN3(JRAN2+1)=RAN1
      RANVAL=RAN1+0.5D0
C
      RETURN
C
C  END RANDOM
C
      END
      DOUBLE PRECISION FUNCTION DRANDM(DL)
C
C  SIMPLE PORTABLE PSEUDORANDOM NUMBER GENERATOR.
C
C  DRANDM RETURNS FUNCTION VALUES THAT ARE PSEUDORANDOM
C  NUMBERS UNIFORMLY DISTRIBUTED ON THE INTERVAL (0,1).
C
C  'NUMERICAL MATHEMATICS AND COMPUTING' BY WARD CHENEY AND
C  DAVID KINCAID, BROOKS/COLE PUBLISHING COMPANY
C  (FIRST EDITION, 1980), PAGE 203
C
C  AT THE BEGINNING OF EXECUTION, OR WHENEVER A NEW SEQUENCE IS
C  TO BE INITIATED, SET DL EQUAL TO AN INTEGER VALUE BETWEEN
C  1.0D0 AND 2147483646.0D0, INCLUSIVE.  DO THIS ONLY ONCE.
C  THEREAFTER, DO NOT SET OR ALTER DL IN ANY WAY.
C  FUNCTION DRANDM WILL MODIFY DL FOR ITS OWN PURPOSES.
C
C  DRANDM USES A MULTIPLICATIVE CONGRUENTIAL METHOD.
C  THE NUMBERS GENERATED BY DRANDM SUFFER FROM THE PARALLEL
C  PLANES DEFECT DISCOVERED BY G. MARSAGLIA, AND SHOULD NOT BE
C  USED WHEN HIGH-QUALITY RANDOMNESS IS REQUIRED.  IN THAT
C  CASE, USE A "SHUFFLING" METHOD.
C
      DOUBLE PRECISION DL,DMOD
C
   10 DL=DMOD(16807.0D0*DL,2147483647.0D0)
      DRANDM=DL/2147483647.0D0
      IF(DRANDM.LE.0.0D0 .OR. DRANDM.GE.1.0D0) GO TO 10
      RETURN
      END
