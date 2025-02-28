c$Id:$
      subroutine pplotf(lci,ct,prop)

c      * * F E A P * * A Finite Element Analysis Program

c....  Copyright (c) 1984-2009: Robert L. Taylor
c                               All rights reserved

c     P l o t   C o n t r o l   R o u t i n e   F o r   F E A P
c-----[--.----+----.----+----.-----------------------------------------]
c      Purpose: Driver for plot commands.

c      Inputs:
c         lci       - Plot command option: if blank interactive inputs
c         ct(3)     - Plot command parameters
c         prop      - Proportional load value

c      Outputs:
c         none      - Plot outputs to screen/file
c-----[--.----+----.----+----.-----------------------------------------]

      implicit  none

      include  'comblk.h'
      include  'pointer.h'

      include  'arcler.h'
      include  'cdata.h'
      include  'cdat1.h'
      include  'evdata.h'
      include  'fdata.h'
      include  'hlpdat.h'
      include  'iofile.h'
      include  'pbody.h'
      include  'pdata1.h'
      include  'pdata2.h'
      include  'pdata3.h'
      include  'pdata4.h'
      include  'pdatap.h'
      include  'pdatps.h'
      include  'pdatxt.h'
      include  'plclip.h'
      include  'plflag.h'
      include  'ppers.h'
      include  'prange.h'
      include  'prflag.h'
      include  'print.h'
      include  'prmptd.h'
      include  'prstrs.h'
      include  'pview.h'
      include  'sdata.h'

      character lci*4,lct*4,tx(2)*15
      logical   cflag,errv,labl,odefalt,outf,pflag,ppr,symf
      logical   pltact
      logical   pcomp,tinput,vinput,palloc, setvar, tr,fa

      integer   i,icol,icp,ijump,jj,k1,k2,k3,k4,k5,l
      integer   n,nsizt,nxd,nxn,nne,nface,nfaco, iln(2)
      integer   nty,ntz,nix

      real*8    dumv,es,xm,zcol, prop
      real*8    ct(3),ss(4),tt(4),td(4)

c     Dictionary storage

      integer      list
      parameter (  list = 44)
      character wd(list)*4
      integer   ed(list)

      save

c     Plot data command list

      data wd/'fram','wipe','fact','cent','cart','line','mesh','outl',
     1        'load','disp','stre','node','boun','elem','zoom','colo',
     2        'fill','eigv','scal','axis','pers','hide','defo','unde',
     3        'cont','velo','acce','post','reac','mate','dofs','estr',
     4        'pstr','prom','defa','rang','nora','manu','uplo',
     u        'plt1','plt2','plt3','plt4','plt5'/

      data ed/    1,     0,     1,     2,     0,     1,     0,     0,
     1            0,     0,     0,     0,     0,     0,     0,     1,
     2            0,     0,     1,     0,     0,     0,     0,     0,
     3            0,     0,     0,     0,     0,     0,     1,     0,
     4            0,     2,     2,     1,     1,     4,     3,
     u            4,     4,     4,     4,     4/

      data ss/.25d0,.75d0,.25d0,.75d0/,tt/.75d0,.75d0,.25d0,.25d0/
      data tr/.true./, fa /.false./

c-----[--.----+----.----+----.-----------------------------------------]

c     Assign storage for deformed position

      setvar = palloc( 54, 'CT   ', 3*numnp, 2)

c     Initialize on first call

      if(.not.pfl) then

c       Set initial parameters

        fwin    =  fa
        fwoff   =  tr
        psoff   =  tr
        cflag   =  tr
        pflag   =  tr
        bordfl  =  tr
        clchk   =  fa
        clip    =  tr
        fopn    =  fa
        hdcpy   =  fa
        hdlogo  =  fa
        psfram  =  fa
        blk     =  fa
        ppr     =  tr
        pfl     =  tr
        hide    =  fa
        labl    =  tr
        outf    =  tr
        rangfl  =  fa
        symf    =  fa
        fact    = 1.0d0
        iclear  = 0
        ienter  = 0
        iexit   = 0
        nsizt   = 1
        nix     = 33
        nxd     = nen1
        nxn     = nen
        nne     = numel
        nfac    = numel
        nfmx    = numel
        maplt   = 0

