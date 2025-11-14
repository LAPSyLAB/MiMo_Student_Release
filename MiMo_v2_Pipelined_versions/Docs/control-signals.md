# Control Signals

### Conditional Execution and Removed Decision ROM

In the previous version of MiMo, conditional instructions would have to be specified and specifically programed for every condition in the micro-assembler.

Given that we changed it so every instruction can have an optional condition code now, programming each one separately seems unnecessary.

I found that a more elegant solution is to remove the decision ROM and have the conditional checking be done in hardware.

<figure><img src=".gitbook/assets/image (41).png" alt=""><figcaption><p>The Control ROM</p></figcaption></figure>

The new conditional execution is done in the following way:

1. A **condition\_met** signal along with the **opcode** is received from the **ID** stage**.**
2. The first address in our Control ROM is reserved for when a condition is not met. This throws the following **EX,MA,WB** and **IF** stages in their idle/default state as no instruction will be coming in.
3. The **condition\_met** signal tells us when a condition has been met, so we may execute the instruction. When it is active, the Control ROM takes the **opcode** + 1 (+1 because of reserved first address) as it's address, when it is inactive it takes the first idle/default address as the condition has not been met.
4. Each ROM address contains the values that each control signal should have for the current microinstruction.

### Control signal buffering

Because it is a pipelined CPU of course, some signals will be needed in later stages than others.

To accommodate for this, signals are buffered using different shift registers,

&#x20;&#x20;

<figure><img src=".gitbook/assets/image (50).png" alt=""><figcaption><p>Buffering of control signals</p></figcaption></figure>

For example, signals needed for the **EX** stage will be needed right after the **ID**  stage, so they are entered in a 1 stage shift register. Signals needed for the **MA** stage require a 2 stage shift register and signals needed for the **WB** stage require a 3 stage shift register.

The only exceptions are signals needed for the **IF** stage. They are immediately processed as they are always jump/branch signals and the flow of execution needs to be immediately changed.

### Control signals with imload

As mentioned in the **Instructions** **section**, some instructions can either take an immediate or a register as an argument now and we do not need separate instructions for immediates.

Since the micro-assembler does not know if a given instruction will use an immediate or a register, a  change for this situation needed to be made.

For example, take the **op2sel** signal. Previously the possible values were **treg(0), immed(1), const0(2), const1(3)**.&#x20;

For an instruction like **add**, that can use a third register or an immediate value, we do not know which value for **op2sel** (**treg** or **immed)** to program into the micro-assembler.&#x20;

<figure><img src=".gitbook/assets/image (38).png" alt=""><figcaption><p>Using the <strong>imload</strong> signal to determine the proper value of the control signal</p></figcaption></figure>

Instead of having **treg** and **immed**, we replace them with **op2(0),** and use the MUX above to properly determine the signal. It works as follows:

* The signal acts as the select signal to the MUX.
* When it is 0 or 1, if **imload** is 1, effectively **immed(1)** is loaded as the signal, when **imload** is 0, effectively **treg(0)** is loaded.&#x20;
* When it is 2 or 3, **const0(2)** and **const1(3)** are simply loaded.
