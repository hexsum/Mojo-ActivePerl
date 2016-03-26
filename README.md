# Mojo-ActivePerl
基于ActivePerl打包的而成的包含Perl-5.22+cpanm+Mojo-Webqq+Mojo-Weixin的完整运行环境

##系统要求：
* Unix/Linux x86_64
* glibc 2.15+

##包含的组件：
* Perl 5.22.1
* Mojo-Webqq 1.7.6
* Mojo-Weixin 1.0.8
* Mojo-IRC-Server-Chinese 1.7.7
* Mojolicious 6.57
* cpanm 1.7.4

##安装方法：

1. 下载[ZIP压缩包](https://github.com/sjdy521/Mojo-ActivePerl/archive/master.zip)(约43M)

        $ wget https://github.com/sjdy521/Mojo-ActivePerl/archive/master.zip -O Mojo-ActivePerl-master.zip

2. 解压到当前目录并进入目录
    
        $ unzip Mojo-ActivePerl-master.zip
        $ cd Mojo-ActivePerl-master

3. 运行安装脚本，指定安装目录(需要有权限创建和写入)

        $ sh install.sh --prefix /usr/local/Mojo-ActivePerl  #这里以/usr/local/Mojo-ActivePerl目录为例

4. 把如下perl和cpanm所在目录(/usr/local/Mojo-ActivePerl/bin/)添加到PATH环境变量（或不设置环境变量，直接使用绝对路径）

        $ /usr/local/Mojo-ActivePerl/bin/perl
        $ /usr/local/Mojo-ActivePerl/bin/cpanm