c       Determine 3-d sizes for surface plots

        setvar = palloc(91,'APLOT',numel  ,1)
        setvar = palloc( 61,'OUTL ',numnp+1,2)
        call setclp(hr(np(43)),ndm,numnp)
        call plfacn(mr(np(33)),mr(np(91)),nen,
     &              numel,nface,mr(np(32)),nie)
        setvar = palloc( 55,'FCIX ',7*max(nface,1),1)
        nfaco   = max(nface,1)
        call plfacx(mr(np(33)),mr(np(91)),mr(np(55)),
     &              nen,numel,mr(np(32)),nie)

        setvar = palloc( 56,'FCZM ',max(nface,numel),2)
        setvar = palloc( 62,'SYMM ',max(nface,numel),1)
        call psetip(mr(np(62))     ,max(nface,numel))

        setvar = palloc( 59,'VISN ',numnp, 1)

        do i = 1,3
          pdf(i) = i
        end do ! i

c       Set initial conditions for no perspective

        kpers   = 0
        call pzero (xsyc,3)
        call pzero (eold,3)
        call pzero (vold,3)
        vold(ndm) = 1.0d0
        ifrm    = 0
        iln(1)  = 0
        iln(2)  = 1
        ilno(1) = 0
        ilno(2) = 1
        nzm1 = 0
        nzm2 = 0
        cs   = 0.0d0
        es   = 1.0d0
        call frame(hr(np(43)),ndm,numnp,1)

c     Check for elements currently active

      else
        if(pltact) then
          pltact = fa
          call setclp(hr(np(43)),ndm,numnp)
          call plfacn(mr(np(33)),mr(np(91)),nen,
     &                numel,nface,mr(np(32)),nie)
          if(nface.gt.nfaco) then
            setvar = palloc( 55,'FCIX ',7*max(nface,1),1)
          endif
          call pzeroi(mr(np(55)),7*nface)
          call plfacx(mr(np(33)),mr(np(91)),mr(np(55)),
     &                nen,numel,mr(np(32)),nie)
          if(max(nface,numel).gt.max(nfaco,numel)) then
            setvar = palloc( 56,'FCZM ',max(nface,numel),2)
            setvar = palloc( 62,'SYMM ',max(nface,numel),1)
          endif
          nfaco = max(nfaco,1)
          call pzero  (hr(np(56)),max(nface,numel))
          call pzeroi(mr(np(62)),max(nface,numel))
          call psetip (mr(np(62)),max(nface,numel))
          if(hide) then
            call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),
     &                 ndm,ndf,numnp,hr(np(54)))
            call pppcol(0,0)
            call pzeroi(mr(np(59)),numnp)
            nix  = 55
            nxd  = 7
            nxn  = 4
            nne  = nface
            call plface(mr(np(nix)),mr(np(62)),hr(np(54)),
     &                  3,nxd,numnp,nne,iln,ct(2))
c           nne  = nfac
            if(ndm.eq.3) then
              write(*,*) ' **ERROR** No 3-d outline '
            endif
            if(kpers.ne.0) then
              call perspz(hr(np(54)),mr(np(nix)), hr(np(61)),hr(np(56)),
     &                    mr(np(62)),nxd,nxn,  3,numnp,nne)
            endif
          endif
        endif

      endif

      ijump = 0

c     Start plot or clear screen

60    if(iclear.eq.0) then
        call plopen
        call plclos
        iclear = 1
      endif

      if(ior.lt.0.and.pcomp(lci,'    ',4)) then
        ijump  = 1
        if (ppr) then
          write(*,2003)
          write(*,2004) ijump
        else
          write(*,2010)
        endif
        setvar = tinput(tx,2,td,4)
        lct    = tx(1)

        if(pcomp(lct,'end ',4) .or. pcomp(lct,'e   ',4)) then
          setvar = palloc( 54, 'CT   ', 0, 2)
          return
        endif

        if(ior.lt.0.and.pcomp(lct,'help',4)) then
          call phelp(tx(2),wd,ed,list,'PLOT')
          go to 200
        endif

      else
        lct = lci
      endif

c     Set initial values for parameters

      ipb    = 0
      dtext  = 0.0d0
      do l = 1,list
        if(pcomp(lct,wd(l),4)) go to 100
      end do ! l
      if(ior.gt.0) write(iow,2001) lct
      if(ior.lt.0) write(*,2001) lct
      go to 200

c     Set 'ct' parameters for interactive mode

100   if(ijump.ne.0) then
        setvar = vinput(tx(2),15,ct(1),1)
        ct(2)  = td(1)
        ct(3)  = td(2)
        zcol   = td(3)
      else                                     ! Batch mode
        zcol   = 0.0d0
      endif

