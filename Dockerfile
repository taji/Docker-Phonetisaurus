FROM ubuntu

MAINTAINER Todd Garza "todd.garza@gmail.com"

WORKDIR /root

# DEBIAN_FRONTEND=noninterctive suprresses unneeded warnings:
# http://askubuntu.com/questions/506158/unable-to-initialize-frontend-dialog-when-using-ssh

ENV DEBIAN_FRONTEND=noninteractive

# Most of the install process below is taken from here:
#        https://github.com/AdolfVonKleist/Phonetisaurus

# Eventually, condense provision to one RUN command as best practice:  https://docs.docker.com/articles/dockerfile_best-practices/

# But for now, take it piece by peice.
RUN printf "\nPROVISION 1: UPDATING UBUNTU AND INSTALLING PACKAGES\n" && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    nano \
    git \
    wget \
    tar \
    python \
    python-dev \
    python-setuptools \
    python-twisted && \
    cd /root

RUN printf "\nDOWNLOADING AND INSTALLING OPEN FST\n" && \
    wget http://openfst.org/twiki/pub/FST/FstDownload/openfst-1.4.1.tar.gz && \
    tar -xvzf openfst-1.4.1.tar.gz && \
    cd openfst-1.4.1 && \
    ./configure --enable-compact-fsts --enable-const-fsts --enable-far --enable-lookahead-fsts --enable-pdt --enable-ngram-fsts && \
    make install && \
    cd /root

RUN printf "\nDOWNLOADING AND INSTALLING OPEN NGRAM\n" && \
    wget http://openfst.cs.nyu.edu/twiki/pub/GRM/NGramDownload/opengrm-ngram-1.2.1.tar.gz && \
    tar -xvzf opengrm-ngram-1.2.1.tar.gz && \
    cd opengrm-ngram-1.2.1 && \
    ./configure && \
    make install && \
    cd /root

ENV LD_LIBRARY_PATH /usr/local/lib

RUN printf "\nDOWNLOADING AND INSTALLING PHONETISAURUS\n" && \
    git clone https://github.com/AdolfVonKleist/Phonetisaurus.git phonetisaurus && \
    cd phonetisaurus/src && \
    make -j 4 && \
    make install && \
    cd .. && \
    sudo python setup.py install && \
    cd /root

# Note that the command line "phonetisaurus-arpa2wfst-omega..." below returns 1 but is successful. 
# So we add the || true to ignore the bad return code. 

RUN printf "\nDOWNLOADING AND BUILDING CMU DICT FST MODEL\n" && \
    cd phonetisaurus/script/ && \
    wget https://www.dropbox.com/s/vlmlfq52rpbkniv/cmu-eg.me-kn.8g.arpa.gz?dl=0 -O test.arpa.gz && \
    gunzip test.arpa.gz && \
    phonetisaurus-arpa2wfst-omega --lm=test.arpa --ofile=test.fst || true

RUN   printf "\nPROVISION COMPLETE\n"
CMD \bin\bash
