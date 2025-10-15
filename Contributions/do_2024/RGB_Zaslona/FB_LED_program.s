# This program uses the instructions defined in the
# basic_microcode.def file. It counts down to 0 from 2
# and stores -1 in memory location 16.
# (c) GPL3 Warren Toomey, 2012
#
main:	li r1, 0x7ffe
		li r2, 0x1818
		
		sw r1, 0x2002
		sw r2, 0x2005
		sw r2, 0x2006
		sw r2, 0x2007
		sw r2, 0x2008
		sw r2, 0x2009
		sw r2, 0x200a
		sw r2, 0x200b
		sw r2, 0x200c

		

		
		
		