c     Transfer to requested plot operation

      go to( 1, 1, 3, 4, 5, 6, 7, 8, 9, 9,11,12,13,14,15,16,17,18,19,20,

c            f  w  f  c  c  l  m  o  l  d  s  n  b  e  z  c  f  e  s  a
c            r  i  a  e  a  i  e  u  o  i  t  o  o  l  o  o  i  i  c  x
c            a  p  c  n  r  n  s  t  a  s  r  d  u  e  o  l  l  g  a  i
c            m  e  t  t  t  e  h  l  d  p  e  e  n  m  m  o  l  v  l  s

     &      21,22,23,24,25,4,25,28,29,30,31,11,11,34,35,36,37,38,39,

c            p  h  d  u  c  v  a  p  r  m  d  e  p  p  d  r  n  m  u
c            e  i  e  n  o  e  c  o  e  a  o  s  s  r  e  a  o  a  p
c            r  d  f  d  n  l  c  s  a  t  f  t  t  o  f  n  r  n  l
c            s  e  o  e  t  o  e  t  c  e  s  r  r  m  a  g  a  u  o

     &      800,800,800,800,800), l

c            p   p   p   p   p
c            l   l   l   l   l
c            t   t   t   t   t
c            1   2   3   4   5

      go to 200

c     New frame
c     [fram,ifrm] - ifrm = 0 for whole screen
c                   ifrm = 1 for upper-left
c                   ifrm = 2 for upper-right
c                   ifrm = 3 for lower-left
c                   ifrm = 4 for lower-right
c                   ifrm = 5 for legend Box

1     ifrm = ct(1)
      ifrm = min(5,ifrm)
110   if(ifrm.ge.1 .and. ifrm.le.4) then
         scale = 0.5d0*scaleg*fact
         s0(1) = ss(ifrm)
         s0(2) = tt(ifrm)
      elseif(ifrm.eq.0) then
         scale = scaleg*fact
         s0(1) = 0.5d0
         s0(2) = 0.5d0
      endif

c     [wipe,ifrm,noclean] - ifrm as above - clean screen

      if(l.eq.2) then
        xp(1) = min(-ct(1),ct(2))
        if(ifrm.eq.0) iclear = 0
        call plopen
        call pppcol(-1,0)
        if(ifrm.eq.1) call ppbox(.010d0,.485d0,.476d0,.475d0,1)
        if(ifrm.eq.2) call ppbox(.485d0,.485d0,.475d0,.475d0,1)
        if(ifrm.eq.3) call ppbox(.010d0,.010d0,.476d0,.476d0,1)
        if(ifrm.eq.4) call ppbox(.485d0,.010d0,.475d0,.476d0,1)
        if(ifrm.eq.5) call ppbox(0.98d0,0.10d0,0.30d0,0.70d0,1)
        ifrm = mod(ifrm,5)
      endif
      go to 200

c     [fact,value] - Multiply plot area by 'value'

3     if(ct(1).eq.0.0d0) then
        fact = 1.0
      else
        fact = ct(1)
      endif
      go to 110

c     [cent]er,s0-1,s0-2  - center graphics in window

4     if(abs(ct(1))+abs(ct(2)).ne.0.0d0) then
        s0(1) = ct(1)
        s0(2) = ct(2)
      else
        s0(1) = ss(ifrm)
        s0(2) = tt(ifrm)
      endif
      go to 200

c     [cart] - cartesian view: (l=5)

5     nix   = 33
      nxd   = nen1
      nxn   = nen
      nne   = numel
      nfac  = nne
      hide  = fa
      kpers = 0
      call psetip(mr(np(62)),nne)
      call frame(hr(np(43)),ndm,numnp,1)
      go to 200

c     [line,value,width] - 'value' is line type
c                          'width' is line width (device dependent)

6     iln(1) = max(0,min(nint(ct(1)),7))
      iln(2) = max(0,min(nint(ct(2)),5))
      if(ior.lt.0) then
        if(iln(1).eq.0) then
          write(*,2030) iln(2)
        elseif(iln(1).eq.1) then
          write(*,2031) iln(2)
        elseif(iln(1).eq.2) then
          write(*,2032) iln(2)
        elseif(iln(1).eq.3) then
          write(*,2033) iln(2)
        elseif(iln(1).eq.4) then
          write(*,2034) iln(2)
        elseif(iln(1).eq.5) then
          write(*,2035) iln(2)
        elseif(iln(1).eq.6) then
          write(*,2036) iln(2)
        elseif(iln(1).eq.7) then
          write(*,2037) iln(2)
        endif
      else
        if(iln(1).eq.0) then
          write(iow,2030) iln(2)
        elseif(iln(1).eq.1) then
          write(iow,2031) iln(2)
        elseif(iln(1).eq.2) then
          write(iow,2032) iln(2)
        elseif(iln(1).eq.3) then
          write(iow,2033) iln(2)
        elseif(iln(1).eq.4) then
          write(iow,2034) iln(2)
        elseif(iln(1).eq.5) then
          write(iow,2035) iln(2)
        elseif(iln(1).eq.6) then
          write(iow,2036) iln(2)
        elseif(iln(1).eq.7) then
          write(iow,2037) iln(2)
        endif
      endif
      call plopen
      call plline(iln)
      go to 200

