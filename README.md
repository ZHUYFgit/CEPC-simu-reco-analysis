# CEPC-simu-reco-analysis
Introduce the whole process of simulation, reconstruction, and analysis at the CEPC.
There is a detailed description of CEPC software and analysis procedure written by Yuexin Wang, https://code.ihep.ac.cn/wangyuexin/cepcsoft-tutorial/-/wikis/Quick-Start.

------

## Generator (based on whizard)
 - Download whizard from [https://github.com/lhprojects/WhizardAis]([http://madgraph.phys.ucl.ac.be](https://github.com/lhprojects/WhizardAis)).
 - The following operations are based on the CEPC env, so you need to load the container of CEPC env with the following commands.
   * `export PATH=/cvmfs/container.ihep.ac.cn/bin:$PATH`
   * `hep_container shell CentOS7`
   * `export PATH=/cvmfs/common.ihep.ac.cn/software/hepjob/bin:$PATH`
 - If you want to generate e+e- -> bb with the center of mass energy of 91.2 GeV, follow the steps listed in the following.
   * Edit the 2fermions.prc to specilize the process, shown as the file [[generator/2fermions.prc]](generator/2fermions.prc).
   * Edit the mkin.sh to set the luminosity or number of events you want to generate, just as the file [[generator/mkin.sh]](generator/mkin.sh).
   * Edit the file example to set running process, as the file [[generator/example]](generator/example).
   * Press the command `source example` and you would get the directory named 2fermions containing the files used to generate samples.
   * Go to the directory 2fermions and sh sub_all.sh. The job used to generate samples would be submitted to cluster. Note: you need to change the command `hep_sub` to `hep_sub -os CentOS7` in sub_all.sh.

## Simulation
#### Full Simulation
 - If you can access the computing resource from Institute of High Energy Physics, Chinese Academy of Sciences, you can do full simulation with CEPC Software.
 - Welcome to join CEPC.
 - The directory [[full_simulation]](full_simulation) provides the code used to extract the features from the reconstructed files (with postfix slcio).


## Install Miniconda3, weaver, and ParticleNet
 - Install Miniconda3 according to your OS, such as you can install it with the following commands. You need to change the path in env_conda.sh to your installed miniconda3 path.
 ```
$ wget https://repo.anaconda.com/miniconda/Miniconda3-latest-lnux-x86_64.sh
$ chmod +x Miniconda3-latest-Linux-x86_64.sh
$ ./Miniconda3-latest-Linux-x86_64.sh
$ source env_conda.sh
```
 - Create a virtual environment, activate the created environment, install pytorch (according to ou OS/CUDA version at [https://pytorch.org/get-started](https://pytorch.org/get-started)) and weaver with the following commands. 
```
$ conda create -n weaver python=3.10
$ conda activate weaver
$ conda install pytorch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1 pytorch-cuda=11.6 -c pytorch -c nvidia
$ pip install weaver-core
```
 - Once you do something wrong with weaver env, you can delete the env with the following command and recreate the env with the above commands.
```
$ conda env remove --name weaver
```
#### Install ParticleNet
 - Download ParticleNet and Particle Transformer from github  https://github.com/jet-universe/particle_transformer. Once your analysis use the code from ParticleNet or Particle Transformer, you need to cite the papers listed in https://github.com/jet-universe/particle_transformer.
 - The director of ParticleNet (suppose that the directory name you downloaded is ParticleNet) has several files.
   * ParticleNet/env.sh: set the input directories of samples in this file (export DATADIR_JetClass=)
   * ParticleNet/data/JetClass/JetClass_full.yaml:
     * *new_variables* means you can construct new variables based on the variables stored in your generated root files
     * *Pt_points* has two variables used to calculate the distance between two particles in ParticleNet
     * *pf_features* are the features used in training the model
     * *pf_vectors* are four momentum of particles used to calculate the pair-wise features used in Particle Transformer
     * *labels* list the labels of your sample when you want to train a classfication model
     * *observers* list the variables do not used to train the model while keep them in the files after testing
     * *length* restrict the number of particle candidates within the jet. In proton-proton collision, the particles are sorted by the transver momentum, while in electron-positron collision, the particles are sorted by the energy. If the *length* is larger than the number of particles in the jet, the leading *length* particles are preserved. If the *length* is smaller than the number of particles in the jet, the program would add particles with all features equal to 0.
   * ParticleNet/train_JetClass.sh: set the detailed input paths, predicted output path, and other hyper parameters   


## Acknowledgement

We extend our heartfelt thanks to Huilin Qu and Congqiao Li for their invaluable support in utilizing ParticleNet and Particle Transformer. Our gratitude also goes to Shudong Wang and Xu Gao for their guidance in Delphes, as well as to Sitian Qian and Ze Guan for their support with Herwig.
