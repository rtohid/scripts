#!/bin/bash -e
sudo apt install -y build-essential git cmake gdb htop
sudo apt install -y llvm clang clang-format 
sudo apt install -y libboost-all-dev libgoogle-perftools-dev libopenmpi-dev libhwloc-dev 
sudo apt install -y libblas-dev liblapack-dev 
sudo apt install -y python3-pip pylint python3-tk
sudo apt install -y texlive texlive-extra-utils 
sudo apt install -y vim vim-airline vim-airline-themes fonts-powerline
sudo pip3 install pytest numpy sklearn pandas scipy matplotlib
