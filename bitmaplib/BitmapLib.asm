# BITMAPLIB
# A library for working with the MARS Bitmap Display tool. Open the Bitmap Display, and remember to
# actually attach it to MIPS, or you can't control it! Also, ensure you reserve memory for the display
# ahead of time. Otherwise, that memory will get overwritten.
#
# USAGE
# 



# A guard to prevent this library from running before the main function
beqz $ra, _bitmaplib_guard



# fillDisplay: Fill an area of the display with a certain colour
# Arguments:
#	a0: The address of the display's memory
#	a1: The area's width
#	a2: The area's height
#	a3: The colour to fill
fillDisplay:
	



# The file guard
_bitmaplib_guard: