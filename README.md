StrongCrypt
===========
----

StrongCrypt is a on the fly transparent disk encryption program for MS Windows Vista/7/8/8.1/10 (32 and 64 Bit)

Using this software, you can create one or more "virtual disks" on your computer - anything written to these disks is automatically, and securely, encrypted before being stored on your computers hard drive.

** This software is based on FreeOTFE and/or FreeOTFE4PDA, the free disk encryption system for PCs and PDAs, available at www.FreeOTFE.org **

Features
--

  - Source code freely available
  - Easy to use; full wizard included for creating new volumes
  - Hash algorithms include: Whirlpool, SHA-512, RIPEMD and many more
  - Cyphers include: AES (256 bit), Twofish (256 bit), Serpent (256 bit) and many more
  - Cypher modes supported include: XTS and CBC
  - Linux compatibility (dm-crypt and LUKS supported)
  - Hidden volumes , providing "plausible deniability"
  - StrongCrypt volumes have no "signature" to allow them to be identified as such
  - Encrypted volumes can be either file or partition based.
  - Modular design allowing 3rd party drivers to be created, incorporating new hash/cypher algorithms
  - Supports password salting (up to 512 bits), reducing the risks presented by dictionary attacks.
  - Supports volumes files up to 2^63 bytes (8388608 TB)
  - Portable mode included

Version
--
5.3

Why version 5.3?

StrongCrypt is based on FreeOTFE 5.2. So we start with 5.3.

What is new in 5.3
--
  - Some small changes in the drivers (replaced banned functions)
  - Replaced MS Crypto API PRNG with ISAAC PRNG
  - Simplified the build process
  - Replaced old WinXP toolbar icons with new Win8 toolbar icons
  - Replaced program icon
  - Algorith column added to main window
  - Added password quality indicator
  - Removed update check ( we don't want the program to phone home)
  - ASlR and DEP added to the main program
  - some minor tweaks

License
--
FreeOTFE Licence (v1.1)
