### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    LUNAR_LANDING_GUIDANCE_EQUATIONS.agc
## Purpose:     A section of Luminary revision 116.
##              It is part of the source code for the Lunar Module's (LM) 
##              Apollo Guidance Computer (AGC) for Apollo 12.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 791-822
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2017-01-22 MAS  Created from Luminary 99.

## NOTE: Page numbers below have not yet been updated to reflect Luminary 116.

## Page 798
                EBANK=          E2DPS                           
                COUNT*          $$/F2DPS                        

# ****************************************************************************************************************
# LUNAR LANDING FLIGHT SEQUENCE TABLES
# ****************************************************************************************************************

# FLIGHT SEQUENCE TABLES ARE ARRANGED BY FUNCTION.   THEY ARE REFERENCED USING AS AN INDEX THE REGISTER WCHPHASE:
#       WCHPHASE = -1 ---> IGNALG
#       WCHPHASE =  0 ---> BRAKQUAD
#       WCHPHASE =  1 ---> APPRQUAD
#       WCHPHASE =  2 ---> VERTICAL

#****************************************************************************************************************

# ROUTINES FOR STARTING NEW GUIDANCE PHASES:

                TCF             TTFINCR                         # IGNALG
NEWPHASE        TCF             TTFINCR                         # BRAKQUAD
                TCF             STARTP64                        # APPRQUAD
                TCF             P65START                        # VERTICAL

# PRE-GUIDANCE COMPUTATIONS:

                TCF             CALCRGVG                        # IGNALG
PREGUIDE        TCF             RGVGCALC                        # BRAKQUAD
                TCF             REDESIG                         # APPRQUAD
                TCF             RGVGCALC                        # VERTICAL

# GUIDANCE EQUATIONS:

                TCF             TTF/8CL                         # IGNALG
WHATGUID        TCF             TTF/8CL                         # BRAKQUAD
                TCF             TTF/8CL                         # APPRQUAD
                TCF             VERTGUID                        # VERTICAL

# POST GUIDANCE EQUATION COMPUTATIONS:

                TCF             CGCALC                          # IGNALG
AFTRGUID        TCF             CGCALC                          # BRAKQUAD
                TCF             CGCALC                          # APPRQUAD
                TCF             STEER?                          # VERTICAL

## Page 799
# WINDOW VECTOR COMPUTATIONS:

                TCF             EXGSUB                          # IGNALG
WHATEXIT        TCF             EXBRAK                          # BRAKQUAD
                TCF             EXNORM                          # APPRQUAD

# DISPLAY ROUTINES:

WHATDISP        TCF             P63DISPS                        # BRAKQUAD
                TCF             P64DISPS                        # APPRQUAD
                TCF             VERTDISP                        # VERTICAL

# ALARM ROUTINE FOR TTF COMPUTATION:

                TCF             1406P00                         # IGNALG
WHATALM         TCF             1406ALM                         # BRAKQUAD
                TCF             1406ALM                         # APPRQUAD

# INDICES FOR REFERENCING TARGET PARAMETERS:

                OCT             0                               # IGNALG
TARGTDEX        OCT             0                               # BRAKQUAD
                OCT             34                              # APPRQUAD

#****************************************************************************************************************
# ENTRY POINTS:  ?GUIDSUB FOR THE IGNITION ALGORITHM, LUNLAND FOR SERVOUT
#****************************************************************************************************************

# IGNITION ALGORITHM ENTRY:  DELIVERS N PASSES OF QUADRATIC GUIDANCE

?GUIDSUB        EXIT                                            
                CAF             TWO                             # N = 3
                TS              NGUIDSUB                        
                TCF             GUILDRET        +2              

GUIDSUB         TS              NGUIDSUB                        # ON SUCEEDING PASSES SKIP TTFINCR
                TCF             CALCRGVG                        

# NORMAL ENTRY:  CONTROL COMES HERE FROM SERVOUT

LUNLAND         TC              PHASCHNG                        
                OCT             00035                           # GROUP 5:  RETAIN ONLY PIPA TASK
                TC              PHASCHNG                        
                OCT             05023                           # GROUP 3:  PROTECT GUIDANCE WITH PRIO 21  
                OCT             21000                           #       JUST HIGHER THAN SERVICER'S PRIORITY

## Page 800
#****************************************************************************************************************
# GUILDENSTERN:  AUTO-MODES MONITOR (R13)
#****************************************************************************************************************

                COUNT*          $$/R13                          

# HERE IS THE PHILOSOPHY OF GUILDENSTERN:       ON EVERY APPEARANCE OR DISAPPEARANCE OF THE MANUAL THROTTLE
# DISCRETE TO SELECT P67 OR P66 RESPECTIVELY:   ON EVERY APPEARANCE OF THE ATTITUDE-HOLD DISCRETE TO SELECT P66
# UNLESS THE CURRENT PROGRAM IS P67 IN WHICH CASE THERE IS NO CHANGE.

GUILDEN         EXTEND                                          # IS UN-AUTO-THROTTLE DISCRETE PRESENT?
                READ            CHAN30                          
                MASK            BIT5                            
                CCS             A                               
                TCF             STARTP67                        # YES
P67NOW?         TC              CHECKMM                         # NO:  ARE WE IN P67 NOW?
                DEC             67                              
                TCF             STABL?                          # NO
STARTP66        TC              FASTCHNG                        # YES
                TC              NEWMODEX                        
DEC66           DEC             66                              
                EXTEND                                          
                DCA             HDOTDISP                        # SET DESIRED ALTITUDE RATE = CURRENT
                DXCH            VDGVERT                         #       ALTITUDE RATE.
STRTP66A        TC              INTPRET                         
                SLOAD           PUSH                            
                                PBIASZ                          
                SLOAD           PUSH                            
                                PBIASY                          
                SLOAD           VDEF                            
                                PBIASX                          
                VXSC            SET                             
                                BIASFACT                        
                                RODFLAG                         
                STOVL           VBIAS                           
                                TEMX                            
                VCOMP                                           
                STOVL           OLDPIPAX                        
                                ZEROVECS                        
                STODL           DELVROD                         
                                RODSCALE                        
                STODL           RODSCAL1                        
                                PIPTIME                         
                STORE           LASTTPIP                        
                EXIT                                            
                CAF             ZERO                            
                TS              FCOLD                           
                TS              FWEIGHT                         
                TS              FWEIGHT         +1              
VRTSTART        TS              WCHVERT                         
## Page 801
                CAF             TWO                             # WCHPHASE = 2 ---> VERTICAL: P65,P66,P67
                TS              WCHPHOLD                        
                TS              WCHPHASE                        
                TC              BANKCALL                        # TEMPORARY, I HOPE HOPE HOPE
                CADR            STOPRATE                        # TEMPORARY, I HOPE HOPE HOPE
                TC              DOWNFLAG                        # PERMIT X-AXIS OVERRIDE
                ADRES           XOVINFLG                        
                TC              DOWNFLAG                        
                ADRES           REDFLAG                         
                TCF             VERTGUID                        

