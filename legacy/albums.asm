***********************************************************************
* ALBUM MONTH COUNTER - IBM SYSTEM/360 ASSEMBLER                     *
* Counts albums released in each month from ALBUMS.DAT file          *
* Converted from COBOL legacy code                                   *
***********************************************************************
ALBCOUNT CSECT
         STM   R14,R12,12(R13)    SAVE REGISTERS
         LR    R12,R15            LOAD BASE REGISTER
         USING ALBCOUNT,R12       ESTABLISH ADDRESSABILITY
         LA    R11,SAVEAREA       LOAD ADDRESS OF SAVE AREA
         ST    R13,4(R11)         CHAIN SAVE AREAS
         ST    R11,8(R13)
         LR    R13,R11            NEW SAVE AREA
*
* INITIALIZE MONTH COUNTERS TO ZERO
*
         LA    R3,12              LOAD COUNTER FOR 12 MONTHS
         LA    R4,MONTHTBL        POINT TO MONTH COUNTER TABLE
INITLOOP ST    R0,0(R4)           STORE ZERO
         LA    R4,4(R4)           NEXT COUNTER
         BCT   R3,INITLOOP        LOOP UNTIL DONE
*
* OPEN THE ALBUM DATA FILE
*
         OPEN  (ALBUMFIL,(INPUT)) OPEN INPUT FILE
         LTR   R15,R15            CHECK RETURN CODE
         BNZ   OPENERR            BRANCH IF ERROR
*
* MAIN PROCESSING LOOP - READ AND COUNT ALBUMS
*
READLOOP GET   ALBUMFIL,ALBUMREC  READ A RECORD
         BAL   R14,PROCRECRD      PROCESS THE RECORD
         B     READLOOP           CONTINUE READING
*
ENDFILE  CLOSE ALBUMFIL           CLOSE THE FILE
*
* DISPLAY THE RESULTS
*
         BAL   R14,DISPRSLT       DISPLAY RESULTS
*
* RETURN TO CALLER
*
         L     R13,4(R13)         RESTORE SAVE AREA
         LM    R14,R12,12(R13)    RESTORE REGISTERS
         SR    R15,R15            SET RETURN CODE 0
         BR    R14                RETURN
*
***********************************************************************
* PROCESS RECORD - INCREMENT COUNTER FOR RELEASE MONTH              *
***********************************************************************
PROCRECRD DS   0H
         ST    R14,PROCSAVE       SAVE RETURN ADDRESS
*
* EXTRACT MONTH FROM POSITIONS 39-40 (0-BASED: 39-40)
*
         LA    R5,ALBUMREC        POINT TO RECORD
         LA    R5,39(R5)          POINT TO MONTH FIELD
         MVC   MONTHFLD(2),0(R5)  MOVE MONTH TO WORK AREA
*
* CONVERT PACKED DECIMAL MONTH TO BINARY
*
         PACK  PKMONTH,MONTHFLD   PACK THE MONTH
         CVB   R6,PKMONTH         CONVERT TO BINARY
*
* VALIDATE MONTH (1-12)
*
         C     R6,=F'1'           CHECK IF >= 1
         BL    PROCRET            IF LESS, SKIP
         C     R6,=F'12'          CHECK IF <= 12
         BH    PROCRET            IF GREATER, SKIP
*
* INCREMENT COUNTER FOR THIS MONTH
*
         BCTR  R6,0               ADJUST TO 0-BASED INDEX
         SLL   R6,2               MULTIPLY BY 4 (WORD SIZE)
         LA    R4,MONTHTBL        POINT TO COUNTER TABLE
         AR    R4,R6              ADD OFFSET
         L     R7,0(R4)           LOAD CURRENT COUNT
         LA    R7,1(R7)           INCREMENT
         ST    R7,0(R4)           STORE BACK
*
PROCRET  L     R14,PROCSAVE       RESTORE RETURN ADDRESS
         BR    R14                RETURN
*
***********************************************************************
* DISPLAY RESULTS - PRINT MONTH NAMES AND COUNTS                    *
***********************************************************************
DISPRSLT DS   0H
         ST    R14,DISPSAVE       SAVE RETURN ADDRESS
*
* PRINT HEADING
*
         PUT   OUTFILE,HEADING    PRINT HEADING LINE
*
* LOOP THROUGH 12 MONTHS
*
         LA    R8,1               START WITH MONTH 1
         LA    R9,MONTHTBL        POINT TO COUNTER TABLE
         LA    R10,MNAMES         POINT TO MONTH NAMES
*
DISPLOOP DS   0H
         MVC   OUTLINE(9),0(R10)  MOVE MONTH NAME TO OUTPUT
         L     R7,0(R9)           LOAD COUNTER
         CVD   R7,PKCOUNT         CONVERT TO DECIMAL
         UNPK  OUTLINE+12(4),PKCOUNT+6(2) UNPACK COUNT
         OI    OUTLINE+15,X'F0'   FIX SIGN
         PUT   OUTFILE,OUTLINE    PRINT LINE
*
         LA    R10,9(R10)         NEXT MONTH NAME
         LA    R9,4(R9)           NEXT COUNTER
         LA    R8,1(R8)           INCREMENT MONTH
         C     R8,=F'12'          CHECK IF DONE
         BNH   DISPLOOP           CONTINUE IF NOT
*
         L     R14,DISPSAVE       RESTORE RETURN ADDRESS
         BR    R14                RETURN
*
***********************************************************************
* ERROR HANDLING                                                     *
***********************************************************************
OPENERR  WTO   'ERROR: CANNOT OPEN ALBUMS.DAT',ROUTCDE=11
         LA    R15,8              SET RETURN CODE 8
         B     EXIT               EXIT
*
***********************************************************************
* DATA AREAS                                                         *
***********************************************************************
SAVEAREA DS    18F                REGISTER SAVE AREA
PROCSAVE DS    F                  SUBROUTINE SAVE
DISPSAVE DS    F                  SUBROUTINE SAVE
*
* ALBUM FILE DCB
*
ALBUMFIL DCB   DSORG=PS,MACRF=GM,RECFM=FB,LRECL=80,               X
               DDNAME=ALBUMIN,EODAD=ENDFILE
*
* OUTPUT FILE DCB (SYSOUT)
*
OUTFILE  DCB   DSORG=PS,MACRF=PM,RECFM=FBA,LRECL=133,             X
               DDNAME=SYSOUT,BLKSIZE=133
*
* RECORD BUFFERS
*
ALBUMREC DS    CL80               INPUT RECORD BUFFER
OUTLINE  DS    CL133              OUTPUT LINE
HEADING  DC    CL133' Month       AlbumCount'
*
* WORKING STORAGE
*
MONTHTBL DS    12F                TABLE OF 12 MONTH COUNTERS
MONTHFLD DS    CL2                MONTH FIELD WORK AREA
PKMONTH  DS    D                  PACKED MONTH
PKCOUNT  DS    D                  PACKED COUNT
*
* MONTH NAMES TABLE
*
MNAMES   DS    0CL108
         DC    CL9'January  '
         DC    CL9'February '
         DC    CL9'March    '
         DC    CL9'April    '
         DC    CL9'May      '
         DC    CL9'June     '
         DC    CL9'July     '
         DC    CL9'August   '
         DC    CL9'September'
         DC    CL9'October  '
         DC    CL9'November '
         DC    CL9'December '
*
EXIT     L     R13,4(R13)         RESTORE SAVE AREA
         LM    R14,R12,12(R13)    RESTORE REGISTERS
         BR    R14                RETURN
*
         END   ALBCOUNT
