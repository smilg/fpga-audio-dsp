# Comparch FA'22 Final Project - FPGA Audio Delay

This is my final project for Computer Architecture. It is a feedback audio delay effect currently for simulation only. To run the simulation, use `make test_main`. The output can be viewed by running `make waves_main`. See [`docs/delay_documentation.md`](docs/delay_documentation.md) for more information about how it works.

The hdl for the project is located in [`hdl/`](hdl/) and the testbench is located in [`tests/`](tests/). The `.memh` files with audio samples for simulation and a Python script to generate new ones ([`generate_sine_samples.py`](memories/generate_sine_samples.py)) are in [`memories/`](memories/).