STARTP67        TC              NEWMODEX                        # NO HARM IN "STARTING" P67 OVER AND OVER
                DEC             67                              # SO NO NEED FOR A FASTCHNG AND NO NEED
                CAF             ZERO                            # TO SEE IF ALREADY IN P67.
                TS              RODCOUNT                        
                CAF             TEN                             
                TCF             VRTSTART                        

STABL?          CAF             BIT13                           # IS UN-ATTITUDE-HOLD DISCRETE PRESENT?
                EXTEND                                          
                RAND            CHAN31                          
                CCS             A                               
                TCF             GUILDRET                        # YES: ALL'S WELL

P66NOW?         CS              MODREG                          
                AD              DEC66                           
                EXTEND                                          
                BZF             RESTART?                        

                CA              RODCOUNT                        # NO. HAS THE ROD SWITCH BEEN "CLICKED"?
                EXTEND                                          
                BZF             GUILDRET                        # NO. CONTINUE WITH AUTOMATIC LANDING.
                TCF             STARTP66                        # YES. SWITCH INTO THE ROD MODE.

RESTART?        CA              FLAGWRD1                        # HAS THERE BEEN A RESTART?
                MASK            RODFLBIT                        
                EXTEND                                          
                BZF             STRTP66A                        # YES.  REINITIALIZE BUT LEAVE VDGVERT AS
                                                                #       IS.

                TCF             VERTGUID                        # NO: CONTINUE WITH R.O.D.

# ****************************************************************************************************************
# INITIALIZATION FOR THIS PASS
# ****************************************************************************************************************

                COUNT*          $$/F2DPS                        

GUILDRET        CAF             ZERO                            
                TS              RODCOUNT                        

## Page 802
 +2             EXTEND                                          
                DCA             TPIP                            
                DXCH            TPIPOLD                         

                TC              FASTCHNG                        

                EXTEND                                          
                DCA             PIPTIME1                        
                DXCH            TPIP                            

                EXTEND                                          
                DCA             TTF/8                           
                DXCH            TTF/8TMP                        

                CCS             FLPASS0                         
                TCF             TTFINCR                         

BRSPOT1         INDEX           WCHPHASE                        
                TCF             NEWPHASE                        

# ****************************************************************************************************************
# ROUTINES TO START NEW PHASES
# ****************************************************************************************************************

P65START        TC              NEWMODEX                        
                DEC             65                              
                CS              TWO                             
                TS              WCHVERT                         
                TC              DOWNFLAG                        # PERMIT X-AXIS OVERRIDE
                ADRES           XOVINFLG                        
                TCF             TTFINCR                         

STARTP64        TC              NEWMODEX                        
                DEC             64                              
                CA              DELTTFAP                        # AUGMENT TTF/8
                ADS             TTF/8TMP                        
                CA              BIT12                           # ENABLE RUPT10
                EXTEND                                          
                WOR             CHAN13                          
                TC              DOWNFLAG                        # INITIALIZE REDESIGNATION FLAG
                ADRES           REDFLAG                         


#               (CONTINUE TO TTFINCR)

# ****************************************************************************************************************
# INCREMENT TTF/8, UPDATE LAND FOR LUNAR ROTATION, DO OTHER USEFUL THINGS
# ****************************************************************************************************************

#       TTFINCR COMPUTATIONS ARE AS FOLLOWS:-
## Page 803
#               TTF/8 UPDATED FOR TIME SINCE LAST PASS:
#                       TTF/8 = TTF/8 + (TPIP - TPIPOLD)/8
#               LANDING SITE VECTOR UPDATED FOR LUNAR ROTATION:
#                       -       -          -                             -
#                       LAND = /LAND/ UNIT(LAND - LAND(TPIP - TPIPOLD) * WM)
#               SLANT RANGE TO LANDING SITE, FOR DISPLAY:
#                                        -      -
#                       RANGEDSP = ABVAL(LAND - R)

TTFINCR         TC              INTPRET                         
                DLOAD           DSU                             
                                TPIP                            
                                TPIPOLD                         
                SLR             PUSH                            # SHIFT SCALES DELTA TIME TO 2(17) CSECS
                                11D                             
                VXSC            VXV                             
                                LAND                            
                                WM                              
                BVSU            RTB                             
                                LAND                            
                                NORMUNIT                        
                VXSC            VSL1                            
                                /LAND/                          
                STODL           LANDTEMP                        
                EXIT                                            

                DXCH            MPAC                            
                DAS             TTF/8TMP                        # NOW HAVE INCREMENTED TTF/8 IN TTF/8TMP

                TC              FASTCHNG                        

                EXTEND                                          
                DCA             TTF/8TMP                        
                DXCH            TTF/8                           

                EXTEND                                          
                DCA             LANDTEMP                        
                DXCH            LAND                            
                EXTEND                                          
                DCA             LANDTEMP        +2              
                DXCH            LAND            +2              
                EXTEND                                          
                DCA             LANDTEMP        +4              
                DXCH            LAND            +4              

## Page 804
                TC              TDISPSET                        
                TC              FASTCHNG                        # SINCE REDESIG MAY CHANGE LANDTEMP

BRSPOT2         INDEX           WCHPHASE                        
                TCF             PREGUIDE                        

# ****************************************************************************************************************
# LANDING SITE PERTURBATION EQUATIONS
# ****************************************************************************************************************

REDESIG         CA              FLAGWRD6                        # IS REDFLAG SET?
                MASK            REDFLBIT                        
                EXTEND                                          
                BZF             RGVGCALC                        # NO:  SKIP REDESIGNATION LOGIC

                CA              TREDES                          # YES:  HAS TREDES REACHED ZERO?
                EXTEND                                          
                BZF             RGVGCALC                        # YES:  SKIP REDESIGNATION LOGIC

                INHINT                                          
                CA              ELINCR1                         
                TS              ELINCR                          
                CA              AZINCR1                         
                TS              AZINCR                          
                TC              FASTCHNG                        

                CA              ZERO                            
                TS              ELINCR1                         
                TS              AZINCR1                         
                TS              ELINCR          +1              
                TS              AZINCR          +1              

                CA              FIXLOC                          # SET PD TO 0
                TS              PUSHLOC                         

                TC              INTPRET                         
                VLOAD           VSU                             
                                LAND                            
                                R                               #                 -      -
                RTB             PUSH                            # PUSH DOWN UNIT (LAND - R)
                                NORMUNIT                        
                VXV             VSL1                            
                                YNBPIP                          #                    -          -      -
                VXSC            PDDL                            # PUSH DOWN - ELINCR(YNB * UNIT(LAND - R))
                                ELINCR                          
                                AZINCR                          
                VXSC            VSU                             
                                YNBPIP                          
                VAD             PUSH                            # RESULTING VECTOR IS 1/2 REAL SIZE

## Page 805

                DLOAD           DSU                             # MAKE SURE REDESIGNATION IS NOT
                                0                               #       TOO CLOSE TO THE HORIZON
                                DEPRCRIT                        
                BMN             DLOAD                           
                                REDES1                          
                                DEPRCRIT                        
                STORE           0                               
