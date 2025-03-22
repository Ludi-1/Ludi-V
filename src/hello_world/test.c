int function(int a, int b) {
  return a + b;
}

int main(){
  volatile char *ptr1 = (char *)0xFF;
  *ptr1 = 0xA;
  
  volatile char *ptr2 = (char *)0xFF;
  *ptr2 = 0xC;
  
  volatile char *ptr3 = (char *)0xAF;
  *ptr2 = *ptr1;

  volatile char *ptr4 = (char *)0xFF;
  *ptr3 = 0xD;

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
