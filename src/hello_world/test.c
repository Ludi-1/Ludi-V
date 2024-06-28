int function(int a, int b) {
    return a + b;
}

int main(){
    int a = 5;
    int b = 11;
    int c = function(a, b);
    return 0;
}

/*
 * Define the entry point of the program.
 */
__attribute__((section(".text.start")))
void _start(void)
{
	main();
}