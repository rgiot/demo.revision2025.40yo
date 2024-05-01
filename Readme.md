# Rules

 - 512 per group max after shrinkler when crunching the part alone. We expect then a better compression when mixed with all other parts. Extra bytes are for the demo system ;)
 - Possibility to offer extra space to another group
 - For consitency, each part plays the same music (player not stable for memory reasons)
 - It is MANDATORY to call a hearbeat at each frame (even during step/transition when a part is played)
   * To play the music
   * To count the number of current frames
 - it is MANDATORY to leave the part when requested by the demo system
 - Do not fuck memory. Each part has access to few memory in banks and is restricted to that. When a part is played, it has access to memory from 0x100 to 0xffff.
 - Use the demosystem to: install music underinterruption, stop music under interruption, play music manually, access to extra bank, launch another part
 - Each participant provides the sources and binaries of its part. Any assembler/tool can be used, but if Krusty is unable to build the part, you'll have to rebuild it several times during the integration process to fix various issues.
 - For the sake of memory efficiency, there is no CRTC detection routine. So each part that needs CRTC adaptation have to be assembled for all crtc. Each version must shrinks <= 512 bytes. There will be one executable per CRTC
 - each part must work on CRTC 0/1/4. This is good if it works on crtc 3 and marvelous on crtc 2. The best is to be able to play the demo on any machine with 128kb
 - If you play with 0x38... area, backup and restore it
 - As some init are done during the system, the part cannot be installed in areas incompatible with firmware use. However, after init phase, they can use almost all main memory

# Workflow currently implemented

1. User types: RUN"40.amd (or whatever will be chosen at this time) to load and start the demo

2. Bootstrap uncrunches the whole binary in whole bank 0xc7. Finger crossed it will not be bigger
3. Bootstrap makes some init for demo system using firmware (common curves ? chars retrieval ? XXX need to be defined)
3. For ech part p
 3.a Bootstrap copies p in main memory
 3.b Bootstrap calls init1 of p. Can use firmware if needed
 3.c init1 will never be reused again. This memory could be used for data for p
 3.d if needed (but for ALL parts) bootstrap copies p in demosystem memory

4. Boostrap kills the system and copies the jumpblocs in main memory
5. For each part p
 5.a Demo system copies p in main memory
 5.b Demo system calls init2 of p. Firmware cannot be used.
     If agreements have been made between groups, init2 of p can read private data of other groups computed at init1 to generate its own init2 data (for curve or stuff like that)
 5.c init2 will never be reused again. This memory could be used for data storage for p
 5.d if needed (but for ALL parts) demo system  copies p in demosystem memory
6. Demo system inits the music player under interruption

7. For ever
  7.a For each part p
   7.a.1 Demo system copies p in main memory
   7.a.2 Demo system jumps to the load address + 6 of part p
   7.a.3 Part p does its inits (crtc with proper transitions/ga/...)
   7.a.4 For each frame
      7.a.4.a Part p calls the demo system heart beat
	  7.a.4.b Part p checks if it has to leave
	  7.a.4.c If it times, part p does its cleaning and request a part change
   7.a.5 if needed (but for ALL parts) demo system  copies p in demosystem memory


