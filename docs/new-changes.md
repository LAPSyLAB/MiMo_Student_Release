# New Changes



## Changes to standard version (without anti-hazard additions)

### Changed circuit layout and appearance to be more similar to OR class sketch

<figure><img src=".gitbook/assets/image (15) (1).png" alt=""><figcaption><p>OR class sketch</p></figcaption></figure>

All of the stages are and their parts are now displayed on the main circuit and I have added "transition blocks" (like IF->ID, ID->EX), that store the data goign in and leaving a stage.



### Added Link Register

I added the Link register as a special register, outside of the Register Bank.&#x20;

It does not make sense to use one of the normal registers because the Write Back stage for normal registers happens at the end, and since branch with link is a branch instruction, it needs to happen immediately after decoding like the other branch/jump instructions.



<figure><img src=".gitbook/assets/temp (6).png" alt=""><figcaption><p>Link register</p></figcaption></figure>

I added 2 new microinstructions, **loadlink** and **strlink**.

When the first signal is active it saves the current IF stage address in the link register, the second stores the current Link register value inside the **immed** port of the IF stage, as pictured below.

<figure><img src=".gitbook/assets/image (9).png" alt=""><figcaption><p>Link register connection to IF stage</p></figcaption></figure>

I added **rts** as the 29th instruction to the assembler. This instruction is used to return from subroutine.

An example can be seen and tested in the **Assembler/tests/test7.txt** file.



### Added .data section to assembler

Added a **.data** section that outputs a second ram file for the operand RAM.

You first must declare **.data** then followed by the data you want to add. Afterwards, before declaring instructions, you must declare **.text** similar to standard ARM assembly.

<figure><img src=".gitbook/assets/image.png" alt=""><figcaption><p>Example .data section of code</p></figcaption></figure>

The **.word** directive declares words to be added to the operand RAM. They can be written as decimal or hexadecimal type.

The **.space** directive declares an amount of space(bytes) to be left empty in operand RAM.

The **.ascii** and **.asciiz** directives declare ascii strings to be added to the operand RAM. They are not aligned and take up as much space as needed. The only difference is **.asciiz** adds a terminating null character(empty byte) to each string.

The assembler.exe program now produces 2 files, an **.IRAM** file for the instruction RAM and a **.ORAM** file for the operand RAM.



### Added different formats for the ldr instruction

Changed assembler and microcode and added 2 new microcode entries to allow for different **ldr** notations:



* **ldr Rd, \[Rs]**
* **ldr Rd, \[Rs, Rt/immed]**
* **ldr Rd, immed**

This again brings us closer to more standard ARM assembly code.

<figure><img src=".gitbook/assets/image (1).png" alt=""><figcaption><p>Changes to microcode</p></figcaption></figure>

An example can be seen and tested in the **Assembler/tests/test8.txt** file.

#### All of the changes above have been implemented in mimo\_32bit\_v2.circ



## Pipeline Stall Version (mimo\_32bit\_v2.1)

The aim of this version is to show how an implementation with pipeline stalls works. The CPU detects when a Read-After-Write error is about to occur and stalls the pipeline accordingly to avoid it.&#x20;

I added a simple RAW-check circuit in the ID section.

<figure><img src=".gitbook/assets/image (2).png" alt=""><figcaption><p>RAW_Check sicruit</p></figcaption></figure>

The circuit checks whether any of the 3 previous instructions:

* Wrote to the register bank (**dwrite**=1)

A RAW error occurs when an instruction reads from the Register Bank before a instruction preceding it writes to it.

We check the previous 3 instructions because it takes 3 cycles and pipeline stages for an instruction to go from the ID stage to the end of the WB stage.&#x20;

* Their condition was met

If the condition of the previous instruction is not met, it can not write to the Register Bank and a RAW therefore can not occur.

* The **dsel** is equal to the current **ssel** or is equal to the current **tsel** while **imload**=0

The destination register of the previous instruction must be equal to one of he registers being used in the current instruction( tsel is only active when not using an immediate value).



The circuit produces the **stall** and **bubble** signals when a incoming RAW is detected.

The **stall** signal stops the **pcload** and **irload** signals, so that no new instruction is loaded into the IF or ID stage.

