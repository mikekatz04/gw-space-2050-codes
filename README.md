# gw-space-2050-codes

Data Analysis Codes for GW Space 2050 Studies. 

1) To run, clone this repository:

```
git clone https://github.com/mikekatz04/gw-space-2050-codes.git
cd gw-space-2050-codes
```

2) Run the install script. You must have Anaconda installed with the base distribution loaded. This will run through `conda`. It will create a new environment and install all required packages/versions (LISA Analysis Toosl, BBHx, GBGPU, FEW, Eryn, etc.). The default environment name will be "2050_env." To adjust that, provide `env_name=` after the install script.

```
bash space_2050_install.sh env_name=2050_env
```

3) Follow the install instructions for [`gwspaceperf`](https://git.aei.mpg.de/gwspace2050/performance-model).

4) Activate the environment, open the notebook, and run.

```
cd notebooks/
conda activate $env_name
jupyter lab space_2050_tutorial.ipynb
```

## Acknowledgements

* LISA orbits and deciHertz orbits are based on [https://link.springer.com/article/10.1007/s40295-021-00263-2](https://link.springer.com/article/10.1007/s40295-021-00263-2).
* LISA max orbits are based on [https://iopscience.iop.org/article/10.1088/1361-6382/acf3c7](https://iopscience.iop.org/article/10.1088/1361-6382/acf3c7).

## Authors

* Michael L. Katz
* Alice Perego, Alberto Sesana, Matteo Bonetti (Stochastic Contributions)