REDES1          DLOAD           DSU                             
                                LAND                            
                                R                               
                DDV             VXSC                            
                                0                               
                VAD             UNIT                            
                                R                               
                VXSC            VSL1                            
                                /LAND/                          
                STORE           LANDTEMP                        
                EXIT                                            # LOOKANGL WILL BE COMPUTED AT RGVGCALC

                TC              FASTCHNG                        

                EXTEND                                          
                DCA             LANDTEMP                        
                DXCH            LAND                            
                EXTEND                                          
                DCA             LANDTEMP        +2              
                DXCH            LAND            +2              
                EXTEND                                          
                DCA             LANDTEMP        +4              
                DXCH            LAND            +4              

                TCF             RGVGCALC                        

# ****************************************************************************************************************
# COMPUTE STATE IN GUIDANCE COORDINATES
# ****************************************************************************************************************

#       RGVGCALC COMPUTATIONS ARE AS FOLLOWS:-
#       VELOCITY RELATIVE TO THE SURFACE:
#               -         -   -   -
#               ANGTERM = V + R * WM

#       STATE IN GUIDANCE COORDINATES:
#               -     *   -   -
#               RGU = CG (R - LAND)
#               -     *   -   -    -
## Page 806
#               VGU = CG (V - WM * R)

#       HORIZONTAL VELOCITY FOR DISPLAY:

#               VHORIZ = 8 ABVAL (0, VG , VG )
#                                      2    1
#       DEPRESSION ANGLE FOR DISPLAY:
#                                      -   -     -
#               LOOKANGL = ARCSIN(UNIT(R - LAND).XMBPIP)

CALCRGVG        TC              INTPRET                         # IN IGNALG, COMPUTE V FROM INTEGRATION
                VLOAD           MXV                             #       OUTPUT AND TRIM CORRECTION TERM
                                VATT1                           #       COMPUTED LAST PASS AND LEFT IN UNFC/2
                                REFSMMAT                        
                VSR1            VAD                             
                                UNFC/2                          
                STORE           V                               
                EXIT                                            

RGVGCALC        TC              INTPRET                         # ENTER HERE TO RECOMPUTE RG AND VG
                VLOAD           VXV                             
                                R                               
                                WM                              
                VAD             VSR2                            # RESCALE TO UNITS OF 2(9) M/CS
                                V                               
                STORE           ANGTERM                         
                MXV                                             
                                CG                              # NO SHIFT SINCE ANGTERM IS DOUBLE SIZED
                STORE           VGU                             
                PDDL            VDEF                            # FORM (0,VG ,VG ) IN UNITS OF 2(10) M/CS
                                ZEROVECS                        #           2   1
                ABVAL           SL3                             
                STOVL           VHORIZ                          # VHORIZ FOR DISPLAY DURING P65.
                                R                               #           -   -
                VSU             PUSH                            # PUSH DOWN R - LAND
                                LAND                            
                MXV             VSL1                            
                                CG                              
                STORE           RGU                             
                ABVAL                                           
                STOVL           RANGEDSP                        
                RTB             DOT                             # NOW IN MPAC IS SINE(LOOKANGL)/4
                                NORMUNIT                        
                                XNBPIP                          
                EXIT                                            

                CA              FIXLOC                          # RESET PUSH DOWN POINTER
                TS              PUSHLOC                         

## Page 807 
                CA              MPAC                            # COMPUTE LOOKANGL ITSELF
                DOUBLE                                          
                TC              BANKCALL                        
                CADR            SPARCSIN        -1              
                AD              1/2DEG                          
                EXTEND                                          
                MP              180DEGS                         
                TS              LOOKANGL                        # LOOKANGL FOR DISPLAY DURING P64

BRSPOT3         INDEX           WCHPHASE                        
                TCF             WHATGUID                        

# ****************************************************************************************************************
# TTF/8 COMPUTATION
# ****************************************************************************************************************

TTF/8CL         TC              INTPRETX                        
                DLOAD*                                          
                                JDG2TTF,1                       
                STODL*          TABLTTF         +6              # A(3) = 8 JDG  TO TABLTTF
                                ADG2TTF,1                       #             2
                STODL           TABLTTF         +4              # A(2) = 6 ADG  TO TABLTTF
                                VGU             +4              #             2
                DMP             DAD*                            
                                3/4DP                           
                                VDG2TTF,1                       
                STODL*          TABLTTF         +2              # A(1) = (6 VGU  + 18 VDG )/8 TO TABLTTF
                                RDG             +4,1            #              2         2
                DSU             DMP                             
                                RGU             +4              
                                3/8DP                           
                STORE           TABLTTF                         # A(0) = -24 (RGU  - RDG )/64 TO TABLTTF
                EXIT                                            #                2      2

                CA              BIT8                            
                TS              TABLTTF         +10             # FRACTIONAL PRECISION FOR TTF TO TABLE

                EXTEND                                          
                DCA             TTF/8                           
                DXCH            MPAC                            # LOADS TTF/8 (INITIAL GUESS) INTO MPAC
                CAF             TWO                             # DEGREE - ONE
                TS              L                               
                CAF             TABLTTFL                        
                TC              ROOTPSRS                        # YIELDS TTF/8 IN MPAC
                INDEX           WCHPHASE                        
                TCF             WHATALM                         

                EXTEND                                          # GOOD RETURN
                DCA             MPAC                            # FETCH TTF/8 KEEPING IT IN MPAC
                DXCH            TTF/8                           # CORRECTED TTF/8

## Page 808
                TC              TDISPSET                        

#               (CONTINUE TO QUADGUID)

# ***************************************************************************************************************
# MAIN GUIDANCE EQUATION
# ***************************************************************************************************************

#       AS PUBLISHED:-
#                             -     -        -     -
#               -     -     6(VDG + VG)   12(RDG - RG)
#               ACG = ADG + ----------- + ------------
#                               TTF        (TTF)(TTF)
#       AS HERE PROGRAMMED:-
#                            -     -
#                     3 (1/4(RDG - RG)   -     - )
#                     - (------------- + VDG + VG)
#               -     4 (    TTF/8               )   -
#               ACG = ---------------------------- + ADG
#                                 TTF/8

QUADGUID        CS              TTF/8                           
                AD              LEADTIME                        # LEADTIME IS A NEGATIVE NUMBER
                AD              POSMAX                          # SAFEGUARD THE COMPUTATIONS THAT FOLLOW
                TS              L                               #       BY FORCING -TTF*LEADTIME > OR = ZERO
                CS              L                               
                AD              L                               
                ZL                                              
                EXTEND                                          
                DV              TTF/8                           
                TS              BUF                             # - RATIO OF LAG-DIMINISHED TTF TO TTF
                EXTEND                                          
                SQUARE                                          
                TS              BUF             +1              
                AD              BUF                             
                XCH             BUF             +1              # RATIO SQUARED - RATIO
                AD              BUF             +1              
                TS              MPAC                            # COEFFICIENT FOR VGU TERM
                AD              BUF             +1              
                INDEX           FIXLOC                          
                TS              26D                             # COEFFICIENT FOR RDG-RGU TERM
                AD              BUF             +1              
                INDEX           FIXLOC                          
                TS              28D                             # COEFFICIENT FOR VDG TERM
                AD              BUF                             
                AD              POSMAX                          
