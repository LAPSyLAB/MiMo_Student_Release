# Original project

This is a OR related fork of original thesis project by Kiril Tofiloski

https://github.com/kiriltofiloski/pipelined-MiMo-CPU


# CPU Overview

This document describes the changes to the new versions of the pipelined CPU based on the original MiMo CPU model.

Developed in Logisim Evolution.

General features and changes:

* 5 stage pipeline (Instruction fetch - **IF**, Instruction Decode - **ID**, Execute - **EX**, Memory Access - **MA**, Write Back - **WB**)
* Harvard Architecture (Separate Instruction and Operand RAM)
* 32-bit Instruction Set
* 16-bit addresses (_Logisim RAM modules have limited address sizes)._
* Instruction set has been modified to be more similar to ARM ISA (_More details on **Instructions** page)._
* Added Overflow flag **V**
* Added Link Register
* Multiple pipeline hazard optimization methods added (_Described thoroughly on **Pipeline Hazard Optimizations** page_)_._

