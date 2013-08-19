%{

/* ATTENTION - this is the glitch factor to adjust, it doesn't take much! */
/* Here's a default value, but it can be changed via the command line  */
double glitch_factor = 0.01;
const double epsilon = 0.00001; /* a change which is too small to notice */
 
 
%}

%Start D_DATA QUOTED_DATA
%%
<D_DATA>[A-Z_a-z][-A-Z_a-z.0-9]*	ECHO;
<D_DATA>[0-9]+("."[0-9]+)?			glitchNumber();
<D_DATA>\"							{ ECHO; BEGIN 0; }
<D_DATA>[ \t]+						ECHO;
<D_DATA>","							ECHO;
<D_DATA>.							ECHO;
<QUOTED_DATA>[A-Z_a-z][-A-Z_a-z.0-9]*	ECHO;
<QUOTED_DATA>\"							{ ECHO; BEGIN 0; }
<QUOTED_DATA>.							ECHO;
"d=\""						{ ECHO; BEGIN D_DATA; }
\"							{ ECHO; BEGIN QUOTED_DATA; }
[ \t]+						ECHO;
[<>?/]						ECHO;
[A-Z_a-z][-A-Z_a-z.0-9]*	ECHO;
.							ECHO;
"\n"						ECHO;
%%

/* replace library yywrap()-there is no need to append files, so this will do */
int yywrap()  
{  
	return(1);  
}  

/* replace libraries main(), so that command line parameters can be retrieved */
int main(int argc, char *argv[])  
{  
	if (argc > 1) { /* look for a glitch factor */
		double numb = strtod(argv[1], NULL);
		if (-epsilon < numb && numb < epsilon) {
			fprintf(stderr, "the command line parameter \'%s\', should be a decimal number larger than %f\n",
							argv[1], epsilon);
			exit(1);
		}
		glitch_factor = numb;
	}
	
	while (yylex())  
	   ;  
} 

/* helper functions for debugging and transformation */
extern int shmush(int c);
extern int glitchNumber();  


/* output a string as a single specific character to help debugging */
int shmush(int c) { int i; for (i=0; i<yyleng; ++i) putchar(c); }

int glitchNumber() {
	char *endptr;
	double numb = strtod(yytext, &endptr);
	if (endptr == &yytext[0]) {
		fprintf(stderr, "** ERROR **: GB has made mistake 1, ");
		fprintf(stderr, "tried to convert a double, but it isn't a number\n");
		fprintf(stderr, "    called strtod(\"%s\"), not a number?\n", yytext);
		exit(1);
	}
	
	/* convert the random number to somehing in the range -1.0 to +1.0 */
	double r = ((double)(random()-0x3FFFFFFFL))/(double)0x3FFFFFFFL;
	
	r *= glitch_factor; 
	
	double glitched = numb + (numb * r); 

	if (r < -1.0 || 1.0 < r ) { 
		fprintf(stderr, "** ERROR **: GB has made mistake 2, ");
		fprintf(stderr, "the random number used to glitch coordinates is out of range\n");
		fprintf(stderr, "    r should be within +/-1, but r=%f\n", r);
	}
#ifdef DEBUG
	fprintf(stderr, " {svg font coordinate=%s, r=%f glitched=%f} ", yytext, r, glitched);	
#endif

#ifdef DEBUG
    printf("%s", yytext);	/* don't change it, to make testing easy */
#else
	printf("%f", glitched);
#endif
}