## Page 809
                AD              BUF             +1              
                AD              BUF             +1              
                INDEX           FIXLOC                          
                TS              30D                             # COEFFICIENT FOR ADG TERM

                CAF             ZERO                            
                TS              MODE                            

                TC              INTPRETX                        
                VXSC            PDDL                            
                                VGU                             
                                28D                             
                VXSC*           PDVL*                           
                                VDG,1                           
                                RDG,1                           
                VSU             V/SC                            
                                RGU                             
                                TTF/8                           
                VSR2            VXSC                            
                                26D                             
                VAD             VAD                             
                V/SC            VXSC                            
                                TTF/8                           
                                3/4DP                           
                PDDL            VXSC*                           
                                30D                             
                                ADG,1                           
                VAD                                             
AFCCALC1        VXM             VSL1                            # VERTGUID COMES HERE
                                CG                              
                PDVL            V/SC                            
                                GDT/2                           
                                GSCALE                          
                BVSU            STADR                           
                STORE           UNFC/2                          # UNFC/2 NEED NOT BE UNITIZED
                ABVAL                                           
AFCCALC2        STODL           /AFC/                           # MAGNITUDE OF AFC FOR THROTTLE
                                UNFC/2                          # VERTICAL COMPONENT
                DSQ             PDDL                            
                                UNFC/2          +2              # OUT-OF-PLANE
                DSQ             PDDL                            
                                HIGHESTF                        
                DDV             DSQ                             
                                MASS                            #                        2    2    2
                DSU             DSU                             # AMAXHORIZ = SQRT(ATOTAL - A  - A  )
                BPL             DLOAD                           #                            1    0
                                AFCCALC3                        
                                ZEROVECS                        
AFCCALC3        SQRT            DAD                             
                                UNFC/2          +4              
## Page 810
                BPL             BDSU                            
                                AFCCLEND                        
                                UNFC/2          +4              
                STORE           UNFC/2          +4              
AFCCLEND        EXIT                                            
                TC              FASTCHNG                        

                CA              WCHPHASE                        # PREPARE FOR PHASE SWITCHING LOGIC
                TS              WCHPHOLD                        
                INCR            FLPASS0                         # INCREMENT PASS COUNTER

BRSPOT4         INDEX           WCHPHASE                        
                TCF             AFTRGUID                        

# ***************************************************************************************************************
# ERECT GUIDANCE-STABLE MEMBER TRANSFORMATION MATRIX
# ***************************************************************************************************************

CGCALC          CAF             EBANK5                          
                TS              EBANK                           
                EBANK=          TCGIBRAK                        
                EXTEND                                          
                INDEX           WCHPHASE                        
                INDEX           TARGTDEX                        
                DCA             TCGFBRAK                        
                INCR            BBANK                           
                INCR            BBANK                           
                EBANK=          TTF/8                           
                AD              TTF/8                           
                XCH             L                               
                AD              TTF/8                           
                CCS             A                               
                CCS             L                               
                TCF             EXTLOGIC                        
                TCF             EXTLOGIC                        
                NOOP                                            

                TC              INTPRETX                        
                VLOAD           UNIT                            
                                LAND                            
                STODL           CG                              
                                TTF/8                           
                DMP*            VXSC                            
                                GAINBRAK,1                      # NUMERO MYSTERIOSO
                                ANGTERM                         
                VAD                                             
                                LAND                            
                VSU             RTB                             
                                R                               
                                NORMUNIT                        
## Page 811
                VXV             RTB                             
                                LAND                            
                                NORMUNIT                        
                STOVL           CG              +6              # SECOND ROW
                                CG                              
                VXV             VSL1                            
                                CG              +6              
                STORE           CG              +14             
                EXIT                                            

#               (CONTINUE TO EXTLOGIC)

# ****************************************************************************************************************
# PREPARE TO EXIT
# ****************************************************************************************************************

# DECIDE (1) HOW TO EXIT, AND (2) WHETHER TO SWITCH PHASES

EXTLOGIC        INDEX           WCHPHASE                        # WCHPHASE = 1   APPRQUAD
                CA              TENDBRAK                        # WCHPHASE = 0   BRAKQUAD
                AD              TTF/8                           

EXSPOT1         EXTEND                                          
                INDEX           WCHPHASE                        
                BZMF            WHATEXIT                        

                TC              FASTCHNG                        

                CA              WCHPHOLD                        
                AD              ONE                             
                TS              WCHPHASE                        
                CA              ZERO                            
                TS              FLPASS0                         # RESET FLPASS0

                INDEX           WCHPHOLD                        
                TCF             WHATEXIT                        

# ****************************************************************************************************************
# ROUTINES FOR EXITING FROM LANDING GUIDANCE
# ****************************************************************************************************************

# 1.    EXGSUB IS THE RETURN WHEN GUIDSUB IS CALLED BY THE IGNITION ALGORITHM.
# 2.    EXBRAK IN THE EXIT USED DURING THE BRAKING PHASE.  IN THIS CASE UNIT(R) IS THE WINDOW POINTING VECTOR.
# 3.    EXNORM IS THE EXIT USED AT OTHER TIMES DURING THE BURN.
# (EXOVFLOW IS A SUBROUTINE OF EXBRAK AND EXNORM CALLED WHEN OVERFLOW OCCURRED ANYWHERE IN GUIDANCE.)

EXGSUB          TC              INTPRET                         # COMPUTE TRIM VELOCITY CORRECTION TERM
## Page 812
                VLOAD           RTB                             
                                UNFC/2                          
                                NORMUNIT                        
                VXSC            VXSC                            
                                ZOOMTIME                        
                                TRIMACCL                        
                STORE           UNFC/2                          
                EXIT                                            

                CCS             NGUIDSUB                        
                TCF             GUIDSUB                         
                CCS             NIGNLOOP                        
                TCF             +3                              
                TC              ALARM                           
                OCT             01412                           

 +3             TC              POSTJUMP                        
                CADR            DDUMCALC                        

EXBRAK          TC              INTPRET                         
                VLOAD                                           
                                UNIT/R/                         
                STORE           UNWC/2                          
                EXIT                                            
                TCF             STEER?                          

EXNORM          TC              INTPRET                         
                VLOAD           VSU                             
                                LAND                            
                                R                               
                RTB                                             
                                NORMUNIT                        
                STORE           UNWC/2                          # UNIT(LAND - R) IS TENTATIVE CHOICE
                VXV             DOT                             
                                XNBPIP                          
                                CG              +6              
                EXIT                                            # WITH PROJ IN MPAC 1/8 REAL SIZE

                CS              MPAC                            # GET COEFFICIENT FOR CG +14
                AD              PROJMAX                         
                AD              POSMAX                          
                TS              BUF                             
                CS              BUF                             
                ADS             BUF                             # RESULT IS 0 IF PROJMAX - PROJ NEGATIVE

                CS              PROJMIN                         # GET COEFFICIENT FOR UNIT(LAND - R)
                AD              MPAC                            
                AD              POSMAX                          
                TS              BUF             +1              
                CS              BUF             +1              
