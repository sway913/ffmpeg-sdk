#! /bin/sh
#
# init-config.sh
# 
# Created by yuqilin on 11/26/2018
# Copyright (C) 2018 yuqilin <iyuqilin@foxmail.com>
#

if [ ! -f 'config/module.sh' ]; then
    cp config/module-lite.sh config/module.sh
fi
