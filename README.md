# Mojo-ActivePerl
基于ActivePerl打包的而成的包含perl-5.22+cpanm+Mojo-Webqq+Mojo-Weixin的完整运行环境

##系统要求：
* Unix/Linux x86_64
* glibc 2.15+

##包含的组件：
* Perl 5.22.1
* Mojo-Webqq 1.7.5
* Mojo-Weixin 1.0.8
* Mojo-IRC-Server-Chinese 1.7.7
* Mojolicious 6.57
* cpanm 1.7.4

##安装方法：

1. 下载[压缩包](https://github.com/sjdy521/Mojo-ActivePerl/blob/master/Mojo-ActivePerl-5.22.1.2201-x86_64-linux-glibc-2.15-299574.tar.gz)

        $ wget https://github.com/sjdy521/Mojo-ActivePerl/blob/master/Mojo-ActivePerl-5.22.1.2201-x86_64-linux-glibc-2.15-299574.tar.gz

2. 解压到任意目录
    
        $ tar zxf Mojo-ActivePerl-5.22.1.2201-x86_64-linux-glibc-2.15-299574.tar.gz
        $ cd Mojo-ActivePerl-5.22.1.2201-x86_64-linux-glibc-2.15-299574

3. 运行安装脚本，指定安装目录(需要有权限创建和写入)

        $ sh install.sh --prefix ~/Mojo-ActivePerl  #这里以~/Mojo-ActivePerl目录为例

4. 把perl和cpanm路径添加到PATH环境变量（或不设置环境变量，直接使用绝对路径）

        $ ~/Mojo-ActivePerl/bin/perl
        $ ~/Mojo-ActivePerl/bin/cpanm