## Page 813
                ADS             BUF             +1              # RESULT IS 0 IF PROJ - PROJMIN NEGATIVE

                CAF             FOUR                            
UNWCLOOP        MASK            SIX                             
                TS              Q                               
                CA              EBANK5                          
                TS              EBANK                           
                EBANK=          CG                              
                CA              BUF                             
                EXTEND                                          
                INDEX           Q                               
                MP              CG              +14             
                INCR            BBANK                           
                EBANK=          UNWC/2                          
                INDEX           Q                               
                DXCH            UNWC/2                          
                EXTEND                                          
                MP              BUF             +1              
                INDEX           Q                               
                DAS             UNWC/2                          
                CCS             Q                               
                TCF             UNWCLOOP                        

                INCR            BBANK                           
                EBANK=          PIF                             

STEER?          CA              FLAGWRD2                        # IF STEERSW DOWN NO OUTPUTS
                MASK            STEERBIT                        
                EXTEND                                          
                BZF             RATESTOP                        

EXVERT          CA              OVFIND                          # IF OVERFLOW ANYWHERE IN GUIDANCE
                EXTEND                                          #       DON'T CALL THROTTLE OR FINDCDUW
                BZF             +13                             

EXOVFLOW        TC              ALARM                           # SOUND THE ALARM NON-ABORTIVELY.
                OCT             01410                           

RATESTOP        CAF             BIT13                           # ARE WE IN ATTITUDE-HOLD?
                EXTEND                                          
                RAND            CHAN31                          
                EXTEND                                          
                BZF             DISPEXIT                        # YES

                TC              BANKCALL                        # NO:  DO A STOPRATE
                CADR            STOPRATE                        

                TCF             DISPEXIT                        

GDUMP1          TC              THROTTLE                        
## Page 814
                TC              INTPRET                         
                CALL                                            
                                FINDCDUW        -2              
                EXIT                                            

#               (CONTINUE TO DISPEXIT)

# ****************************************************************************************************************
# GUIDANCE LOOP DISPLAYS
# ****************************************************************************************************************

DISPEXIT        EXTEND                                          # KILL GROUP 3:  DISPLAYS WILL BE
                DCA             NEG0                            #       RESTORED BY NEXT GUIDANCE CYCLE
                DXCH            -PHASE3                         

 +3             CS              FLAGWRD8                        # IF FLUNDISP IS SET, NO DISPLAY THIS PASS
                MASK            FLUNDBIT                        
                EXTEND                                          
                BZF             ENDLLJOB                        # TO PICK UP THE TAG

                INDEX           WCHPHOLD                        
                TCF             WHATDISP                        

 -2             TC              PHASCHNG                        # KILL GROUP 5
                OCT             00035                           

P63DISPS        CAF             V06N63                          
DISPCOMN        TC              BANKCALL                        
                CADR            REGODSPR                        

ENDLLJOB        TCF             ENDOFJOB                        

P64DISPS        CA              TREDES                          # HAS TREDES REACHED ZERO?
                EXTEND                                          
                BZF             RED-OVER                        # YES: CLEAR REDESIGNATION FLAG

                CS              FLAGWRD6                        # NO:  IS REDFLAG SET?
                MASK            REDFLBIT                        
                EXTEND                                          
                BZF             REDES-OK                        # YES:  DO STATIC DISPLAY

                CAF             V06N64                          # OTHERWISE USE FLASHING DISPLAY
                TC              BANKCALL                        
                CADR            REFLASHR                        
                TCF             GOTOPOOH                        # TERMINATE
                TCF             P64CEED                         # PROCEED       PERMIT REDESIGNATIONS
                TCF             P64DISPS                        # RECYCLE
## Page 815
                TCF             ENDLLJOB                        # TO PICK UP THE TAG

P64CEED         CAF             ZERO                            
                TS              ELINCR1                         
                TS              AZINCR1                         

                TC              UPFLAG                          # ENABLE REDESIGNATION LOGIC
                ADRES           REDFLAG                         

                TCF             ENDOFJOB                        

RED-OVER        TC              DOWNFLAG                        
                ADRES           REDFLAG                         
REDES-OK        CAF             V06N64                          
                TCF             DISPCOMN                        


VERTDISP        CAF             V06N60                          
                TCF             DISPCOMN                        


# ****************************************************************************************************************
# GUIDANCE FOR P65
# ****************************************************************************************************************

VERTGUID        CCS             WCHVERT                         
                TCF             P67VERT                         # POSITIVE NON-ZERO ---> P67
                TCF             P66VERT                         # +0

#       THE P65 GUIDANCE EQUATION IS AS FOLLOWS:-
#                     -      -
#                     V2FG - VGU
#               ACG = ----------
#                       TAUVERT

P65VERT         TC              INTPRET                         
                VLOAD           VSU                             
                                V2FG                            
                                VGU                             
                V/SC            GOTO                            
                                TAUVERT                         
                                AFCCALC1                        
## Page 816
# ****************************************************************************************************************
# GUIDANCE FOR P66
# ****************************************************************************************************************

P66VERT         TC              POSTJUMP                        
                CADR            P66VERTA                        

P67VERT         TC              PHASCHNG                        # TERMINATE GROUP 3
                OCT             00003                           

                TC              INTPRET                         
                VLOAD           GOTO                            
                                V                               
                                VHORCOMP                        

                SETLOC          P66LOC                          
                BANK                                            
                COUNT*          $$/F2DPS                        

RODTASK         CAF             PRIO22                          
                TC              FINDVAC                         
                EBANK=          DVCNTR                          
                2CADR           RODCOMP                         

                TCF             TASKOVER                        

P66VERTA        TC              PHASCHNG                        # TERMINATE GROUP 3.
                OCT             00003                           

                CAF             1SEC                            
                TC              TWIDDLE                         
                ADRES           RODTASK                         

RODCOMP         INHINT                                          
                CAF             ZERO                            
                XCH             RODCOUNT                        
                EXTEND                                          
                MP              RODSCAL1                        
                DAS             VDGVERT                         # UPDATE DESIRED ALTITUDE RATE.

                EXTEND                                          # SET OLDPIPAX,Y,Z = PIPAX,Y,Z
                DCA             PIPAX                           
                DXCH            OLDPIPAX                        
                DXCH            RUPTREG1                        # SET RUPTREG1,2,3 = OLDPIPAX,Y,Z
                CA              PIPAZ                           
                XCH             OLDPIPAZ                        
                XCH             RUPTREG3                        

                EXTEND                                          # SHAPSHOT TIME OF PIPA READING.
                DCA             TIME2                           
