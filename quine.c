#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char* repeat(){
	char* quine[]={
		"#include <stdlib.h>\n\0",
		"#include <stdio.h>\n\0",
		"#include <string.h>\n\0",
		"\n\0",
		"char* repeat()\{\n\0",
		"for (unsigned long int i=0; i<sizeof(quine_elems); i++){\n\0",
		"\tprintf(\"%s\n\", *(&quine[i]));\n\0",
		"\tfor(unsigned long int j=0; j<(sizeof(**quine)); j++)\n\0",
		"\t\t{\n\0",
		"\t\t\tprintf(\"%d\", *(&quine[i][j]));\n\0",
		"\t\t};\n\0",
		"\treturn *quine;\n\0",
		"};\n\0",
		"void main(){\n\0",
		"\trepeat();\n\0",
		"};\n\0",
		"\0"
	};

//	unsigned long int quine_elems = sizeof(*quine)/sizeof(*(&quine[0]));
	unsigned long int quine_elems = sizeof(quine)/sizeof(char*);
//	printf("Number of strings: %lu", quine_elems);
//	unsigned long int quine_str_elems = sizeof(*(&quine[i]))/sizeof(char);


	for (unsigned long int i=0; i < quine_elems; i++){
		printf("Line: %lu %s\n", i, *(&quine[i]));
		//unsigned long int quine_str_elems =(sizeof(*(&quine[i])) / sizeof(*&(quine[i][0]));
		unsigned long int quine_str_elems = strlen(*(&quine[i]));
		for(unsigned long int j=0; j<(sizeof(quine_str_elems)); j++)
				{
					printf("%d\n", *(&quine[i][j]));
				};
				
	};
	return *quine;
}

int main(){
	char* new_quine = repeat();
	printf("First line of quine: %s", new_quine);
	return 0;
}
