# Contributing to Bank Smart Contract

感谢您对Bank智能合约项目的关注！我们欢迎各种形式的贡献。

## 如何贡献

### 🐛 报告Bug

1. 查看现有的[Issues](../../issues)确保问题未被报告
2. 使用Bug报告模板创建新Issue
3. 提供详细的复现步骤和环境信息

### 💡 提出新功能

1. 查看现有的[Issues](../../issues)确保功能未被建议
2. 使用功能请求模板创建新Issue
3. 详细描述功能需求和使用场景

### 🔧 提交代码

1. Fork本仓库
2. 创建功能分支: `git checkout -b feature/amazing-feature`
3. 提交代码: `git commit -m 'Add amazing feature'`
4. 推送到分支: `git push origin feature/amazing-feature`
5. 创建Pull Request

## 开发指南

### 环境设置

```bash
# 克隆仓库
git clone https://github.com/your-username/bank-foundry.git
cd bank-foundry

# 安装Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 编译和测试
make build
make test
```

### 代码标准

#### Solidity代码规范

1. **命名约定**
   - 合约名: PascalCase (`Bank`)
   - 函数名: camelCase (`getBalance`)
   - 变量名: camelCase (`totalDeposits`)
   - 常量名: UPPER_SNAKE_CASE (`MAX_DEPOSIT`)

2. **注释规范**
   - 使用NatSpec注释
   - 所有public/external函数必须有注释
   - 复杂逻辑需要inline注释

3. **安全规范**
   - 使用`require`进行输入验证
   - 实现重入攻击防护
   - 遵循checks-effects-interactions模式

#### 测试规范

1. **测试覆盖率**
   - 所有public/external函数必须有测试
   - 边界条件测试
   - 错误场景测试

2. **测试命名**
   - 测试函数: `test<FunctionName><Scenario>`
   - 模糊测试: `testFuzz<FunctionName><Scenario>`

3. **测试结构**
   ```solidity
   function testDepositSuccess() public {
       // Arrange
       uint256 depositAmount = 1 ether;
       
       // Act
       vm.prank(user);
       bank.deposit{value: depositAmount}();
       
       // Assert
       assertEq(bank.getBalance(user), depositAmount);
   }
   ```

### 提交信息规范

使用[Conventional Commits](https://www.conventionalcommits.org/)格式:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### 类型
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式修改
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

#### 示例
```
feat(bank): add interest calculation feature

Implement compound interest calculation for deposits
- Add interest rate state variable
- Add calculateInterest() function
- Update deposit() to accrue interest

Closes #123
```

## Pull Request流程

### 提交前检查

1. **代码质量**
   ```bash
   make build        # 编译通过
   make test         # 所有测试通过
   make test-coverage # 覆盖率检查
   ```

2. **Gas优化**
   ```bash
   make test-gas     # 查看Gas报告
   ```

3. **安全检查**
   - 手动安全审查
   - 确保无新的安全漏洞

### PR描述

- 使用PR模板
- 详细描述变更内容
- 列出相关的Issue
- 说明测试情况

### 代码审查

所有PR需要经过代码审查:

1. **自动检查**
   - CI/CD流水线通过
   - 测试覆盖率维持
   - Gas成本检查

2. **人工审查**
   - 代码逻辑正确性
   - 安全性评估
   - 代码风格一致性

## 发布流程

### 版本命名

使用[Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- 例如: `1.0.0`, `1.1.0`, `1.1.1`

### 发布步骤

1. 更新版本号
2. 更新CHANGELOG.md
3. 创建Git tag
4. 发布到测试网
5. 创建GitHub Release

## 社区准则

### 行为准则

- 保持尊重和包容
- 专注于技术讨论
- 接受建设性反馈
- 帮助新贡献者

### 沟通渠道

- GitHub Issues: 问题报告和功能请求
- GitHub Discussions: 技术讨论
- Pull Requests: 代码贡献

## 安全政策

### 安全漏洞报告

如果发现安全漏洞:

1. **不要**在公开Issue中报告
2. 发送邮件到: [security@example.com]
3. 提供详细的漏洞信息
4. 等待回复和修复

### 负责任披露

我们承诺:
- 24小时内确认收到报告
- 10个工作日内提供初步评估
- 修复后公开致谢(如果您同意)

## 许可证

贡献代码即表示您同意在MIT许可证下发布您的贡献。

## 感谢

感谢所有贡献者的付出！每一个PR、Issue和讨论都让这个项目变得更好。

---

如有任何问题，请随时在Issues中询问或查看我们的[FAQ](./docs/FAQ.md)。