c     [mesh,k1] - plot mesh of current material number
c                 k1 < 0 alters mesh color

7     call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      call plopen
      call pppcol(4,1)
      if(cs.gt.0.0d0) call pppcol(1,1)
      call pline(hr(np(54)),mr(np(32)),mr(np(nix)),hr(np(61)),
     &           mr(np(62)),numnp,nne,3,nxd,nxn,nie,ct(1),tr)
      if(cs.ne.0.0d0) call pltime()
      go to 200

c     [outl,k1,k2] - Outline of 2-d meshes
c              k1  - 3-d outline
c              k2 < 0 alters line color

8     call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      call plopen
      call pppcol(5,1)
      if(ndm.eq.3) then
        write(*,*) ' **ERROR** No 3-d ouline'
      else
        call pline(hr(np(54)),mr(np(32)),mr(np(nix)),hr(np(61)),
     &             mr(np(62)),numnp,nne,3,nxd,nxn,nie,ct(2),fa)
      endif
      if(cs.ne.0.0d0) call pltime()
      go to 200

c     [load,,k1] - Plot load vector: k1 > 0 tip on node

9     call plopen
      call pppcol(3,1)
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      setvar = palloc(81,'TEMP1',numnp,1)
      call pnumna(mr(np(nix)),nxd,nxn,nne,mr(np(81)))
      k1 = ct(2)
      if(l.eq.9) then
        if(rlnew.eq.0.0d0) then
          dumv = 1.0d0
        else
          dumv = rlnew*prop
        endif
        setvar = palloc(82,'TEMP2',nneq,2)
        call pzero(hr(np(82)),nneq)
        call setfor(hr(np(27)),hr(np(28)),dumv,nneq, hr(np(82)))
        call pltfor(hr(np(54)),hr(np(82)),hr(np(45)),mr(np(31)),
     &              mr(np(81)),3,ndf,numnp,k1,1)
        setvar = palloc(82,'TEMP2',0,2)

c     [disp,,k1] - Plot displacement vector: k1 > 0 tip on node

      elseif(l.eq.10) then
        call pltfor(hr(np(54)),hr(np(40)),hr(np(45)),mr(np(31)),
     &              mr(np(81)),3,ndf,numnp,k1,2)
      endif
      setvar = palloc(81,'TEMP1',    0,1)
      call pltime()
      go to 200

c     Stress contours
c     [stre,k1,k2,k3] - k1 = component number (1-ndf) - Projected values
c     [pstr,k1,k2,k3] - k1 = component number (1-4)   - Principal values
c     [estr,k1,k2,k3] - k1 = component number (1-ndf)
c                       k2 = # lines (fill if <,= 0)
c                       k3 = 0: superpose mesh
c                       k3 > 0: no mesh

11    ipb = ct(3)
      setvar = palloc( 58,'NDNP',numnp*npstr,2)
      setvar = palloc( 57,'NDER',numnp*8    ,2)
      setvar = palloc( 60,'NSCR',numel      ,2)
      nph    = np(58)
      ner    = np(57)
      k1 = abs(ct(1))
      k2 = ct(2)
      nty= nph + numnp
      ntz= ner + numnp
      k5 = 1
      if(.not.fl(11)) then
        call pjstrs(trifl)
      endif
      if(l.eq.11) then
        k1 = min(npstr-1,max(k1,1))
        ntz= nty + numnp*(k1 - 1)
        k5 = 1
      elseif(l.eq.32) then
        k1 = min(npstr-1,max(k1,1))
        ntz= nty + numnp*(k1 - 1)
        k5 = 1
      elseif(l.eq.33) then
        k1 = min(7,max(k1,1))
        ntz= ntz + numnp*(k1-1)
        k5 = 5
      endif
      call rprint(hr(ntz),1,k2)
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      if(k2.le.0) then
        k2 = -k1
      endif
      k3 = 1

c     No projection case

      if(l.eq.32) then
        if(.not.hide) then
          setvar = palloc(81,'TEMP1',numel*nen,2)
          call pltelc(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &                hr(nph),hr(nph+numnp),hr(np(81)),
     &                nie,3,k3,nxd,k3,k2,k1,k5,labl)
          setvar = palloc(81,'TEMP1',0,2)
          fl(11) = fa
        endif
      else
        call pltcon(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &              hr(ntz),nie,3,k3,nxd,k3,k2,k1,k5,labl)
        fl(11) = tr
      endif
      call pltime()
      go to 200

