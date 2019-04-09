import os
import hdltools

root = os.path.dirname(__file__)
sim = hdltools.Simulation()
sim.add_source_files(os.path.join(root, "test", "*.sv"))
sim.add_source_files(os.path.join(root, "test", "*.v"))
sim.add_source_files(os.path.join(root, "src", "*.v"))

sim.run()
