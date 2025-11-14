1. **@testing unconditionals with no set flags and no jumps**

2. **@testing setting flags and conditionals**

3. **@testing jumps**

4. **@testing jumps with instructions after jump command**

5. **@testing conditional jumps**

6. **@testing jump to register**

7. **@testing jump to subroutine and return**

8. **@testing `ldr` with `[rs]`, `[rs, rt]` and `[rs, immed]`**

9. **@testing conditional execution stall vs plain**

10. **@cycle times are written for zaklenitev version, no `nop` commands needed**

11. **@testing operand forwarding**

12. **@testing how delays occur for jumping instructions in op forwarding version**

13. **@testing predictions**

14. **1bit:**  
    - @testing prediction tables

15. **2bits:**  
    - @testing 2-bit prediction table, only 1 wrong prediction per loop  
    - @exception: when at start of program and starting in 00 state

16. **corr:**  
    - @testing correlating predictor  
    - @sometimes 2 branches can take up the same spot in our local prediction table  
    - @because we use a 3-bit addressed LPT, this happens if 2 instructions separated by 8 addresses are both branches

16. **corr_lht:**  
    - @testing correlating predictor  
    - @sometimes 2 branches can take up the same spot in our local prediction table  
    - @because we use a 3-bit addressed LPT, this happens if 2 instructions separated by 8 addresses are both branches

17. **tournament:**  
    - @testing tournament predictor  
    - @correlating predictor is not always better than a standard 2-bit predictor  
    - @Sometimes, unrelated jumps may affect the correlating predictor and make predictions worse.  
    - @To account for that, we use a tournament predictor that dynamically chooses whether to predict using  
      local history (as a correlating predictor) or global history (2-bit predictor)  
    - @We'll take the same code as with our correlating predictor, but expand it with an extra jump

18. **stall vs forwarding:**  
    - @This example is taken from the HiP lecture example and is meant to showcase the difference between stall and forwarding

19. **1bit vs 2bits:**  
    - @This is a revised example showing the efficiency of a 2-bit predictor over a 1-bit predictor  
    - Using 1-bit predictor: **50/100 predictions are incorrect**  
      - This makes sense, as a 1-bit predictor is wrong on loop enter and loop exit, and since loops alternate, it is wrong half the time  
    - Using 2-bit predictor: **25/100 predictions are incorrect**  
      - We increased prediction efficiency by half!