## Page 817
                DXCH            THISTPIP                        

                CA              OLDPIPAX                        
                AD              PIPATMPX                        
                TS              MPAC                            # MPAC(X) = PIPAX + PIPATMPX
                CA              OLDPIPAY                        
                AD              PIPATMPY                        
                TS              MPAC            +3              # MPAC(Y) = PIPAY + PIPATMPY
                CA              OLDPIPAZ                        
                AD              PIPATMPZ                        
                TS              MPAC            +5              # MPAC(Z) = PIPAZ + PIPATMPZ

                CS              OLDPIPAX                        
                AD              TEMX                            
                AD              RUPTREG1                        
                TS              DELVROD                         
                CS              OLDPIPAY                        
                AD              TEMY                            
                AD              RUPTREG2                        
                TS              DELVROD         +2              
                CS              OLDPIPAZ                        
                AD              TEMZ                            
                AD              RUPTREG3                        
                TS              DELVROD         +4              

                CAF             ZERO                            
                TS              MPAC            +1              # ZERO LO-ORDER MPAC COMPONENTS
                TS              MPAC            +4              
                TS              MPAC            +6              
                TS              TEMX                            # ZERO TEMX, TEMY, AND TEMZ SO WE WILL
                TS              TEMY                            #       KNOW WHEN READACCS CHANGES THEM.
                TS              TEMZ                            
                CS              ONE                             
                TS              MODE                            
                TC              INTPRET                         
ITRPNT1         VXSC            PDDL                            # SCALE MPAC TO M/CS *2(-7) AND PUSH    (6)
                                KPIP1                           
                                THISTPIP                        
                DSU                                             
                                PIPTIME                         
                STORE           30D                             # 30-31D CONTAINS TIME IN CS SINCE PIPTIME
                DDV             PDVL                            #                                       (8)
                                4SEC(28)                        
                                GDT/2                           
                VSU             VXSC                            #                                       (6)
                                VBIAS                           
                VSL2            VAD                             
                                V                               
                VAD             STADR                           #                                       (0)
                STOVL           24D                             # STORE UPDATED VELOCITY IN 24-29D
## Page 818
                                R                               
                UNIT                                            
                STORE           14D                             
                DOT             SL1                             
                                24D                             
                STODL           HDOTDISP                        # UPDATE HDOTDISP FOR NOUN 63.
                                30D                             
                SL              DMP                             
                                11D                             
                                HDOTDISP                        
                DAD             DSU                             
                                36D                             
                                /LAND/                          
                STODL           HCALC1                          # UPDATE HCALC1 FOR NOUN 63.
                                HDOTDISP                        
                BDSU            DDV                             
                                VDGVERT                         
                                TAUROD                          
                PDVL            ABVAL                           #                               (2)
                                GDT/2                           
                DDV             SR2                             
                                GSCALE                          
                STORE           20D                             
                DAD                                             #                               (0)
                PDVL            CALL                            #                               (2)
                                UNITX                           
                                CDU*NBSM                        
                DOT                                             
                                14D                             
                STORE           22D                             
                BDDV            STADR                           #                               (0)
                STOVL           /AFC/                           
                                DELVROD                         
                VXSC            VAD                             
                                KPIP1                           
                                VBIAS                           
                ABVAL           PDDL                            #                               (2)
                                THISTPIP                        
                DSU             PDDL                            #                               (4)
                                LASTTPIP                        
                                THISTPIP                        
                STODL           LASTTPIP                        #                               (2)
                DDV             BDDV                            #                               (0)
                                SHFTFACT                        
                PDDL            DMP                             #                               (2)
                                FWEIGHT                         
                                BIT1H                           
                DDV             DDV                             
                                MASS                            
                                SCALEFAC                        
## Page 819
                DAD             PDDL                            #                               (4)
                                0D                              
                                20D                             
                DDV             DSU                             #                               (2)
                                22D                             
                DMP             DAD                             
                                LAG/TAU                         
                                /AFC/                           
                PDDL            DDV                             #                               (4)
                                MAXFORCE                        
                                MASS                            
                PDDL            DDV                             #                               (6)
                                MINFORCE                        
                                MASS                            
                PUSH            BDSU                            #                               (8)
                                2D                              
                BMN             DLOAD                           #                               (6)
                                AFCSPOT                         
                DLOAD           PUSH                            #                               (6)
                BDSU            BPL                             
                                2D                              
                                AFCSPOT                         
                DLOAD                                           #                               (4)
AFCSPOT         DLOAD                                           #                               (2), (4), OR (6)
                SETPD                                           #                               (2)
                                2D                              
                STODL           /AFC/                           #                               (0)
ITRPNT2         EXIT                                            
                DXCH            MPAC                            # MPAC = MEASURED ACCELERATION.
                TC              BANKCALL                        
                CADR            THROTTLE        +3              
                TC              INTPRET                         
                VLOAD                                           # PICK UP UPDATED VELOCITY VECTOR.
                                24D                             
VHORCOMP        VSL2            VAD                             
                                DELVS                           
                VSR2            PDVL                            #                               (6)
                                R                               
                UNIT            VXSC                            
                                HDOTDISP                        
                VSL1            BVSU                            #                               (0)
                ABVAL                                           
                STORE           VHORIZ                          
                EXIT                                            
                TC              BANKCALL                        # PUT UP V06N60 DISPLAY BUT AVOID PHASCHNG
                CADR            DISPEXIT        +3              

BIT1H           OCT             00001                           
SHFTFACT        2DEC            1               B-17            
## Page 820
BIASFACT        2DEC            655.36          B-28            

# ****************************************************************************************************************
# REDESIGNATOR TRAP
# ****************************************************************************************************************

                BANK            11                              
                SETLOC          F2DPS*11                        
                BANK                                            

                COUNT*          $$/F2DPS                        

PITFALL         XCH             BANKRUPT                        
                EXTEND                                          
                QXCH            QRUPT                           

                TC              CHECKMM                         # IF NOT IN P64, NO REASON TO CONTINUE
                DEC             64                              
                TCF             RESUME                          

                EXTEND                                          
                READ            CHAN31                          
                COM                                             
                MASK            ALL4BITS                        
                TS              ELVIRA                          
                CAF             TWO                             
                TS              ZERLINA                         
                CAF             FIVE                            
                TC              TWIDDLE                         
                ADRES           REDESMON                        
                TCF             RESUME                          

# REDESIGNATION MONITOR (INITIATED BY PITFALL)

PREMON1         TS              ZERLINA                         
PREMON2         CAF             SEVEN                           
                TC              VARDELAY                        
REDESMON        EXTEND                                          
                READ            31                              
                COM                                             
                MASK            ALL4BITS                        
                XCH             ELVIRA                          
                TS              L                               
                CCS             ELVIRA                          # DO ANY BITS APPEAR THIS PASS?
                TCF             PREMON2                         # Y:    CONTINUE MONITOR

                CCS             L                               # N:    ANY LAST PASS?
                TCF             COUNT'EM                        #       Y:      COUNT 'EM, RESET RUPT, TERMINATE
## Page 821
                CCS             ZERLINA                         #       N:      HAS ZERLINA REACHED ZERO YET?
                TCF             PREMON1                         #               N:      DIMINISH ZERLINA, CONTINUE
RESETRPT        CAF             BIT12                           #               Y:      RESET RUPT. TERMINATE
                EXTEND                                          
                WOR             CHAN13                          
                TCF             TASKOVER                        