c     [node,k1,k2] - Plot nodes k1 to k2 & numbers
c                               k1 = 0 show all nodes & numbers
c                               k1 < 0 show all nodes, no numbers

12    call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      setvar = palloc(81,'TEMP1',numnp,1)
      call pnumna(mr(np(nix)),nxd,nxn,nne,mr(np(81)))
      call plopen
      call pppcol(5,1)
      k4 = ct(1)
      if(k4.lt.0) then
        k1 = 0
        k2 = 1
        k3 = numnp
      elseif(k4.eq.0) then
        k1 = 1
        k2 = 1
        k3 = numnp
      else
        k1 = 1
        k2 = max( 1,min(numnp,int(ct(1))))
        k3 = max(k2,min(numnp,int(ct(2))))
        call pppcol(7,1)
      endif
      call pltnod(hr(np(54)),mr(np(81)),  3,k1,k2,k3)
      setvar = palloc(81,'TEMP1',    0,1)
      go to 200

c     [boun,k1] - Plot/label boundary restraints; k1 > 0

13    call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      setvar = palloc(81,'TEMP1',numnp,1)
      call pnumna(mr(np(33)),nen1,nen,numel,mr(np(81)))
      call plopen
      call pppcol(2,1)
      k1 = ct(1)
      call pltbou(mr(np(31)),hr(np(54)),hr(np(45)),mr(np(81)),
     &            3,ndf,numnp,k1)
      setvar = palloc(81,'TEMP1',    0,1)
      go to 200

c     [elem],n1,n2 - Label elements with numbers n1 to n2 (default = all)

14    call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      call plopen
      call pppcol(3,1)
      if(int(ct(1)).eq.0) then
        k2 = 1
        k3 = nne
      else
        k2 = max( 1,min(nne,int(ct(1))))
        k3 = max(k2,min(nne,int(ct(2))))
      endif
      call pltelm(hr(np(54)),mr(np(32)),mr(np(nix)),scale,nie,3,
     &            nxd,k2,k3)
      go to 200

c     [zoom,k1,k2] Set window for zoom; k1 = 1st node; k2 = 2nd node

15    nzm1 = ct(1)
      nzm2 = ct(2)
      fwin = .false.
151   call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))

c     Construct perspective projection if necessary

      if(kpers.ne.0) then
        call frame(hr(np(54)),  3,numnp,-1)
        call perspj(hr(np(54)),mr(np(49)),numnp,errv)
        if(errv) kpers = 0
      else
        call frame(hr(np(54)),  3,numnp,1)
      endif
      go to 200

c     [colo,k1,k2] - set color
c                    k1 <  0  greyscale postscript
c                    k1 >= 0  color postscript
c                    k2 =  0  standard color order
c                    k2 != 0  reversed color order

16    icol = ct(1)
      if(ct(1).lt.0.0d0) then
        if(ior.lt.0) write(*,*) 'PostScript - grayscale'
        pscolr = .false.
        psrevs = .false.
        icol   = 1
      else
        pscolr = .true.
        psrevs = ct(2).ne.0.0d0
        if(ior.lt.0. .and. psrevs) then
          write(*,*) 'PostScript - color order reversed'
        elseif(ior.lt.0) then
          write(*,*) 'PostScript - normal color order'
        endif
      endif
      call plopen
      call pppcol(icol,1)
      go to 200

c     [fill,k1],<k2> - fill current material in color 'k1'
c                    - no 'Time =' displayed if 'k2' non-zero.

17    call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      k1 = ct(1)
      k3 = ct(3)
      call plopen
      call plot2d(mr(np(32)),mr(np(nix)),mr(np(62)),hr(np(54)),
     &            hr(np(44)),nie,3,nxn,nxd,nne,k1,k3)
      if(cs.ne.0.0d0 .and. ct(2).eq.0.0d0) call pltime()
      go to 200

c     [eigv,k1,k2,k3] - Plot eigenvector for value 'k1' and material 'k2'
c                       k2 = 0 for all materials. k3-dof

18    k1 = max(1,min(mq,int(abs(ct(1)))))

c     Place value on screen

      call pleigt(hr(np(76)+k1-1))

c     Compute current deformed state of coordinates

      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))

