#!/bin/sh

SIZE=100000000
CHUNK=1
MAX_PATH=10

while true; do
    MP_HIGH=$(echo "$MAX_PATH/2^65" | bc)
    MP_LOW=$(echo "(($MAX_PATH/2) - $MP_HIGH*(2^64))" | bc)
    NEXT=$(echo "$CHUNK + $SIZE" | bc)

    sed -i "s/\(%define start \).*/\1$CHUNK/" collatz.asm
    sed -i "s/\(%define end \).*/\1$NEXT/" collatz.asm
    sed -i "s/\(%define mp_low \).*/\1$MP_LOW/" collatz.asm
    sed -i "s/\(%define mp_high \).*/\1$MP_HIGH/" collatz.asm
    nasm -f elf64 collatz.asm
    ld collatz.o
	OUT=$(./a.out)
	ITER=$(echo $OUT | cut -d' ' -f1)
	LOW=$(echo $OUT | cut -d' ' -f2)
	HIGH=$(echo $OUT | cut -d' ' -f3)
	echo $ITER
	echo $LOW
	echo $HIGH
    COM=$(printf "2*(%s+((2^64)*%s))" "$LOW" "$HIGH"| bc)
	echo $COM
    if [ "$OUT" != "Segmentation fault (core dumped)" ]; then
        AT_ITERATION=$(echo "$OUT" | cut -d' ' -f1)
        NEXT_PATH=$(echo "$OUT" | cut -d' ' -f2)
        if [ $(echo "$NEXT_PATH > $MAX_PATH" | bc) -eq 1 ]; then
            MAX_PATH=$NEXT_PATH
            echo "$AT_ITERATION $MAX_PATH"
        fi
        CHUNK=$(echo "$CHUNK + $SIZE" | bc)
    fi
done