COUNT'EM        CAF             BIT13                           # ARE WE IN ATTITUDE-HOLD?
                EXTEND                                          
                RAND            CHAN31                          
                EXTEND                                          
                BZF             RESETRPT                        # YES: SKIP REDESIGNATION LOGIC.

                CA              L                               # NO
                MASK            -AZBIT                          
                CCS             A                               
-AZ             CS              AZEACH                          
                ADS             AZINCR1                         
                CA              L                               
                MASK            +AZBIT                          
                CCS             A                               
+AZ             CA              AZEACH                          
                ADS             AZINCR1                         
                CA              L                               
                MASK            -ELBIT                          
                CCS             A                               
-EL             CS              ELEACH                          
                ADS             ELINCR1                         
                CA              L                               
                MASK            +ELBIT                          
                CCS             A                               
+EL             CA              ELEACH                          
                ADS             ELINCR1                         
                TCF             RESETRPT                        

# THESE EQUIVALENCIES ARE BASED ON GSOP CHAPTER 4, REVISION 16 OF P64LM

+ELBIT          =               BIT2                            # -PITCH
-ELBIT          =               BIT1                            # +PITCH
+AZBIT          =               BIT5                            
-AZBIT          =               BIT6                            

## Page 822
ALL4BITS        OCT             00063                           
AZEACH          DEC             .03491                          # 2 DEGREES
ELEACH          DEC             .00873                          # 1/2 DEGREE

# ****************************************************************************************************************
# R.O.D. TRAP
# ************************************************************************

                BANK            20                              
                SETLOC          RODTRAP                         
                BANK                                            
                COUNT*          $$/F2DPS                        # ****************************************

DESCBITS        MASK            BIT7                            # COME HERE FROM MARKRUPT CODING WITH BIT
                CCS             A                               #       7 OR 6 OF CHANNEL 16 IN A; BIT 7 MEANS
                CS              TWO                             #       - RATE INCREMENT, BIT 6 + INCREMENT
                AD              ONE                             
                ADS             RODCOUNT                        
                TCF             RESUME                          # TRAP IS RESET WHEN SWITCH IS RELEASED

                BANK            31                              
                SETLOC          F2DPS*31                        
                BANK                                            

                COUNT*          $$/F2DPS                        

# ****************************************************************************************************************
# DOUBLE PRECISION ROOT FINDER SUBROUTINE (BY ALLAN KLUMPP)
# ****************************************************************************************************************

#                                                      N        N-1
#       ROOTPSRS FINDS ONE ROOT OF THE POWER SERIES A X  + A   X    + ... + A X + A
#                                                    N      N-1              1     0
# USING NEWTON'S METHOD STARTING WITH AN INITIAL GUESS FOR THE ROOT.  THE ENTERING DATA MUST BE AS FOLLOWS:
#       A       SP      LOC-3           ADRES FOR REFERENCING PWR COF TABL
#       L       SP      N-1             N IS THE DEGREE OF THE POWER SERIES
#       MPAC    DP      X               INITIAL GUESS FOR ROOT

#       LOC-2N  DP      A(0)
#               ...
#       LOC     DP      A(N)
#       LOC+2   SP      PRECROOT         PREC RQD OF ROOT (AS FRACT OF 1ST GUESS)

## Page 823
# THE DP RESULT IS LEFT IN MPAC UPON EXIT, AND A SP COUNT OF THE ITERATIONS TO CONVERGENCE IS LEFT IN MPAC+2.
# RETURN IS NORMALLY TO LOC(TC ROOTPSRS)+3.  IF ROOTPSRS FAILS TO CONVERGE IN 8 PASSES, RETURN IS TO LOC+1 AND
# OUTPUTS ARE NOT TO BE TRUSTED.

# PRECAUTION:  ROOTPSRS MAKES NO CHECKS FOR OVERFLOW OR FOR IMPROPER USAGE.  IMPROPER USAGE COULD
# PRECLUDE CONVERGENCE OR REQUIRE EXCESSIVE ITERATIONS.  AS A SPECIFIC EXAMPLE, ROOTPSRS FORMS A DERIVATIVE
# COEFFICIENT TABLE BY MULTIPLYING EACH A(I) BY I, WHERE I RANGES FROM 1 TO N.  IF AN ELEMENT OF THE DERIVATIVE
# COEFFICIENT TABLE = 1 OR >1 IN MAGNITUDE, ONLY THE EXCESS IS RETAINED.  ROOTPSRS MAY CONVERGE ON THE CORRECT
# ROOT NONETHELESS, BUT IT MAY TAKE AN EXCESSIVE NUMBER OF ITERATIONS.  THEREFORE THE USER SHOULD RECOGNIZE:
#       1.  USER'S RESPONSIBILITY TO ASSURE THAT I X A(I) < 1 IN MAGNITUDE FOR ALL I.
#       2.  USER'S RESPONSIBILITY TO ASSURE OVERFLOW WILL NOT OCCUR IN EVALUATING EITHER THE RESIDUAL OR THE DERIVATIVE
#           POWER SERIES.  THIS OVERFLOW WOULD BE PRODUCED BY SUBROUTINE POWRSERS, CALLED BY ROOTPSRS, AND MIGHT NOT
#           PRECLUDE EVENTUAL CONVERGENCE.
#       3.  AT PRESENT, ERASABLE LOCATIONS ARE RESERVED ONLY FOR N UP TO 5.  AN N IN EXCESS OF 5 WILL PRODUCE CHAOS.
#           ALL ERASABLES USED BY ROOTPSRS ARE UNSWITCHED LOCATED IN THE REGION FROM MPAC-33 OCT TO MPAC+7.
#       4.  THE ITERATION COUNT RETURNED IN MPAC+2 MAY BE USED TO DETECT ABNORMAL PERFORMANCE.

                                                                # STORE ENTERING DATA, INITLIZE ERASABLES
ROOTPSRS        EXTEND                                          
                QXCH            RETROOT                         # RETURN ADRES
                TS              PWRPTR                          # PWR TABL POINTER
                DXCH            MPAC            +3              # PWR TABL ADRES, N-1
                CA              DERTABLL                        
                TS              DERPTR                          # DER TABL POINTER
                TS              MPAC            +5              # DER TABL ADRES
                CCS             MPAC            +4              # NO POWER SERIES OF DEGREE 1 OR LESS
                TS              MPAC            +6              # N-2
                CA              ZERO                            # MODE USED AS ITERATION COUNTER.  MODE
                TS              MODE                            # MUST BE POS SO ABS WON'T COMP MPAC+3 ETC

                                                                # COMPUTE CRITERION TO STOP ITERATING
                EXTEND                                          
                DCA             MPAC                            # FETCH ROOT GUESS, KEEPING IT IN MPAC
                DXCH            ROOTPS                          # AND IN ROOTPS
                INDEX           MPAC            +3              # PWR TABL ADRES
                CA              5                               # PRECROOT TO A
                TC              SHORTMP                         # YIELDS DP PRODUCT IN MPAC
                TC              USPRCADR                        
                CADR            ABS                             # YIELDS ABVAL OF CRITERION ON DX IN MPAC
                DXCH            MPAC                            
                DXCH            DXCRIT                          # CRITERION

                                                                # SET UP DER COF TABL
