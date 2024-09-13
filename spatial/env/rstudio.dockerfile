FROM  rocker/geospatial
USER root

# https://zenn.dev/nononoexe/articles/recommendations-for-spatial-analysis-with-r

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

RUN sed -i '$d' /etc/locale.gen \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# 日本語フォントのインストール 
RUN apt-get update && \
    apt-get install -y \
    fonts-ipaexfont fonts-noto-cjk \
    libpng-dev libjpeg-dev libfreetype6-dev libglu1-mesa-dev libgl1-mesa-dev pandoc zlib1g-dev libicu-dev libgdal-dev gdal-bin libgeos-dev libproj-dev \
    libboost-filesystem-dev mecab libmecab-dev mecab-ipadic mecab-ipadic-utf8 texlive-xetex texlive-latex-base sudo htop

#japanese font
RUN install2.r --error --skipmissing --skipinstalled extrafont remotes
RUN R -q -e 'extrafont::font_import(prompt = FALSE)'
RUN R -q -e 'install.packages("devtools")'

RUN mkdir /work && \
    mkdir /work/env/

#compose fileからのディレクトリの位置。フォルダはコピーされない
COPY ./shell/ /work/env/

WORKDIR /work/env/
RUN sudo ./Rlibrary.sh

#catdap2ext
RUN mkdir /work/catdap
WORKDIR /work/catdap

RUN install2.r --error --skipmissing --skipinstalled catdap && \
    curl -OL https://jasp.ism.ac.jp/ism/catdap2ext/catdap2ext_0.2.0.zip && \
    R -q -e 'install.packages("catdap2ext_0.2.0.tar.gz")'
