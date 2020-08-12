load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;Written by Patrick C. Campbell (Patrick.C.Campbell@noaa.gov)

;*****************************************************************
; Read source files and lat/lon for regridding
;*****************************************************************

;---Read the source and destination lat/lon grids 
    srcFileName = getenv("srcfile") 
    dstFileName = getenv("dstfile")

;---Read the weight file name
    wgtFileName = getenv("wgtfile")

;---Read input and write to  the regridded output filename
    inFileName  = getenv("infile")
    outFileName = getenv("outfile")

    sfile = addfile(srcFileName,"r") 
    dfile = addfile(dstFileName,"r") 
    ifile = addfile(inFileName,"r")
    ofile = addfile(outFileName,"c")

    src_lat = sfile->lat
    src_lon = sfile->lon
    dst_lat = dfile->grid_latt
    dst_lon = dfile->grid_lont

;*****************************************************************
; Read data for regridding
;*****************************************************************

;---Get names of all variables on file 
    vNames = getfilevarnames (ifile)
    nNames = dimsizes (vNames)    
;---Loop through and read the data you want to regrid
    do n=0,nNames-1
    	v = ifile->$vNames(n)$
        rank=(dimsizes(dimsizes(v)))
 
     if (rank .ge. 2) then  ;must be two-dimensional

;*****************************************************************
; Set options for regridding
;*****************************************************************

    	Opt = True 
	;---source grid information 
    	Opt@SrcRegional = True 
    	Opt@SrcGridLat = src_lat 
    	Opt@SrcGridLon = src_lon 
	;---destination grid information 
    	Opt@DstRegional = True 
    	Opt@DstGridLat = dst_lat 
    	Opt@DstGridLon = dst_lon
    
    	Opt@ForceOverwrite = True 
    	Opt@CopyVarCoords = True ; Whether to copy coordinate information 
                                 ; to regridded variable 
    	Opt@InterpMethod = "conserve" ; (default) "patch" or "conserve" 
    	Opt@WgtFileName    = wgtFileName

;*****************************************************************
; Check / create weight files for regridding, and then regrid
;*****************************************************************

    	exists=isfilepresent(wgtFileName)
    	if( .not. exists ) then
     		print("creating weight file and regridding..."+vNames(n))
     		vregrid = ESMF_regrid(v,Opt) 
    	else 
     		print("weight file exists. Regridding..."+vNames(n))
     		vregrid = ESMF_regrid_with_weights(v,wgtFileName,Opt)
    	end if
  
;*****************************************************************
; Write regridded variables to output file
;*****************************************************************
     	dimNames=getvardims(v)
        if (rank .eq. 2) then
        vregrid!0=dimNames(0)
        vregrid!1=dimNames(1)
        end if
        if (rank .eq. 3) then
        vregrid!1=dimNames(1)
        vregrid!2=dimNames(2)
        end if
        if (rank .eq. 4) then
        vregrid!2=dimNames(2)
        vregrid!3=dimNames(3)
        end if
     	delete_VarAtts(vregrid,(/"lat2d","lon2d"/))
        ofile->$vNames(n)$=vregrid     
        delete(dimNames)
        delete(vregrid)
     end if
        delete(v)
     end do
end 
