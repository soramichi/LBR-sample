[[日本語]](https://github.com/soramichi/LBR-sample/blob/master/README.md)

# How to configure LBR (Last Branch Record) by yourself

## Overview of LBR
- The processor records the source (from_ip) and the destination (to_ip) of when a branch-related instruction is executed.
- Branch-related instructions include not only 'jmp' but also function calls and 'ret'.
- The overhead is (almost) zero because the addesses are recoreded by hardware into model specific registers.
- "Branch traces" used in debuggers like gdb, on the other hand, incurs an iterruption to software every time a branch is executed and the overhead is huge (a brief experiment on a numeric application showed 250X slowdown).
- A drawback is that the number of records is limited due since they are stored in model specific registers. Skylake (and newer) CPUs can store 32 records and Broadwell (and older) ones can store 16.

## How to use the sample
- Prepare a random workload that issues many 'jmp's
```
main(){
  int i = 0;

  while(1) {
      i++;
  }
}
```
- Execute it on a specific core (e.g. core 1)
```
$ taskset -c 1 ./a.out &
```
- Execute the sample (that reads and displays 'from_ip's of core 1)
```
$ ./lastbranch_from_ip.sh
559135ada66f
559135ada66f
559135ada66f
...
```
- Extract the memory address on which the execution code of a.out is placed (from /proc/{PID}/maps).
Adding it the offset of the jmp instruction inside the program code will give you the same address as shown above.

## Things to improve
- There is no gdb integration of LBR. This is because a CPU does not support freezing the LBR when an exception occurs or when a break point is hit.
This means that you will see many branches that are on the way from a workload to gdbs if you read LBRs from gdb when the workload stops at an exeception.
- Therefore, if you want to freeze LBR when an arbitrary type of exeception (like SIGSEGV, SIGFPE) occurs, you may need to add a code to stop the LBR recording into the head of exception handlers in the OS.

## References (on how LBR is useful)
- https://lwn.net/Articles/680985/
- https://lwn.net/Articles/680996/ 