# MindHub Git设置指南

按照以下步骤将MindHub项目上传到GitHub：

## 准备工作

1. 确保您已在GitHub上创建了一个名为"MindHub"的空仓库
2. 确保您的Git已正确配置了用户名和邮箱：
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## 仓库当前状态

本地Git仓库已初始化，包含两次提交：
- 初始提交：包含基本项目文件、文档和配置
- 清理提交：移除了临时文件和部署脚本，更新了文档

接下来，您需要将本地仓库推送到GitHub：

```bash
# 添加GitHub远程仓库
git remote add origin https://github.com/lizixi-0x2F/MindHub.git

# 推送到GitHub
git push -u origin main
```

## 可能需要的其他命令

```bash
# 如果需要使用个人访问令牌(PAT)而不是密码
git remote set-url origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/lizixi-0x2F/MindHub.git

# 如果您更喜欢使用SSH而不是HTTPS
git remote set-url origin git@github.com:lizixi-0x2F/MindHub.git
```

## 后续更新

每次更改后提交和推送：

```bash
git add .
git commit -m "Update: 您的更改描述"
git push
```

## 注意事项

- 已确保崩溃日志、临时文件和敏感信息被.gitignore排除
- 项目已完成清理，包括：
  - 移除了临时部署脚本
  - 删除了崩溃日志目录
  - 更新了变更日志
  - 完善了文档
- 首次推送可能需要验证GitHub凭据 