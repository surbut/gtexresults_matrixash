# Docker container for reproducing the MASH paper (Urbut, Wang and Stephens 2017)

# Pull base image: it configures basic R and Python environments to run related pipelines
FROM gaow/dsc

# :)
MAINTAINER Gao Wang, gaow@uchicago.edu

# Install tools required by MASH
ENV SFAVERSION 1.0
ENV MASHVERSION 0.2-1
ENV EDVERSION master

WORKDIR /tmp
ADD http://stephenslab.uchicago.edu/assets/software/sfa/sfa${SFAVERSION}.tar.gz sfa.tar.gz
ADD https://github.com/stephenslab/mashr-paper/archive/v${MASHVERSION}.zip mash.zip
ADD https://github.com/jobovy/extreme-deconvolution/archive/${EDVERSION}.zip ed.zip

## Install OpenMP and gsl
RUN apt-get -qq update \
    && apt-get -qq -y install libgomp1 libgsl-dev \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

## Install Extreme Deconvolution R package
RUN unzip ed.zip && cd extreme-deconvolution-${EDVERSION} \
    && make && make rpackage && R CMD INSTALL ExtremeDeconvolution_1.3.tar.gz

## Install SFA
RUN ln -s /lib/x86_64-linux-gnu/libgsl.so.23.0.0 /lib/x86_64-linux-gnu/libgsl.so.0
RUN tar zxf sfa.tar.gz && mv sfa /opt

## Install MASH code to reproduce the paper
RUN unzip mash.zip && mv mashr-paper-${MASHVERSION}/R /opt/mash-paper
RUN install.r mvtnorm SQUAREM gplots colorRamps ashr

## Clean up
RUN rm -rf *

# Default command
CMD ["bash"]