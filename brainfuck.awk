#!/usr/bin/awk -f
BEGIN {
    STORAGE_SIZE = 1000
    for (m = 0; m < STORAGE_SIZE; m++)
        storage[m] = 0
    
    for (m = 0; m < 256; m++)
        ord_table[sprintf("%c", m)] = m
}

{
    # filter out invalid chars
    gsub(/[^><+-.,\[\]]/, "")

    # append current line to end
    program = program $0
}

END {
    program_length = length(program)

    # calculated loops jump table using a stack
    stack_length = 0
    for (k = 0; k < program_length; k++) {
        op = substr(program, k+1, 1)
        if (op == "[") {
            # push
            stack[stack_length++] = k
        } else if (op == "]") {
            start_p = sprintf("%d", stack[stack_length-1])
            jump_table[start_p] = k
            jump_table[k] = start_p
            # pop
            delete stack[stack_length--]
        }
    }

    ptr = 0
    count = 0
    for (i = 0; i < program_length; ++i) {
        op = substr(program, i+1, 1)
        if (op == ">")          { ptr = min(ptr + 1, STORAGE_SIZE) }
        else if (op == "<")     { ptr = max(ptr - 1, 0) }
        else if (op == "+")     { storage[ptr] = min(storage[ptr] + 1, 2^8 - 1) }
        else if (op == "-")     { storage[ptr] = max(storage[ptr] - 1, 0) }
        else if (op == ".")     { printf("%c", storage[ptr]) }
        else if (op == ",")     { printf("> "); getline str <"-"; storage[ptr] = ord(str) }
        else if (op == "[" && !storage[ptr]) { i = jump_table[i] - 1 } # jump to loop end
        else if (op == "]" && storage[ptr])  { i = jump_table[i] - 1 } # jump to loop start
    }
}

function min(a, b) {
    return a < b ? a : b
}

function max(a, b) {
    return a > b ? a : b
}

function ord(str,  c) {
    c = substr(str, 1, 1)
    return ord_table[c]
}