## Page 824
                EXTEND                                          
                INDEX           PWRPTR                          
                DCA             3                               
                DXCH            MPAC                            # A(N) TO MPAC

                CA              MPAC            +4              # N-1 TO A

DERCLOOP        TS              PWRCNT                          # LOOP COUNTER
                AD              ONE                             
                TC              DMPNSUB                         # YIELDS DERCOF = I X A(I) IN MPAC
                EXTEND                                          
                INDEX           PWRPTR                          
                DCA             1                               
                DXCH            MPAC                            # A(I-1) TO MPAC, FETCHING DERCOF
                INDEX           DERPTR                          
                DXCH            3                               # DERCOF TO DER TABL
                CS              TWO                             
                ADS             PWRPTR                          # DECREMENT PWR POINTER
                CS              TWO                             
                ADS             DERPTR                          # DECREMENT DER POINTER
                CCS             PWRCNT                          
                TCF             DERCLOOP                        

                                                                # CONVERGE ON ROOT
ROOTLOOP        EXTEND                                          
                DCA             ROOTPS                          # FETCH CURRENT ROOT
                DXCH            MPAC                            # LEAVE IN MPAC
                EXTEND                                          
                DCA             MPAC            +5              # LOAD A, L WITH DER TABL ADRES, N-2
                TC              POWRSERS                        # YIELDS DERIVATIVE IN MPAC

                EXTEND                                          
                DCA             ROOTPS                          
                DXCH            MPAC                            # CURRENT ROOT TO MPAC, FETCHING DERIVTIVE
                DXCH            BUF                             # LEAVE DERIVATIVE IN BUF AS DIVISOR
                EXTEND                                          
                DCA             MPAC            +3              # LOAD A, L WITH PWR TABL ADRES, N-1
                TC              POWRSERS                        # YIELDS RESIDUAL IN MPAC

                TC              USPRCADR                        
                CADR            DDV/BDDV                        # YIELDS -DX IN MPAC

                EXTEND                                          
                DCS             MPAC                            # FETCH DX, LEAVING -DX IN MPAC
                DAS             ROOTPS                          # CORRECTED ROOT NOW IN ROOTPS

                TC              USPRCADR                        
                CADR            ABS                             # YIELDS ABS(DX) IN MPAC
                EXTEND                                          
## Page 825
                DCS             DXCRIT                          
                DAS             MPAC                            # ABS(DX)-ABS(DXCRIT) IN MPAC

                CA              MODE                            
                MASK            BIT4                            # KLUMPP SAYS GIVE UP AFTER EIGHT PASSES
                CCS             A                               
BADROOT         TC              RETROOT                         

                INCR            MODE                            # INCREMENT ITERATION COUNTER
                CCS             MPAC                            # TEST HI ORDER DX
                TCF             ROOTLOOP                        
                TCF             TESTLODX                        
                TCF             ROOTSTOR                        
TESTLODX        CCS             MPAC            +1              # TEST LO ORDER DX
                TCF             ROOTLOOP                        
                TCF             ROOTSTOR                        
                TCF             ROOTSTOR                        
ROOTSTOR        DXCH            ROOTPS                          
                DXCH            MPAC                            
                CA              MODE                            
                TS              MPAC            +2              # STORE SP ITERATION COUNT IN MPAC+2
                INDEX           RETROOT                         
                TCF             2                               

DERTABLL        ADRES           DERCOFN         -3              

# *****************************************************************************************************************
# TRASHY LITTLE SUBROUTINES
# *****************************************************************************************************************

INTPRETX        INDEX           WCHPHASE                        # SET X1 ON THE WAY TO THE INTERPRETER
                CS              TARGTDEX                        
                INDEX           FIXLOC                          
                TS              X1                              
                TCF             INTPRET                         

TDISPSET        CA              TTF/8                           
                EXTEND                                          
                MP              TSCALINV                        
                DXCH            TTFDISP                         

                CA              EBANK5                          # TREDES BECOMES ZERO TWO PASSES
                TS              EBANK                           #       BEFORE TCGFAPPR IS REACHED
                EBANK=          TCGFAPPR                        
                CA              TCGFAPPR                        
                INCR            BBANK                           
                INCR            BBANK                           
                EBANK=          TTF/8                           
## Page 826
                AD              TTF/8                           
                EXTEND                                          
                MP              TREDESCL                        
                AD              -DEC103                         
                AD              NEGMAX                          
                TS              L                               
                CS              L                               
                AD              L                               
                AD              +DEC99                          
                AD              POSMAX                          
                TS              TREDES                          
                CS              TREDES                          
                ADS             TREDES                          
                TC              Q                               

1406P00         TC              POODOO                          
                OCT             01406                           
1406ALM         TC              ALARM                           
                OCT             01406                           
                TCF             RATESTOP                        

# ****************************************************************************************************************
# SPECIALIZED "PHASCHNG" SUBROUTINE
# ****************************************************************************************************************

                EBANK=          PHSNAME2                        
FASTCHNG        CA              EBANK3                          # SPECIALIZED 'PHASCHNG' ROUTINE
                XCH             EBANK                           
                DXCH            L                               
                TS              PHSNAME3                        
                LXCH            EBANK                           
                EBANK=          E2DPS                           
                TC              A                               

# ****************************************************************************************************************
# PARAMETER TABLE INDIRECT ADDRESSES
# ****************************************************************************************************************

RDG             =               RBRFG                           
VDG             =               VBRFG                           
ADG             =               ABRFG                           
VDG2TTF         =               VBRFG*                          
ADG2TTF         =               ABRFG*                          
JDG2TTF         =               JBRFG*                          

# ****************************************************************************************************************
# LUNAR LANDING CONSTANTS
# ***************************************************************************************************************

## Page 827
TABLTTFL        ADRES           TABLTTF         +3              # ADDRESS FOR REFERENCING TTF TABLE
TTFSCALE        =               BIT12                           
TSCALINV        =               BIT4                            
-DEC103         DEC             -103                            
+DEC99          DEC             +99                             
TREDESCL        DEC             -.08                            
180DEGS         DEC             +180                            
1/2DEG          DEC             +.00278                         
PROJMAX         DEC             .42262          B-3             # SIN(25')/8 TO COMPARE WITH PROJ
PROJMIN         DEC             .25882          B-3             # SIN(15')/8 TO COMPARE WITH PROJ
V06N63          VN              0663                            # P63
V06N64          VN              0664                            # P64
V06N60          VN              0660                            # P65, P66, P67

                BANK            22                              
                SETLOC          LANDCNST                        
                BANK                                            
                COUNT*          $$/F2DPS                        

HIGHESTF        2DEC            4.34546769      B-12            
GSCALE          2DEC            100             B-11            
3/8DP           2DEC            .375                            
3/4DP           2DEC            .750                            
DEPRCRIT        2DEC            -.02            B-1             

## Page 828
# ****************************************************************************************************************
# ****************************************************************************************************************
