---
title: 使用简单shell脚本管理DST服务器
date: 2017-11-20 22:50:30
tags: [Game,Linux,shell]
categories: [Linux,Server]
---

## DST饥荒游戏服务器搭建脚本
上一次写了饥荒服务器的搭建教程，发现很多小伙伴表示都不会用啊，后来想想命令行操作确实有些繁琐，于是乎就想着把这些初始的游戏server安装配置自动化构建起来,那么什么最适合简单的服务器自动化命令操作呢？
在Linux服务器上这个答案显然是Shell脚本,(因为功能很少很简单还用不到python 233)
对于大家伙来说当然越简单使用当然越好哇，这样想了想,然后就有了:
> go.sh

这个思想很简单，就是将更新服务器源到获取steamcmd到安装dst server版，建立文件夹等操作串联起来:

<!--more-->

```bash
#!/bin/bash

sudo apt-get update
sudo apt-get install lib32gcc1 libcurl4-gnutls-dev:i386 screen

mkdir ~/steamcmd
cd ~/steamcmd

wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir ~/dst +app_update 343050 validate +quit

cp ~/steamcmd/linux32/libstdc++.so.6 ~/dst/bin/lib32/

cd ~/dst/bin
echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > overworld.sh
echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Caves > cave.sh

mkdir -p ~/.klei/DoNotStarveTogether/MyDediServer

cd ~

if [[ `echo $?` -eq 0 ]]; then
	echo -e "\033[42;30m ### 游戏服务器初始化完成,请放入配置文件并执行 ./dst \033[0m"
else
	echo -e "\033[31m 执行出现了错误，可能因为网络不好，请尝试重新执行一次 \033[0m"	
fi

```

#### 用法: source go.sh

***

## DST饥荒游戏服务器管理脚本
随着游戏内时间的增加，饥荒服务器往往要经常更新，这个时候总是要登陆服务器运行一大串命令，就显得很是麻烦，于是我就搞了个简单管理脚本
> dst.sh

主要原理就是将管理功能分解，比如启动服务，停止进程，重启，删除游戏记录文件，更新服务器等等..
一次输入交互，然后选择不同目标函数执行即可.

```bash
#!/bin/bash

master='.klei/DoNotStarveTogether/MyDediServer/Master/'
cave='.klei/DoNotStarveTogether/MyDediServer/Caves/'

dst_dir=(${master} ${cave})

stop(){
	ps -ef|grep dontstarve|awk '{print $2}'|xargs kill -9
	if [[ -z `ps -ef | grep -v grep |grep -v "dst.sh"|grep "dontstarve"|sed -n '1P'|awk '{print $2}'` ]]; then
		echo -e "\033[32m ##: 饥荒服务器停止成功!! \033[0m"
	fi
}

del(){
	stop
	for i in ${dst_dir[@]};
	do
		if [[ -d ${i}"save" ]]; then
			rm -r ${i}"save"&&rm -r `find ${i} -name "*.txt"` && rm -r ${i}"backup"
			echo -e "\033[32m ##: ${i}'s 文件已经删除! \033[0m"
		fi
	done
}

goMaster(){
	cd ~/dst/bin

	if [[ -z `ps -ef | grep -v grep |grep -v "dst.sh"|grep "Master"|sed -n '1P'|awk '{print $2}'` ]]; then
		screen -dm sh overworld.sh && if [[ `echo $?` -eq 0 ]]; 
		then
			echo -e "\033[36m ##: 地上成功启动... \033[0m"
		fi
	else
		echo -e "\033[31m !!! 地上正在运行中!!! \033[0m"
	fi
	
}

goCaves(){
	cd ~/dst/bin
	
	if [[ -z `ps -ef | grep -v grep |grep -v "dst.sh"|grep "Caves"|sed -n '1P'|awk '{print $2}'` ]]; then
		screen -dm sh cave.sh && if [[ `echo $?` -eq 0 ]]; then
			echo -e "\033[36m ##: 洞穴启动成功... \033[0m"
		fi
	else
		echo -e "\033[31m !!!洞穴正在运行中!!! \033[0m"
	fi
}

go(){
	goMaster
	goCaves
}

restart(){
	stop
	go
}

reset(){
	del
	go
}

updst(){
	stop
	~/steamcmd/steamcmd.sh +login anonymous +force_install_dir ~/dst +app_update 343050 validate +quit
	if [[ `echo $?` -eq 0 ]]; then
		echo -e "\033[46;37m ##: 饥荒游戏版本更新成功!! \033[0m"
	fi
}

main(){

	echo -e "\033[42;30m ### 饥荒Sever管理脚本 ### \033[0m"
	echo -e "\033[32m 0. \033[0m 启动地上+洞穴"
	echo -e "\033[32m 1. \033[0m 只启动地上"
	echo -e "\033[32m 2. \033[0m 只启动洞穴"
	echo -e "\033[32m 3. \033[0m 停止饥荒游戏进程"
	echo -e "\033[32m 4. \033[0m 删除游戏存档记录"                                                                                             
	echo -e "\033[32m 5. \033[0m 重启游戏(非重置),可以更新mod"
	echo -e "\033[32m 6. \033[0m 重置饥荒游戏,将删除游戏存档记录"
	echo -e "\033[32m 7. \033[0m 更新饥荒游戏版本"

	read -p "输入数字,回车确认选择: " choose
		case $choose in
			0 ) go
				;;
			1 ) goMaster
				;;
			2 ) goCaves
				;;
			3 ) stop
				;;
			4 ) del
				;;
			5 ) restart
				;;
			6 ) reset
				;;
			7 ) updst
				;;
			* ) echo -e "\033[31m 请输入下列正确的数字选项!! \033[0m"
				main
				;;
		esac
}

main

```

#### 用法： ./dst.sh

##### 这样日常再维护游戏服务器就很方便啦~

详情见:--->[DST-Server-Build](https://github.com/qwertyuiop6/DST-Server-Build)
