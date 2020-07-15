@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "d:\_avr\Project\labels.tmp" -fI -W+ie -C V2E -o "d:\_avr\Project\device1.hex" -d "d:\_avr\Project\device1.obj" -e "d:\_avr\Project\device1.eep" -m "d:\_avr\Project\device1.map" "d:\_avr\Project\device1.asm"
