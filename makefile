glitch: glitch.c
	gcc -o glitch glitch.c
	
debug: glitch.c
	gcc -DDEBUG -o glitch glitch.c
	
clean:
	rm glitch glitch.c

	
glitch.c: glitch.l
	flex -t glitch.l >glitch.c

