int function(int a, int b) {
    return a + b;
}

int main(){
    volatile char *ptr = (char *)0xFF; // Pointer to memory address 255
    *ptr = 0xA; // Write ASCII 'A' (0x41) to address 255
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
