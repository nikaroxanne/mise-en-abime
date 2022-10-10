###############################################################################
#			Makefile for Quines
#	A project inspired by Ken Thompson's "Reflections on Trusting Trust"
#	and the Jean Paul Belmondo-esque perpetual cool of Brian Kernighan
#	Each source file is compiled using gcc, with one of four possible options
#		1. No optimization
#		2. O1 optimization
#		3. O2 optimization
#		4. O3 optimization
#
#	all  		- (default) compile all c files in directory
# 	clean  		- clean up compiled object files and executable files
#	
#
###############################################################################

EXECUTABLES = quine 
SOURCE_FILES = quine.c 


GCC = gcc

FLAGS= -g -O -Wall -Wextra -Werror -Wfatal-errors -std=c99

LIBS= -lm

###############################################################################
##############################################################################
#
#
#
###############################################################################

all: $(EXECUTABLES)


###############################################################################

clean: 
	rm -f *.o 

###############################################################################

quine.o: quine.c
	$(GCC) $(FLAGS) -c quine.c

quine: quine.o
	$(GCC) $(FLAGS) -o quine $< $(LIBS)