The **bubble** signal replaces all signals inside the **ID -> EX** intermediate circuit with zeros(bubbles), so that the previous instructions that were causing the RAW may travel through the pipeline until they are no longer a problem.

<figure><img src=".gitbook/assets/image (3).png" alt=""><figcaption><p>Bubble connection to avoid infinite loop</p></figcaption></figure>

The **bubble** signal is also connected to the shift registers that keep previous values of **Rd** and **cond\_met**. This is to ensure that when we encounter multiple RAWs one after another, an infinite loop doesn’t arise and a zero(bubble) is shifted into the shift register instead of the same value of the instruction.

An example can be seen and tested in the **Assembler/tests/test10.txt** file.



## Operand Forwarding Version (mimo\_32bit\_v2.2)

The aim of this version is to show how an implementation with operand forwarding works. The CPU detects when a Read-After-Write error is about to occur and forwards operands to the **ID->EX** transitional circuit.

I based it on the previous version **v2.1 – Zaklenitev**, but I changed multiple things.

<figure><img src=".gitbook/assets/image (4).png" alt=""><figcaption><p>Changes to RAW_Check curcuit</p></figcaption></figure>

The RAW checking circuit was changed to produce 2 signals. One to decide from what pipeline stage to forward **Rs** and one to decided from what pipeline stage to forward **Rt**.

It works on the following principle: If a RAW is detected in the first previous instruction, forward the operand from before the **EX -> MA** stage.

If no RAW is detected in the 1st previous instruction and a RAW is detected in the 2nd previous instruction, forward the operand from before the **MA -> WB** stage.

If no RAW is the detected in the 1st and 2nd previous instructions and a RAW is detected in the 3rd previous instruction, forward the operand from after the    **MA -> WB** stage.

If no RAW is detected at all, no operand forwarding is done.

<figure><img src=".gitbook/assets/image (5).png" alt=""><figcaption><p>Stall needed for ldr instruction</p></figcaption></figure>

**No stall cycles are needed for ALU operations** with this method, the only time when a stall is needed is when the 1st previous instruction is a **ldr** instruction and a RAW is detected. Because operand memory access occurs in the 4th stage (MA), we do not know the value to be loaded inside the register to use in the EX stage, so we must stall one cycle to know the value.

<figure><img src=".gitbook/assets/image (6).png" alt=""><figcaption><p>Wiring to determine register source for forwarding</p></figcaption></figure>

We determine what value (**operand, immed, sreg, aluout**) to forward to the next EX stage by looking at that instruction's **regsrc** signal.

If a RAW was detected in the 1st previous instruction, we take that instruction’s **regsrc** signal (**prevRegsrc**) to determine what value to forward. If it was detected in the 2nd previous instruction, **prevRegsrc1** is used, and if it was detected in the 3rd previous instruction, that means the operands are exiting the **MA->WB** transition block but haven't been written to the Register Bank yet, so we take the natural **regsrc** signal.&#x20;

<figure><img src=".gitbook/assets/image (7).png" alt=""><figcaption><p>Forwarding circuitry inside the ID->EX transition block</p></figcaption></figure>

Inside the **ID -> EX** stage, the value to be loaded into the next EX stage is determined by the **sselforward** and **tselforward** signals produced by the **RAW\_Check** circuit.



<figure><img src=".gitbook/assets/temp.png" alt=""><figcaption><p>Flag forwarding</p></figcaption></figure>

We also forward the flags whenever a flag setting signal is activated the previous instruction, as if we do not do this, we would need to stall one cycle for the proper flags to be loaded into their registers.

An example can be seen and tested in the **Assembler/tests/test11.txt** file.

## Predictions Version (mimo\_32bit\_V2.3.2)

The aim of this version is to present an implementation using prediction methods to mitigate delays because of branches.&#x20;

The model is based on **v2.2 - Premoscanje** and builds upon it.

To implement predictions in our CPU model it only made sense to make the predictions in the IF stage, since naturally we already now the result of the prediction in the ID stage (since we are using **conditions based on** **flags already set**), so we only lose 1 cycle for every jump naturally. With predictions we want to minimize that to 0 cycles lost as often as possible.

Firstly we underline the mechanisms and changes needed for predicting and missing predictions.

