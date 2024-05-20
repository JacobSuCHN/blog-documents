#!/bin/bash

DATE=`date`

# 添加所有变更到暂存区
git add -A

# 提交变更
git commit -m "$0 : $1 $DATE"

# 推送到GitHub仓库
git push origin master