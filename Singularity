Bootstrap: docker
From: ubuntu:18.04


%setup
  mkdir -p ${SINGULARITY_ROOTFS}/opt/fsthalconnMNI


%files
  bin                          /opt/fsthalconnMNI
  src                          /opt/fsthalconnMNI
  build                        /opt/fsthalconnMNI
  README.md                    /opt/fsthalconnMNI

 
%labels
  Maintainer baxter.rogers@vanderbilt.edu

%post

  fsl_version=5.0.11

  apt-get update

  # Workaround for filename case collision in linux-libc-dev
  # https://stackoverflow.com/questions/15599592/compiling-linux-kernel-error-xt-connmark-h
  # https://superuser.com/questions/1238903/cant-install-linux-libc-dev-in-ubuntu-on-windows
  apt-get install -y binutils xz-utils 
  mkdir pkgtemp && cd pkgtemp
  apt-get download linux-libc-dev
  ar x linux-libc-dev*deb
  tar xJf data.tar.xz
  tar cJf data.tar.xz ./usr
  ar rcs linux-libc-dev*.deb debian-binary control.tar.xz data.tar.xz
  dpkg -i linux-libc-dev*.deb
  cd .. && rm -r pkgtemp

  # FSL dependencies, h/t https://github.com/MPIB/singularity-fsl
  #    debian vs ubuntu:
  #            libjpeg62-turbo ->  libjpeg-turbo8
  #            libmng1         ->  libmng2
  apt-get -y install wget python-minimal libgomp1 ca-certificates \
          libglu1-mesa libgl1-mesa-glx libsm6 libice6 libxt6 \
          libjpeg-turbo8 libpng16-16 libxrender1 libxcursor1 \
          libxinerama1 libfreetype6 libxft2 libxrandr2 libmng2 \
          libgtk2.0-0 libpulse0 libasound2 libcaca0 libopenblas-base \
          bzip2 dc bc
  apt-get -y install language-pack-en

  # Get and install main FSL package
  cd /usr/local
  wget -q https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-${fsl_version}-centos7_64.tar.gz
  tar zxf fsl-${fsl_version}-centos7_64.tar.gz
  rm fsl-${fsl_version}-centos7_64.tar.gz
  
  # FSL setup
  export FSLDIR=/usr/local/fsl
  . ${FSLDIR}/etc/fslconf/fsl.sh
  export PATH=${FSLDIR}/bin:${PATH}

  # Run the FSL python installer
  ${FSLDIR}/etc/fslconf/fslpython_install.sh
  
  # Remove non-working old fsleyes
  rm -r $FSLDIR/bin/fsleyes $FSLDIR/bin/FSLeyes

  # Run the 6.0.2 python installer to get fsleyes in /usr/local/fsl-6.0.2/fslpython/envs/fslpython/bin/fsleyes
  /opt/src/fslconf-local/fslpython_install_local.sh
  
  # Update fsleyes per https://users.fmrib.ox.ac.uk/~paulmc/fsleyes/userdoc/latest/install.html
  #/usr/local/fsl-6.0.2/fslpython/bin/conda install -n fslpython -c conda-forge fsleyes

  # Download the Matlab Compiled Runtime installer, install, clean up
  mkdir /MCR
  wget -nv -P /MCR http://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip
  unzip /MCR/MCR_R2017a_glnxa64_installer.zip -d /MCR/MCR_R2017a_glnxa64_installer
  /MCR/MCR_R2017a_glnxa64_installer/install -mode silent -agreeToLicense yes
  rm -r /MCR/MCR_R2017a_glnxa64_installer /MCR/MCR_R2017a_glnxa64_installer.zip
  rmdir /MCR

  # Install Freesurfer. We just need mri_convert
  wget -nv -P /usr/local https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/dev/freesurfer-linux-centos7_x86_64-dev.tar.gz
  cd /usr/local
  tar -zxf freesurfer-linux-centos7_x86_64-dev.tar.gz
  rm freesurfer-linux-centos7_x86_64-dev.tar.gz
  mkdir -p /usr/local/fstemp/bin
  cp /usr/local/freesurfer/bin/mri_convert      /usr/local/fstemp/bin
  cp /usr/local/freesurfer/build-stamp.txt      /usr/local/fstemp
  cp /usr/local/freesurfer/SetUpFreeSurfer.sh   /usr/local/fstemp
  cp /usr/local/freesurfer/FreeSurferEnv.sh     /usr/local/fstemp
  rm -fr /usr/local/freesurfer
  mv /usr/local/fstemp /usr/local/freesurfer

  # Singularity-hub doesn't work with github LFS (it gets the pointer info instead 
  # of the actual file) so we get the compiled matlab executable via direct download.
  # Not needed for local build.
  rm /opt/fsthalconnMNI/bin/spm12.ctf
  wget -nv -P /opt/fsthalconnMNI/bin https://github.com/baxpr/fsthalconnMNI/raw/master/bin/spm12.ctf

  # Also need a "dry run" of SPM executable to avoid directory creation errors later.
  /opt/fsthalconnMNI/bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v92 quit
 
  # Headless X11 support
  apt-get install -y xvfb
  
  # PNG and PDF tools
  apt-get install -y ghostscript imagemagick
  
  # Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
  sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
    /etc/ImageMagick-6/policy.xml
  
  # Create input/output directories for binding
  mkdir /INPUTS && mkdir /OUTPUTS

  # Clean up
  apt-get clean && apt-get -y autoremove

%environment

  # FSL
  export FSLDIR=/usr/local/fsl
  . ${FSLDIR}/etc/fslconf/fsl.sh
  export PATH=${FSLDIR}/bin:/usr/local/fsl-6.0.2/fslpython/envs/fslpython/bin/:${PATH}

 # Freesurfer
 export FREESURFER_HOME=/usr/local/freesurfer

  # Pipeline
  export PATH=/opt/src:${PATH}


%runscript
  xwrapper.sh "$@"

