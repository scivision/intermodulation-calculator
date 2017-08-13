# intermodulation-calculator
Joe Stevens' Pascal Intermodulation product calculator for radio systems. 
No longer maintained by Joe, originally at http://www.kadiak.org/joe/im.html

## Prereq 
You will need a Pascal compiler. 

### Linux/Windows Subsystem for Linux

    apt install fp-compiler fp-ide

### Mac OS

    brew install fpc

## Build

    fpc 

## Invoke Free Pascal IDE
If you want to edit Pascal / Turbo Pascal code in general, you can install the Pascal IDE by 

    apt install fp-ide

and start the text-GUI IDE environment (1990 style) by

    fp

## Program description

This program will run all possible combinations of every transmitter against every receiver in the list.  
It will allow you to choose the bandwidth of the receivers, which is to say how far removed from a receiver carrier on the list will a hit be reported.  
This seperation is entered in MEGAHERTZ such as .049 or .075 and is entered each time you run the program.

The program will NOT report a hit if the DESCRIPTION of any of the frequencies is identical.  
If two transmitters have exactly the same description, it assumes the two frequencies are different channels in the same transmitter and cannot both be on the air at the same time.
Also if a radio is not duplex as a repeater, it cannot transmit and receive at the same time.  
So if the receiver has exactly the same description as a transmitter, it will not report a hit. 
 For this purpose CASE IS SIGNIFICANT!  WL7aml does NOT equal WL7AML.

Descriptions are limited to 8 characters.  
When modifying the two files of frequencies (RFREQS & TFREQS) keep exactly the same number of characters in the frequency and the description.  
It reads the column the character is in to determine the information.  
More than the maximum number of characters will crash the program.

The frequency files, `RFREQS` and `TFREQS`, may be edited with any ASCII editor.  
To edit the receiver frequency file, edit the file `RFREQS`. 
When you have finished entering or changing the data, press the F7 key, then ENTER.  
To edit the transmitter list, just substitute TFREQS in the above.

## Run intermodulation calculator

    IM out.txt

This will place the results of the run in a file name `out.txt`.


## Original author notes 
Note that Joe no longer maintains this program.

The program was originally written and compiled with Borland Turbo Pascal 3.0

    Joe Stevens, WL7AML
    Aksala Electronics, Inc. 
    Kodiak, AK  99615  
    jstevens@ptialaska.net

