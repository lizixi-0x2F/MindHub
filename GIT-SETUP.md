# MindHub Git设置指南

按照以下步骤将MindHub项目上传到GitHub：

## 准备工作

1. 确保您已在GitHub上创建了一个名为"MindHub"的空仓库
2. 确保您的Git已正确配置了用户名和邮箱：
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## 初始化并上传代码

在项目根目录执行以下命令：

```bash
# 初始化Git仓库
git init

# 添加所有文件（.gitignore会过滤不需要的文件）
git add .

# 首次提交
git commit -m "Initial commit: MindHub情绪日记应用"

# 添加GitHub远程仓库
git remote add origin https://github.com/lizixi-0x2F/MindHub.git

# 如果您的默认分支是master而不是main，可以重命名
git branch -M main

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

- 确保崩溃日志、临时文件和敏感信息已被.gitignore排除
- 首次推送可能需要验证GitHub凭据 