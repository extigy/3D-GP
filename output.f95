module output
	use params
	use netcdf
	implicit none
	include 'netcdf.inc'
	integer :: ncdf_id,x_id,y_id,z_id,re_id,im_id,pot_id
	integer       :: icount(3)
	integer       :: istarting(3)

Contains

	subroutine make_file(fname)
		implicit none
		integer :: dims(3)
		integer :: r,x_dim_id,y_dim_id,z_dim_id
		character(len=80) fname
		r=NF90_create(fname , IOR(NF90_CLOBBER,NF90_64BIT_OFFSET), ncdf_id)
		r=NF90_def_dim(ncdf_id, 'x_dim', NX+1, x_dim_id)
		r=NF90_def_dim(ncdf_id, 'y_dim', NY+1, y_dim_id)
		r=NF90_def_dim(ncdf_id, 'z_dim', NZ+1, z_dim_id)

		r=NF90_def_var(ncdf_id, 'x', NF90_DOUBLE,x_dim_id, x_id)
		r=NF90_def_var(ncdf_id, 'y', NF90_DOUBLE,y_dim_id, y_id)
		r=NF90_def_var(ncdf_id, 'z', NF90_DOUBLE,z_dim_id, z_id)

		dims(1) = x_dim_id
		dims(2) = y_dim_id
		dims(3) = z_dim_id

		r=NF90_def_var(ncdf_id, 'real', NF90_DOUBLE, dims, re_id)
		r=NF90_def_var(ncdf_id, 'imag', NF90_DOUBLE, dims, im_id)
		r=NF90_def_var(ncdf_id, 'pot' , NF90_DOUBLE, dims, pot_id)

		r=NF90_enddef(ncdf_id)
		r=NF90_sync(ncdf_id)

	end subroutine


	subroutine write_wf_file()
		implicit none
		integer :: r,i
		istarting(1) = 1
		istarting(2) = 1
		istarting(3) = 1
		icount(1) = NX+1
		r=NF90_put_var(ncdf_id, x_id, (/(i*DSPACE,i=-NX/2,NX/2)/),istarting,icount)
		icount(1) = NY+1
		r=NF90_put_var(ncdf_id, y_id, (/(i*DSPACE,i=-NY/2,NY/2)/),istarting,icount)
		icount(1) = NZ+1
		r=NF90_put_var(ncdf_id, z_id, (/(i*DSPACE,i=-NZ/2,NZ/2)/),istarting,icount)

		icount(1) = NX+1
		icount(2) = NY+1
		icount(3) = NZ+1
		r=NF90_put_var(ncdf_id, re_id,    dble(GRID),istarting,icount)
		r=NF90_put_var(ncdf_id, im_id,   aimag(GRID),istarting,icount)
		r=NF90_put_var(ncdf_id, pot_id, DBLE(OBJPOT),istarting,icount)
	end subroutine

end module