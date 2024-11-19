#!/bin/bash

count=0  # 初始化计数器
while true; do
  count=$((count + 1))  # 增加计数器

  # 执行 radamsa 并将输出打印到终端
  echo "Executing radamsa (Iteration: $count)"
  # /home/test/xfuzz_work/radamsa/bin/radamsa seed | tee input.txt  # 使用 tee 同时输出到终端和文件

  /home/test/xfuzz_work/radamsa/bin/radamsa seed > input.txt
  # 执行 fuzzgoat 并将输出重定向到 /dev/null
  ./fuzzgoat input.txt > /dev/null 2>&1

  # 检查上一个命令的退出状态
  if [ $? -gt 127 ]; then
    cp input.txt "crash-$(date +%s.%N).txt"  # 修改日期格式，确保兼容性
    echo "Crash found!"
  fi
done
