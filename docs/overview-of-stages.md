# Overview of Stages

##

## CPU Layout

<figure><img src=".gitbook/assets/image (60).png" alt=""><figcaption><p>OR class sketch</p></figcaption></figure>

The general layout of the CPU and it's stages has been made to mimic the OR class sketch in it's layout. All of the stages and their parts are displayed on the main circuit with added "transition blocks" between them (like IF->ID, ID->EX), that store the data going in and leaving a stage.

## Instruction Fetch

<figure><img src=".gitbook/assets/image (61).png" alt=""><figcaption><p>IF Stage along with Instruction RAM</p></figcaption></figure>

#### Inputs:

* immed
* Rs
* pcsel
* instrUnload
* str\_LR
* load\_LR

#### Outputs:

* instruction

The Instruction Fetch Stage has the task of fetching a new instruction each cycle.

The **immed** and **Rs** values are directly taken from the most recently processed ID Stage immediate and register values.

The **pcsel** signal dictates whether the PC should increment, jump to immediate address(**immed**), jump to PC + immediate or jump to register address(**Rs**).

<figure><img src=".gitbook/assets/image (53).png" alt=""><figcaption><p>Inside of PC</p></figcaption></figure>

After processing the correct address, the Instruction RAM gives us the corresponding instruction.

<figure><img src=".gitbook/assets/image (48).png" alt=""><figcaption><p>instrUnload MUX</p></figcaption></figure>

The **instrUnload** signal decides whether the instruction passes through to the ID stage. It's purpose is to stop the instruction that is right after a jump/branch command from passing through.

The Link register works as described on the _Instructions_ page.

## Instruction Decode

<figure><img src=".gitbook/assets/image (62).png" alt=""><figcaption><p>ID Stage</p></figcaption></figure>

#### Inputs

* instruction
* Flags (C, Z, V, N)

#### Outputs

* immed
* imload
* dregsel
* tregsel
* sregsel
* cond\_met
* set\_flags
* opcode

The purpose of this stage is to decode the given instruction, decide if it should be executed, and access the needed register values.

The instruction enters the instruction register, from which we receive:

* &#x20;the immediate **immed** that is only loaded if **imload** bit is also active. This immediate is then passed to the next stage.
* **dsel, ssel** and **tsel** which indicate which registers to access
* the **opcode** that will go to the Control ROM
* the **set\_flags** bit that indicates whether the instruction should influence the flags or not.
* the **condition** bits that indicate the condition for which this instruction should execute

The **condition** bits enter the **check\_condition** circuit along with the condition flags (N, Z, C, V). The output is the **condition\_met** signal which indicates whether this instruction passes the given condition.

This  **cond\_met** signal is then passed to the Control ROM along with the **opcode**.

The **set\_flags** signal from our Instruction Register passes through an AND gate with the **condition\_met** signal and is then passed to the next stage (Execute).

The Register Bank needed to be changed to allow 2 selections at the same time, as both the ID and the WB stage need access to it.

**dsel, ssel, tsel** have been changed to **dselin, sselin, tselin** for the WB stage and **dselout, sselout, tselout** for the ID stage.

<figure><img src=".gitbook/assets/image (51).png" alt=""><figcaption><p>Register Bank change</p></figcaption></figure>

The **dsel, ssel** and **tsel** signals enter the **dselout, sselout, tselout** signals of the Register Bank and from the **dreg, sreg** and **treg** outputs, the values for **Rd**, **Rs** and **Rt** are transferred to the next stage.

<figure><img src=".gitbook/assets/image (63).png" alt=""><figcaption><p>Register Bank connected to the ID stage</p></figcaption></figure>

The **dselin, sselin** and **tselin** inputs of the Register Bank are read from the WB stage, as this is when register write back happens. The values of the current instruction's **dsel, ssel** and **tsel** signals are passed on to everey proceding stage, so the same values may be used in the WB stage 3 cycles from now.

## Instruction Execute

<figure><img src=".gitbook/assets/image (64).png" alt=""><figcaption><p>EX Stage</p></figcaption></figure>

#### Inputs:

* Rd
* Rs
* Rt
* Immediate (**immed**)
* flags\_set
* op2sel
* aluop
* negOp2
* rvrsOps
* dregsel
* tregsel
* sregsel

#### Outputs:

* aluout
* Flags (C, Z, V, N)
* Rd
* Rs
* Rt
* immed
* dregsel
* tregsel
* sregsel

The purpose of the Execute stage is to transform the data using an ALU operation if needed and change the condition signals (C, Z, V, N) if instructed to.

The Execute stage takes the register values and immediate fetched in the ID stage as it's operands for data transformation.

**Rs** is always taken as the first operand. The **op2sel** signal dictates which values to take as the second operand: **Rt**, the immediate, constant 0 or constant 1. The **negOp2** signal dictates whether we want the second operand to pass through a NOT gate. The **rvrsOps** signal dictates whether we should swap the first and second operand in the ALU.

The **aluop** signal dictates which ALU operation we want to perform. Each of the condition signals are only changed if the **flags\_set** signal is active.

The resulting ALU result is passed through to the next stage along with the register and immediate values for this instruction.

## Memory Access

<figure><img src=".gitbook/assets/image (65).png" alt=""><figcaption><p>MA Stage</p></figcaption></figure>

#### Inputs:

* aluout
* Rd
* Rs
* Rt
* immed
* addrsel
* datasel
* datawrite
* dregsel
* tregsel
* sregsel

#### Outputs:

* aluout
* immed
* Rs
* dregsel
* tregsel
* sregsel

The purpose of the Memory Access stage is to decide whether to read from or write to memory and select data to be written/address to read from.

The **addrsel** signal decides which address in the Operand RAM to read from/write to. It's options are **immed, aluout** and **Rs**.

The **datasel** signal decides what data to write to the Operand RAM in the case of a write command. It's options are **Rd, Rt** and **aluot**.

The **datawrite** signal dictates wether data should be written to the RAM.

The selected address and data (**datain**) are passed to the Operand RAM. The Operand RAM transfers the **operand** (that the address points to in the case of a read operation) to the next stage.

The data can also be written to any of the 2 other peripherals, the Frame Buffer LED and the TTY, based on the original MiMo model's address decoding scheme.

## Write Back

<figure><img src=".gitbook/assets/image (66).png" alt="" width="398"><figcaption><p>WB Stage</p></figcaption></figure>

#### Inputs:

* Rs
* aluout
* immed
* operand
* regsrc
* dwrite
* swrite
* twrite
* dregsel
* tregsel
* sregsel

#### Outputs:

* regwrite

The purpose of the Write Back stage is to write back to the registers (if needed) any transformed or fetched data in the previous stages.

The **regsrc** signal dictates what data is to be written to the register. It's options are **Rs, immed,** **operand** (taken from Operand RAM) and **aluout**.&#x20;

<figure><img src=".gitbook/assets/image (67).png" alt=""><figcaption><p>Register Bank connected to the WB stage</p></figcaption></figure>

The result is the **regwrite** output which enters the Register Bank along with the **dwrite, swrite** and **twrite** signals which indicate whether to write or not.

The **dregsel, sregsel** and **tregsel** signals from 3 cycles before now exit the pipeline and indicate which registers to write to.

The CPU has now completely finished executing the given instruction and it has exited the pipeline in 5 stages, while concurrently processing 4 other instructions in each of the previous stages. This encapsulates the efficiency of the pipelined model over the previous version.