<figure><img src=".gitbook/assets/image (10).png" alt=""><figcaption><p>circuitry checking if is branch/jump</p></figcaption></figure>

In the IF stage after accessing the RAM, we check whether the instruction is a jump/branch which decides whether we should initialize predictions for that instruction.

We also run it through a register once to know next cycle if the previous instruction was predicted or not.

<figure><img src=".gitbook/assets/image (11).png" alt=""><figcaption><p>circuitry checking if unconditional branch</p></figcaption></figure>

We also check if it a unconditional branch/jump, since if it is, the branch will always be taken.

<figure><img src=".gitbook/assets/image (12).png" alt=""><figcaption><p>prediction</p></figcaption></figure>

After this we run the instruction through our desired prediction method (described later) and get our prediction. We also run it through a register to know what our prediction was next cycle.

Then, if we predicted a jump, we need to change the **pcsel** for the next fetch.

<figure><img src=".gitbook/assets/image (13).png" alt=""><figcaption><p>Changes to pcsel needed for prediction</p></figcaption></figure>

If we conclude that we should predict (**should\_predict**) and if **we did not predict a jump**, the **pcsel** is set to 0 (PC = PC+1), **if we predicted a jump**, the **pcsel** is set to **pcsel1** which is derived from the instruction being processed, explained bellow.

<figure><img src=".gitbook/assets/image (14).png" alt=""><figcaption><p>circuitry checking if branch command and saving pcsel of branch or jump for prediction</p></figcaption></figure>

Since if it is a branch or if it is a jump, the value of **pcsel** changes, and we don’t know the value of **pcsel** yet since that is derived normally in the ID stage. So we have to derive it as well in the IF stage.

**If we should predict and it is predicted to jump**, we store the value of the **predicted\_immed** inside the **immed** field of the PC. We also derive the **predicted\_immed** from the instruction when we decide if we should predict or not.

**If we should not predict this cycle**, the natural **immed** is stored inside the **immed** field of the PC, and the **pcsel** is either the natural **pcsel** derived from the control ROM or it is PC+1, based on whether the previous cycle we predicted an outcome. Since if we previously predicted an outcome, the natural **pcsel** will be that of the jump instruction, instead of the instruction proceeding it.

After we make our prediction the **next cycle we must check if it was correct**.

<figure><img src=".gitbook/assets/image (15).png" alt=""><figcaption><p>circuitry checking if prediction was correct</p></figcaption></figure>

We check to see if the condition was met for that instruction and whether we previously predicted a jump or not. **If they are the same our prediction was correct**.

<figure><img src=".gitbook/assets/image (16).png" alt=""><figcaption><p>circuitry checking for incorrect prediction</p></figcaption></figure>

But if we previously made a prediction and it was wrong, we need to **flush the pipeline**.

<figure><img src=".gitbook/assets/image (17).png" alt=""><figcaption><p>Flushing instruction coming into IF->ID</p></figcaption></figure>

This means we need to remove the instruction coming into the ID stage currently.

<figure><img src=".gitbook/assets/image (18).png" alt=""><figcaption><p>Edited PC logic for predictions</p></figcaption></figure>

We need to set the PC back to what it was previously when we made the prediction. This is why we change the PC logic for this version.

When we detect that we should predict an outcome, the **prev\_pc** register is loaded. When a pipeline flush is needed, the **flush** signal directs the **prev\_pc** signal instead of the **pcout.**

<figure><img src=".gitbook/assets/image (19).png" alt=""><figcaption><p>pcsel change for incorrect prediction</p></figcaption></figure>

We need to set **pcsel** to the **opposite** of what we predicted previously.



#### Exceptions made for bl instruction (branch with link/subroutine call)

<figure><img src=".gitbook/assets/image (20).png" alt=""><figcaption><p>Changes to Link register for predictions</p></figcaption></figure>

During the ID stage, if the **load\_LR** signal is read as true, the **previous PC+1 is loaded into the Link Register** instead of the current PC, since if we made a jump prediction previously the wrong return address would be loaded into the LR.

<figure><img src=".gitbook/assets/image (21).png" alt=""><figcaption><p>rts is read and processed right away</p></figcaption></figure>

Regarding **rts** since it is always an unconditional jump, we directly read **str\_LR** in the IF stage and always jump right away.

Both the **instrUnload** and **str\_LR** control signals are not needed in this version of the CPU.



### Prediction Methods



<figure><img src=".gitbook/assets/temp (1).png" alt=""><figcaption><p>Prediction method toggle</p></figcaption></figure>

There are 4 prediction methods that we employ with varying rates of success. The method used can be toggled using the buttons pictured above.

<figure><img src=".gitbook/assets/image (22).png" alt=""><figcaption><p>Visual representation of prediction success rate</p></figcaption></figure>

We also use 2 TTYs to visually represent branches taken(T) and not taken(N) and we can see how the predictions vary from the outcome.

<figure><img src=".gitbook/assets/image (23).png" alt=""><figcaption></figcaption></figure>

Addressing each prediction method requires the address of the jump/branch instruction. Normally we take the current PC as the address, so we are able to access a prediction for that address. When **prev\_shld\_predict** is active i.e., we made a prediction previously, we need to update the prediction for that instruction, so we need to take the previous PC as the address.



#### 1-bit Prediction Table



<figure><img src=".gitbook/assets/temp (2).png" alt=""><figcaption><p>1-bit Prediction Table</p></figcaption></figure>

The **1-bit prediction table** is the simplest prediction method. We have a 8 address memory that we address by the last 3 bits of our address, each memory location contains a 0 – Don’t jump or a 1 – Jump. After each prediction we update the memory based on whether we jumped or not.

This is the simplest method but it is also the least accurate. For every loop there are 2 mandatory missed predictions, one on loop enter, and one on loop exit.



#### 2-bit Prediction Table



<figure><img src=".gitbook/assets/temp (3).png" alt=""><figcaption><p>2-bit Prdiction Table</p></figcaption></figure>

The **2-bit prediction table** works in a similar way, but each memory location is comprised of 2 bits, and there are 4 possible states:

* 00 – Strong Not Taken
* 01 – Weak Not Taken
* 10 – Weak Taken
* 11 – Strong Taken

The most significant bit signifies whether the branch should be taken or not. The transitions between states are listed in the image bellow:

<figure><img src=".gitbook/assets/image (24).png" alt=""><figcaption><p>Transition between states</p></figcaption></figure>

This is more accurate than 1-bit predictions since there is only one mandatory missed prediction on loops, on loop reenters it correctly predicts the reenter.



#### Correlating Predictor



<figure><img src=".gitbook/assets/temp (4).png" alt=""><figcaption><p>Correlating Predictor</p></figcaption></figure>

One problem with the previous prediction methods is that because we only address by the last 3 bits of our address (and we don’t have much address space for predictions), sometimes 2 jump instructions can have the same last 3 bits and therefore the same spot in the prediction table.

The correlating predictor fixes this by first running the address through a 8x3 Local History Table(LHT), that reroutes the address to a different prediction table location. After a prediction is made, the LHT is updated by shifting a 1 or 0(Branch Taken or Not Taken) into the addressed LHT spot. This then points to a different spot in the prediction table, that will be accessed on the next access of the LHT i.e., the next jump that has the same last 3 bits will not access the same prediction as the one before it.



#### Tournament Predictor



<figure><img src=".gitbook/assets/temp (5).png" alt=""><figcaption><p>Tournament Predictor</p></figcaption></figure>

One problem with the correlating predictor is that it is not always better than a standard 2-bit predictor. Sometimes the LHT rerouting can interfere with jumps that do not share the same last 3 bits.

The tournament predictor fixes this by **dynamically choosing whether to predict by local memory or global memory**.&#x20;

We have a LHT and LPT that keep track the same as a correlating predictor, the Global History Register is updated after every prediction (1 is shifted into it if branch taken, 0 if not taken), the address from the GHR is used to address the Global Prediction Table (GPT), that acts as our standard 2-bit predictor, and the GHR is also used to address the CPT, which is updated the same way as a 2-bit prediction table. The result from the CPT is used to choose whether to take the prediction from the LPT or the GPT when they differ.

The tournament predictor has the highest rate of correct prediction out of every method used and is the most advanced method here.

Examples and tests using all of these methods can be found in **Assembler/tests/test14.txt**
