#include <systemc.h>
#include <verilated.h>
#include <verilated_vcd_sc.h>

#include "Vsoc.h"

#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

using namespace std;

int sc_main(int argc, char* argv[])
{
  Verilated::commandArgs(argc, argv);

  long long unsigned time;
  string filename;
  char *p;
  const char *dumpfile;

  if (argc>1)
  {
    time = strtol(argv[1], &p, 10);
  }
  if (argc>2)
  {
    filename = string(argv[2]);
    filename = filename + ".vcd";
    dumpfile = filename.c_str();
  }

  sc_clock clock ("clock", 1,SC_NS, 0.5, 0.5,SC_NS, false);
  sc_signal<bool> reset;

  Vsoc* soc = new Vsoc("soc");

  soc->clock (clock);
  soc->reset (reset);

#if VM_TRACE
  Verilated::traceEverOn(true);
#endif

#if VM_TRACE
  VerilatedVcdSc* dump = new VerilatedVcdSc;
  sc_start(sc_core::SC_ZERO_TIME);
  soc->trace(dump, 99);
  dump->open(dumpfile);
#endif

  while (!Verilated::gotFinish())
  {
#if VM_TRACE
    if (dump) dump->flush();
#endif
    if (VL_TIME_Q() >= 10000)
    {
      reset = 0;
    }
    else
    {
      reset = 1;
    }
    if (VL_TIME_Q() > time)
    {
      break;
    }
    sc_start(1,SC_NS);
  }

  cout << "End of simulation is " << sc_time_stamp() << endl;

  soc->final();

#if VM_TRACE
  if (dump)
  {
    dump->close();
    dump = NULL;
  }
#endif

  delete soc;
  soc = NULL;

  return 0;
}
