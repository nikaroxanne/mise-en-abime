#!/usr/bin/python

import re, sys, os
import argparse

#####################################################################
#	infect writes a malicious MBR to the disk image
#	created with bximage
#	
#	##Code based on the script from "Rootkits and Bootkits"(Page 213)
#	written by Alex Matrosov, Eugene Rodionov and Sergey Bratus
#
#####################################################################

def infect(mal_mbr, disk_img):
	with open(mal_mbr, 'rb') as mbr_file:
		mbr=mbr_file.read()
		with open(disk_img, "r+b") as disk_img_file:
			disk_img_file.seek(0)
			disk_img_file.write(mbr)
	return 0

def setup_options():
	parser = argparse.ArgumentParser(description='Infects a disk image with a malicious MBR; to be used for bootkit development/debugging/dynamic analysis')
	parser.add_argument('-mbr', type=str, help='path of malicious MBR file to be written to the target disk image')
	parser.add_argument('-diskimg', type=str, help='path of target disk image to be infected with the malicious MBR')
	args = parser.parse_args()
	return parser, args

if __name__ == '__main__':
	parser, args = setup_options()
	mal_mbr=args.mbr
	disk_img=args.diskimg
	infect(mal_mbr, disk_img)