c     Add unit scaled eigenvector to deformed coordinates

      setvar = palloc(81,'TEMP1',nneq,2)
      call pmovec(mr(np(31)),hr(np(77)+(k1-1)*neq), hr(np(81)),
     &            nneq)
      call scalev(hr(np(81)),pdf,ndm,ndf,numnp)
      call pdefm(hr(np(54)),hr(np(81)),es,hr(np(45)),3,ndf,numnp,
     &           hr(np(54)))

      if(kpers.gt.0 .and. hide) then
        dumv = 0.0d0
        call phide(dumv,nix,nxd,nxn,nne,nface,iln)
      endif

      i = abs(ct(3))
      if(i.eq.0) then
        call plopen
        if(kpers.gt.0 .and. hide) then
          k1 = ct(1)
          k4 = 1
          call plot2d(mr(np(32)),mr(np(nix)),mr(np(62)),hr(np(54)),
     &                hr(np(44)),nie,3,nxn,nxd,nne,k1,k4)
        else
          call pppcol(1,1)
          call pline(hr(np(54)),mr(np(32)),mr(np(nix)),hr(np(61)),
     &               mr(np(62)),numnp,nne,3,nxd,nxn,nie,ct(2),tr)
        endif
      else
        i  = min(i,ndf)
        k2 = ct(2)
        n  = abs(k2)
        ipb = 0
        if(ct(3).lt.0.0d0) ipb = 1
        if(k2.le.0) then
          n = -i
        endif
        nty = np(81)
        icp = ndf
        call rprint(hr(nty+i-1),icp,k4)
        call pltcon(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &              hr(nty),nie,3,icp,nxd,i,n,i,2,labl)
      endif
      setvar = palloc(81,'TEMP1',0,2)
      go to 200

c     [scal,cs,c2,c3] - Rescale for deformed window

19    nzm1 = 0
      nzm2 = 0
      jj   = 2
      cs   = ct(1)
      if(cs.eq.0.0d0) cs = 1.0
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      if(ct(2).eq.0.0d0) call pwind(hr(np(43)),hr(np(54)),ndm,3,numnp)
      if(ct(3).eq.0.0d0) jj = 1

c     Construct perspective projection if necessary

      if(kpers.ne.0) then
        call frame(hr(np(54)),  3,numnp,-jj)
        call perspj(hr(np(54)),mr(np(49)),numnp,errv)
        if(errv) kpers = 0
      else
        call frame(hr(np(54)),  3,numnp,jj)
      endif
      go to 200

c     [axis,x,y] - Plot axes at screen coords x,y

20    xm = 0.1*max(xmax(1)-xmin(1),xmax(2)-xmin(2),xmax(3)-xmin(3))
      call plopen
      call pppcol(1,1)
      if(kpers.eq.0) then
        k1 = ndm
      else
        k1 = 3
      endif
      call pltaxs(ct,k1,xm)
      go to 200

c     [pers] Input parameters for perspective projection
c     [pers,on,zview] - zview = ??

21    call plopen
      kpers   = 1
      odefalt = defalt
      defalt  = defalt .and. ct(1).eq.0.0d0
      zview   = ct(2)
      call pppcol(5,1)
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      call maxcor(hr(np(54)),  3,numnp)
      call perspe(pflag)
      call frame(hr(np(54)),  3,numnp,-1)
      call perspj(hr(np(54)),mr(np(49)),numnp,errv)
      defalt = odefalt
      if(errv) then
        kpers = 0
        go to 200
      endif
      nix   = 33
      nxd   = nen1
      nxn   = nen
      nne   = numel
      nfac  = nne
      call psetip(mr(np(62)),nne)
      if(.not.pflag) go to 22
      go to 200

c     [hide,nopl,back,color] Plot visible mesh

22    call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      hide  = tr
      pflag = tr
      if(l.eq.22) then
        call plopen
        call pppcol(4,0)
        if(ct(1).lt. 0.0d0) call pppcol(1,0)
        if(ct(1).lt.-1.0d0) call pppcol(0,0)
        k1 = ct(3)
        if(k1.gt.0) call pppcol(k1,0)
      else
        call pppcol(-1,0)
      endif

c     Set plot mesh quantities

      dumv = ct(2)
      call phide(dumv,nix,nxd,nxn,nne,nface,iln)

      go to 200

c     [defo,scale,resize,escale]
c           scale  = multiplier on displacements (default=1)
c           resize = non-zero: do not rescale plot region
c           escale = multiplier on eigenvectors  (default=1)

23    cs = ct(1)
      es = ct(3)
      if(max(cs,es).eq.0.0d0) cs = 1.d0

      if(ior.lt.0) write(*,2011) cs,es
      if(ct(2).eq.0.0d0) go to 151
      if(ior.lt.0) write(*,2013)

      go to 200

c     [unde,,resize,escale]; do not rescale if resize is non-zero

24    cs = 0.0d0
      if(ior.lt.0) write(*,2012) es

      es = ct(3)

      if(ct(2).eq.0.0d0) go to 151
      if(ior.lt.0) write(*,2013)

      go to 200

