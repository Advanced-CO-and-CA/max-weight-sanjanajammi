


/******************************************************************************
* File: max-weight-implementation_alternate.s
* Author: Sanjana Jammi
* Roll number: CS18M522
* TA: G S Nitesh Narayana
* Guide: Prof. Madhumutyam IITM, PACE
******************************************************************************/

/*
  Assignment 3 - To find the number with the max weight
  Algorithm used - Efficient method to find the Hamming weight of a number and uses 17 arithmetic operations (works without Mul instruction)
  This method is better for processors with slow MUL operations
  Reference: https://en.wikipedia.org/wiki/Hamming_weight
  
  Pseudo Code:
  int hammingWt_32bit(uint32_t x){
		x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
		x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits 
		x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits 
		x += x >>  8;  //put count of each 16 bits into their lowest 8 bits
		x += x >> 16;  //put count of each 32 bits into their lowest 8 bits
		return x & 0x7f;
	}
  */

  @ BSS section
      .bss

  @ DATA SECTION
      .data
data_start: .word 0x205A15E3
            .word 0x256C8700
			.word 0x295468F2
data_end:   .word 0
length: .word (data_end - data_start)/4

m1: .word 0x55555555;
m2: .word 0x33333333;
m4: .word 0xf0f0f0f;
h01: .word 0x0000007f;

num: .word 0;
weight: .word 0;
        

  @ TEXT section
      .text

.globl _main


_main:
	   EOR r2, r2, r2;         @ register r2 to hold max weight, initialized to 0
	   EOR r1, r1, r1;         @ register r1 to hold number with the max weight, initialized to 0
	   
	   
	   LDR r4, =length;        @ load length, if length is 0, stop execution
	   LDR r0, [r4];           @ using r0 as a counter	
	   
	   CMP r0, #0;
	   BEQ done;	           @ break if there are no elements i.e. length is 0
	   
	   LDR r4, =m1;            @ loading these predefined values upfront to avoid memory reads for each element
	   LDR r7, [r4];           @ read value of m1
	   
	   LDR r4, =m2;            @ read value of m2
	   LDR r8, [r4];
	   
	   LDR r4, =m4;            @ read value of m4
	   LDR r9, [r4];
	   
	   LDR r4, =h01;           @ read value of h01
	   LDR r10, [r4];
	   
	   LDR r4, =data_start;    @ load data_start starting address into register r4
	   
	   
loop:  LDR r3, [r4], #4;       @ Looping through all the elements in the list, register r3 holds the number read
	   EOR r5, r5, r5;         @ Register r5 to hold the partially computed weight
	   	   	  
	   AND r5, r7, r3, LSR #1; @ x -= (x >> 1) & m1
	   SUB r5, r3, r5;         @ put count of each 2 bits into those 2 bits
	   	  
	   EOR r6, r6, r6;         @ x = (x & m2) + ((x >> 2) & m2)	
	   AND r6, r8, r5, LSR #2; @ Register r6 holds intermediate results
	   AND r5, r5, r8;
	   ADD r5, r5, r6;         @ put count of each 4 bits into those 4 bits 
	   
	   ADD r5, r5, r5, LSR #4; @ x = (x + (x >> 4)) & m4   	  	  
	   AND r5, r5, r9;        
	   
	   ADD r5, r5, r5, LSR #8; @ x += x >>  8, put count of each 16 bits into their lowest 8 bits
	   ADD r5, r5, r5, LSR #16;@ x += x >> 16, put count of each 32 bits into their lowest 8 bits
	   	   	 
	   AND r5, r5, r10;        @ Lower order 8 bits has the count
	   
	   CMP r5, r2;             @ Compare with the current max weight
	   BMI continue;           @ Proceed if the count is lesser than the current max weight
	   
	   MOV r2, r5;             @ Set current element as the max value if it is greater than the existing max element
	   MOV r1, r3;	           @ Set current element as the element with the max weight
	   
continue: SUBS r0, r0, #1;	   @ Decrement counter
	   BNE loop;	           @ Repeat till counter comes to 0
	   
       
done:  LDR r4, =num;           @ Stop the pgm, store results in memory
	   STR r1, [r4];
	   LDR r4, =weight;
	   STR r2, [r4];	   	   
