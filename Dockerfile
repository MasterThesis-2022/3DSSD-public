FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu16.04

# Install generic dependencies
RUN apt-get update -y \
    && apt-get install build-essential \
    && apt-get install -y apt-utils git curl ca-certificates bzip2 tree htop wget \
    && apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev bmon iotop \
    && apt-get install -y gcc-5 g++-5 gfortran ffmpeg libsm6 libxext6

# Install boost
RUN wget https://jaist.dl.sourceforge.net/project/boost/boost/1.68.0/boost_1_68_0.tar.gz && \
    tar xzvf boost_1_68_0.tar.gz && \
    cp -r ./boost_1_68_0/boost /usr/include && \
    rm -rf ./boost_1_68_0 && \
    rm -rf ./boost_1_68_0.tar.gz 

# Install python
RUN apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE true # Configure Python not to try to write .pyc files on the import of source modules
ENV PYTHON_VERSION 3.6.10
RUN git clone https://github.com/yyuu/pyenv.git /root/.pyenv \
    && cd /root/.pyenv \
    && git checkout `git describe --abbrev=0 --tags` \
    && echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(pyenv init -)"'               >> ~/.bashrc
RUN pyenv install $PYTHON_VERSION
RUN pyenv global $PYTHON_VERSION
# RUN apt-get install -y software-properties-common \
# && add-apt-repository ppa:jonathonf/python-3.6 \ 
# && apt-get update \
# && apt-get install -y python3.7 python3.7-dev python3.7-distutils
RUN apt-get remove -y python python2.7 libpython2.7 python2.7-minimal libpython2.7-stdlib libpython2.7-minimal  python-pip-whl
#RUN apt-get install -y python3.6-distutils python3-apt python3.6-dev
RUN ln -sv /usr/bin/python3 /usr/bin/python
RUN curl https://bootstrap.pypa.io/pip/3.6/get-pip.py | python
RUN ln -sv $PYENV_ROOT/versions/$PYTHON_VERSION/bin/pip /usr/bin/pip
RUN ln -sv $PYENV_ROOT/versions/$PYTHON_VERSION/bin/pip /usr/bin/pip3

# Compile tensorflow    
ENV TENSORFLOW_VERSION 1.14
RUN mkdir /tensorflow-build
RUN git clone -b r$TENSORFLOW_VERSION https://github.com/tensorflow/tensorflow /tensorflow-build

  # Install bazel
RUN apt install -y pkg-config zip g++ zlib1g-dev unzip
RUN curl --output /tmp/bazel-install.sh -SL https://github.com/bazelbuild/bazel/releases/download/0.24.1/bazel-0.24.1-installer-linux-x86_64.sh
RUN chmod +x /tmp/bazel-install.sh
RUN /tmp/bazel-install.sh

#RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
#RUN mv bazel.gpg /etc/apt/trusted.gpg.d/
#RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
#RUN apt update
#RUN apt list | grep bazel
#RUN apt install bazel-0.24.1

WORKDIR /tensorflow-build
#RUN ./configure
#RUN cat ./configure.py
#RUN exit 1
#RUN bazel build --config=cuda //tensorflow/tools/pip_package:build_pip_package
#RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
#RUN pip install /tmp/tensorflow_pkg/tensorflow-$TENSORFLOW_VERSION-tags.whl
# Copy static assets
#COPY ./compile_all.sh /3dssd/compile_all.sh
#COPY ./configs /3dssd/configs
#COPY ./lib /3dssd/lib
#COPY ./mayavi /3dssd/mayavi

# Install python packages
#RUN python -m pip install --upgrade setuptools wheel scikit-build Cython
#COPY requirements.txt /requirements.txt
#RUN PIP_INSTALL="python -m pip --no-cache-dir install" \
#    && $PIP_INSTALL -r requirements.txt

#RUN find / -type d -name "tensorflow"
#ENV TENSORFLOW_PATH=/usr/lib/python3.6/site-packages/tensorflow
#ENV CUDA_PATH=/usr/local/cuda-10.0

#RUN ln -s $CUDA_PATH/lib64/libcudart.so /usr/lib/libcudart.so

#WORKDIR /3dssd
#RUN bash compile_all.sh $TENSORFLOW_PATH $CUDA_PATH

#ENV PYTHONPATH=$PYTHONPATH:/3dssd/lib:/3dssd/mayavi