c     [cont,k1,k2,k3] - k1 = component number (1-ndf)
c                       k2 = # lines (fill if <,= 0)
c                       k3 = 0: superpose mesh
c                       k3 > 0: no mesh

25    k2  = ct(2)
      ipb = ct(3)
      n   = abs(k2)
      n   = max(1,n)
      i   = max(1,abs(int(ct(1))))
      i   = min(i,ndf)
      if(k2.le.0) then
        n = -i
      endif
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      setvar = palloc(81,'TEMP1',nneq,2)

c     Contours of dependent variables

      if(l.eq.25) then
        call protv(mr(np(49)),hr(np(40)),hr(np(45)),ndm,ndf,numnp,
     &             hr(np(81)))
        nty = np(81)
        icp = ndf
        call rprint(hr(nty+i-1),icp,k4)
        call pltcon(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &              hr(nty),nie,3,icp,nxd,i,n,i,2,labl)

c     [velo,k1,k2,k3]

      elseif(l.eq.26) then
        if(fl(9)) then
          call protv(mr(np(49)),hr(np(42)),hr(np(45)),ndm,ndf,numnp,
     &               hr(np(81)))
          nty = np(81)
          icp = ndf
          call rprint(hr(nty+i-1),icp,k4)
          call pltcon(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &                hr(nty),nie,3,icp,nxd,i,n,i,3,labl)
        else
          if(ior.gt.0) then
            write(iow,*) ' **WARNING** Not transient problem'
          else
            write(  *,*) ' **WARNING** Not transient problem'
          endif
        endif

c     [acce,k1,k2,k3]

      elseif(l.eq.27) then
        if(fl(9)) then
          call protv(mr(np(49)),hr(np(42)+nneq),hr(np(45)),ndm,ndf,
     &               numnp,hr(np(81)))
          nty = np(81)
          icp = ndf
          call rprint(hr(nty+i-1),icp,k4)
          call pltcon(hr(np(54)),mr(np(32)),mr(np(nix)),mr(np(62)),
     &                hr(nty),nie,3,icp,nxd,i,n,i,4,labl)
        else
          if(ior.gt.0) then
            write(iow,*) ' **WARNING** Not transient problem'
          else
            write(  *,*) ' **WARNING** Not transient problem'
          endif
        endif
      endif
      setvar = palloc(81,'TEMP1',0,2)
      call pltime()
      go to 200

c     [post] or [post,1] (0=portrait mode, 1=landscape mode)
c            PostScript -  open or close file

28    if (.not. hdcpy) then

c       Open PostScript file, set hdcpy=.true.

        hdcpy = tr
        psfram = (ct(1) .ne. 0.0d0)
        hdlogo = (ct(2) .eq. 0.0d0)
        if(ct(3).ne.0.0d0) then
          ct(3) = min(1.0d0,max(0.1d0,ct(3)))
        else
          ct(3) = 1.0d0
        endif
        call fppsop(ct(3))
      else

c       Close PostScript file, set hdcpy=.false.

        call fpplcl()
        hdcpy = fa
      endif
      goto 200

c     [reac,,k2]  Plot nodal reactions; k2=non-zero gives tip at node

29    call plopen
      call pppcol(5,1)
      setvar = palloc(81,'TEMP1',numnp,1)
      call pnumna(mr(np(33)),nen1,nen,numel,mr(np(81)))
      k1 = ct(2)
      setvar = palloc(82,'TEMP2',nneq,2)
      call pzero(hr(np(82)),nneq)
      if(ct(1).lt.0.0d0) then
        call pload(mr(np(31)),hr(np(30)),hr(np(82)),prop*rlnew,tr)
      endif
      call formfe(np(40),np(82),np(82),np(82),
     &            fa,tr,tr,6,1,numel,1)
      call pdefm(hr(np(43)),hr(np(40)),cs,hr(np(45)),ndm,ndf,numnp,
     &           hr(np(54)))
      call pltfor(hr(np(54)),hr(np(82)),hr(np(45)),mr(np(31)),
     &            mr(np(81)),3,ndf,numnp,k1,-1)
      setvar = palloc(82,'TEMP2',    0,2)
      setvar = palloc(81,'TEMP1',    0,1)
      call pltime()
      goto 200

c     [mate,#] - Set material number for plots (reset projection flag if new)

30    k1    = maplt
      maplt = ct(1)
      maplt = max(0,min(maplt,nummat))
      if(maplt.ne.k1) fl(11) = .false.
      if(prnt) then
        if(ior.lt.0) then
          write(*,2014) maplt,.not.fl(11)
        else
          write(iow,2014) maplt,.not.fl(11)
        endif
      endif

c     Set element material number to all processed

      if(maplt.eq.0) then

c       Set normal material numbers to zero value

        do i = 0,numel-1
          mr(np(91)+i) = 0
        end do

c     Set element material numbers so only 'maplt' is processed

      else

        k1 = 0
        do i = nen1-1,nen1*numel-1,nen1
          if(mr(np(33)+i).eq.maplt) then
            mr(np(91)+k1) =  0
          else
            mr(np(91)+k1) = -1
          endif
          k1 = k1 + 1
        end do

      endif

      call plfacn(mr(np(33)),mr(np(91)),nen,
     &            numel,nface,mr(np(32)),nie)
      if(nface.gt.nfaco) then
        setvar = palloc( 55,'FCIX ',7*max(nface,1),1)
        nfaco  = nface
      endif
      call pzeroi(mr(np(55)),7*nface)
      call plfacx(mr(np(33)),mr(np(91)),mr(np(55)),
     &            nen,numel,mr(np(32)),nie)
      if(max(nface,numel).gt.max(nfaco,numel)) then
        setvar = palloc( 56,'FCZM ',max(nface,numel),2)
        setvar = palloc( 62,'SYMM ',max(nface,numel),1)
      endif
      call psetip(mr(np(62)),  max(nface,numel))

      if(hide) go to 22

      go to 200

c     [dofs,k1,k2,k3] - Reset degree-of-freedoms for deformed plots

31    do i = 1,3
        pdf(i) = ct(i)
      end do

      write(iow,2017) pdf
      if(ior.lt.0) write(*,2017) pdf

      go to 200

c     [prom]pt,<on,off> - Set graphics prompt level

34    if(pcomp(tx(2),'off',3) .or. ct(1).eq.1.d0) then
        prompt = .false.
      else
        prompt = .true.
      endif
      go to 200

c     [defa]ult,<on,off> - Set graphics defaults

35    if(pcomp(tx(2),'off',3) .or. ct(1).eq.1.d0) then
        defalt = .false.
      else
        defalt = .true.
      endif
      go to 200

c     [rang]e,,min,max - range for fill plots

36    if(pcomp(tx(2),'off',3)) then
        rangfl = .false.
        if(iow.lt.0) write(*,2008)
      else
        rangfl = .true.
        rangmn = min(ct(1),ct(2))
        rangmx = max(ct(1),ct(2))
        if(iow.lt.0) write(*,2009) rangmn,rangmx
      endif
      go to 200

c     [nora]nge - off

37    rangfl = .false.
      if(iow.lt.0) write(*,2008)
      go to 200
c     [manu]al,,hlplev - Set manual help display level

38    hlplev = max(-1,min(3,nint(ct(1))))
      go to 200

c     [uplo]t - ct: User plots

39    call plopen
      call pppcol(1,0)
      call uplot(ct)
      go to 200

c     User plot option library

800   k4 = l + 5 - list
      call plopen
      call pppcol(1,0)
      call upltlib(k4,ct(1),prt)
      go to 200

c     Close plot

200   call plclos
      if(ijump.ne.0) go to 60

      setvar = palloc( 54, 'CT   ', 0, 2)
      return

c     Formats

2001  format(' ** WARNING: no match on a plot,',a4,' request.')

2003  format(' Input PLOT instructions, use "help" for a list,',
     &       ' exit with "end".')
2004  format('     Plot ',i3,'> ',$)

2006  format(5x,'Cartesian view')

2007  format(5x,'Perspective view')

2008  format('  Range: Automatic (off)')

2009  format('  Range: Min =',1p,1e12.4,', Max =',1p,1e12.4)

2010  format(' P>', $)

2011  format('  -> Plots on deformed mesh with scale:',1p,e12.5/
     &       '                     Eigenvector scale:',1p,e12.5)

2012  format('  -> Plots on undeformed mesh:',
     &       ' Eigenvector scale:',1p,e12.5)

2013  format('     No rescale for plot.')

2014  format('     Plot results for material number',i3,' Project = ',
     &       l2/'          (0 - for all materials)')

2017  format('  Plot degree-of-freedoms reassigned to:',
     &       ' 1 =',i2,': 2 =',i2,': 3 =',i2/1x)

2030  format('  Line type 0: Solid          ; Width =',i3)
2031  format('  Line type 1: Dotted         ; Width =',i3)
2032  format('  Line type 2: Dash-dot       ; Width =',i3)
2033  format('  Line type 3: Short-dash     ; Width =',i3)
2034  format('  Line type 4: Long-dash      ; Width =',i3)
2035  format('  Line type 5: Dot-dot-dash   ; Width =',i3)
2036  format('  Line type 6: Short+long dash; Width =',i3)
2037  format('  Line type 7: wide dash      ; Width =',i3)

      end
