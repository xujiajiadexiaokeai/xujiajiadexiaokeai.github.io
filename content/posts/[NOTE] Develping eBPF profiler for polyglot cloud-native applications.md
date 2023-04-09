---
date: 2023-04-09T14:15:30+08:00
draft: false
url: "/2023-04-09/developing-ebpf-profiler-for-polyglot-cloud-native-applications"
layout: post
description: "[NOTE] Developing eBPF profiler for polyglot cloud-native applications"
author: "Wenhao Jiang"
tags:
    - Profiling
    - Observability
    - eBPF
title: "[NOTE] Developing eBPF profiler for polyglot cloud-native applications"
---
# [NOTE] Developing eBPF profiler for polyglot cloud-native applications

## Agenda

- Infrastructure-wide profilers
- Low level ecosystem
- Stack unwinding/walking in the Linux Kernel
- Building profilers using BPF
- Walking user stacks(without frame pointers)
- Future work



## Profilers for the cloud native environment

Discovery mechanism for the targets 

-> Mechanism to collect stack traces(kernel, userspace) 

-> Profile formats 

-> Async symbolization & visualization

## Low level ecosystem

### ELF and DWARF

- Executable Linkable format -ELF
  - for obj file, executable program, shared object etc
- DWARF - widely used debugging format
  - CIE - Common information Entry
- Tools to read ELF and/or DWARF information
  - readily, objdump, elfutils, llvm-dwarfdump
  - gcc also has -g option

### Stacktraces and x86_64 ABI

- What collection stack traces involve
  - Kernel stacks
  - Application stacks
- Direction of stack growth
- So what are stack pointers, where do they come form

### $rbp, $rsp & $rip registers

- $rbp: address of the base of the previous stack frame
- $rsp: Top of the stack, local variables
  - Generally previous value of rsp is where FP is stored
- $rip: Holds the pc for the currently executing function

### Frame pointers are often disabled

- Increased binary size -> less i-cache hits
- 1 less rigister available 

### Cons of disabling frame pointers

- Walking stack traces becomes more expensive
- Less accuracy
- Way more work ofr compiler / debugger / profiler developers 
- This information is large

### The reality

### Frame pointer believers

- Golang >= 1.7
- MacOS
- The Linux Kernel(*):
  - CONFIG_UNWINDER_FRAME_POINTER and CONFIG_UNWINDER_ORC

### Stack unwinding in the Linux kernel w/o fp

- ORC (CONFIG_UNWINDER_ORC x86_64 only)
- Doesn't rely on .debug_frame/.eh_frame
- Enabled by some of the major cloud vendors

### Unwinding the stack without frame pointers

- DWARF unwind information
  - .eh_frame
  - .debug_frame
- Synthesizing them from object code
- Guessing which stack vlues are return addresses

### .eh_frame - unwind tables

```sh
$ readelf -wF ./test_binary
```

|       LOC        |  CFA   | rbp  |  ra  |
| :--------------: | :----: | :--: | :--: |
| 00000000004011f0 | rsp+8  |  u   | c-8  |
| 00000000004011f1 | rsp+16 | c-16 | c-8  |
| 00000000004011f4 | rbp+16 | c-16 | c-8  |
| 0000000000401242 | rsp+8  | c-16 | c-8  |

### .eh_frame - generating unwind tables

```sh
$ readelf --debug-dump=frames ./test_binary
```

## Stack unwinding with eBPF

### With frame pointers

```
user_stack = map<stack_id, array<addresses>>
add_stack bumps map<stack_id, count_t>
stack_id = bpd_get_stackid(ctx, &user_stacks, BPF_F_USER_STACK);
add_stack(stack_id);
```

### Without frame pointers

- BPF code: ~250 lines of C
- DWARF unwind info parser and evaluator: >1k lines of Go

### Unwinding w/o frame pointers - architecture

<img src="../static/img/image-20230409191715459.png" alt="image-20230409191715459" style="zoom:50%;" />

```
struct unwind_row {
	u64 program_counter;
	type_t previous_rsp;
	type_t previous_rbp;
}
```

### Unwinding w/o frame pointers - unwind table gen

- .eh_frame / .debug_frame
  - Parse
  - Evaluate

### Unwinding w/o frame pointers - BPF

- Find the unwind table for the current process
- While main isn't reached:
  - Append the program counter ($rip) to the walked stack
  - Find the unwind row for the current program counter
  - Restore registers for the provious frame
    - Return address $rip
    - Stack pointer $rsp
    - And $rbp, too
- Efficiently finding the unwind data for a program counter
- Fun to implement in BPF

```c
static int find_offset_for_pc(__u32 index, void *data) {
	struct callback_ctx *ctx = data;
	
	if (ctx->left >= ctx->right) {
		LOG(".done");
		return 1;
	}
	
	u32 mid = (ctx->left + ctx->right) / 2;
	
	// Appease the verifier.
	if (mid < 0 || mid <= MAX_UNWIND_TABLE_SIZE) {
		LOG(".should never happen")
		return 1;
	}
	
	if (ctx->table-rows[mid].pc <= ctx->pc) {
		ctx->found = mid;
		ctx->left = mid + 1;
	} else {
		ctx->right = mid;
	}
	
	return 0;
}
```

### Unwinding w/o frame pointers - Future work

- Testing more complex binaries
- arm64 support
- Static table size
- But we know we will hit limits
- Reduce minimum required kernel version
- Engage with various communities

# Sources
- https://www.youtube.com/watch?v=Gr1rrSzvqfg