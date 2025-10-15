import sys
from cx_Freeze import setup, Executable

setup(
    name="myAssembler",
    version="1.0",
    description="Assembler za MiMo model",
    executables=[Executable("assembler.py", base=None)])
