# MindHub 贡献指南

感谢您对MindHub项目的关注！我们欢迎任何形式的贡献，包括但不限于代码、文档、问题报告、讨论和建议。

## 开发流程

1. **Fork仓库**：首先，在GitHub上fork本仓库到您自己的账户。

2. **克隆仓库**：将您fork的仓库克隆到本地。
   ```bash
   git clone https://github.com/YOUR-USERNAME/MindHub.git
   cd MindHub
   ```

3. **创建分支**：为您的更改创建一个新分支。
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **进行更改**：在您的分支上进行必要的更改。

5. **提交更改**：提交您的更改并推送到您的fork。
   ```bash
   git add .
   git commit -m "Add: 简明描述您的更改"
   git push origin feature/your-feature-name
   ```

6. **创建Pull Request**：在GitHub上从您的分支创建一个PR到主仓库的main分支。

## 提交规范

为了保持提交历史的清晰和一致，我们建议使用以下提交前缀：

- `Add:` 添加新功能或文件
- `Fix:` 修复bug
- `Update:` 更新现有功能
- `Remove:` 删除文件或功能
- `Refactor:` 重构代码
- `Docs:` 更新文档
- `Test:` 添加或修改测试
- `Style:` 代码风格更改（不影响代码功能）
- `Perf:` 性能改进

## 代码风格

- 遵循Swift标准代码风格
- 使用有意义的变量和函数名
- 添加必要的注释说明复杂的逻辑
- 保持代码简洁和模块化

## 问题报告

如果您发现了bug或有改进建议，请通过GitHub Issues提交。在提交问题时，请包含：

- 问题的简明描述
- 复现步骤
- 预期行为和实际行为
- 相关的环境信息（iOS版本、设备类型等）
- 如果可能，添加截图或视频

## 文档更新

如果您发现文档中有错误或遗漏，欢迎提交PR进行更正或补充。

## 注意事项

- 确保您的更改不会破坏现有功能
- 提交PR前请自行测试您的更改
- 尊重其他贡献者，保持友好和建设性的沟通

感谢您的贡献，我们期待您的参与！ 