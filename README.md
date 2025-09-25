# Bank Smart Contract

一个基于以太坊的银行智能合约，支持存款、管理员提取和排行榜功能。

## 功能特性

- ✅ **存款功能**: 用户可以通过Metamask等钱包直接向合约地址发送ETH进行存款
- ✅ **余额记录**: 合约记录每个地址的累计存款金额
- ✅ **管理员提取**: 仅合约所有者可以提取合约中的资金
- ✅ **排行榜**: 实时维护存款金额前3名的用户列表
- ✅ **安全保护**: 包含重入攻击防护和访问控制

## 技术栈

- **Solidity**: ^0.8.19
- **Foundry**: 开发和测试框架
- **Forge**: 编译和测试工具
- **Anvil**: 本地测试网络

## 项目结构

```
bank-foundry/
├── src/
│   ├── Bank.sol              # 主合约
│   └── interfaces/
│       └── IBank.sol         # 合约接口
├── test/
│   ├── Bank.t.sol            # 单元测试
│   ├── BankFuzz.t.sol        # 模糊测试
│   └── utils/
│       └── TestHelper.sol    # 测试辅助工具
├── script/
│   ├── Deploy.s.sol          # 部署脚本
│   └── interactions/
│       ├── Deposit.s.sol     # 存款交互脚本
│       └── Withdraw.s.sol    # 提取交互脚本
├── foundry.toml              # Foundry配置
└── README.md                 # 项目文档
```

## 快速开始

### 1. 安装依赖

```bash
# 安装Foundry (如果尚未安装)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 克隆项目
git clone <repository-url>
cd bank-foundry

# 安装依赖 (如果需要)
forge install
```

### 2. 编译合约

```bash
forge build
```

### 3. 运行测试

```bash
# 运行所有测试
forge test

# 运行特定测试文件
forge test --match-contract BankTest

# 运行模糊测试
forge test --match-contract BankFuzzTest

# 查看测试覆盖率
forge coverage

# 查看Gas报告
forge test --gas-report
```

### 4. 本地部署测试

```bash
# 启动本地测试网络
anvil

# 在新终端中部署合约
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### 5. 环境配置

复制环境变量模板：
```bash
cp env.example .env
```

编辑 `.env` 文件，填入真实的配置：
```bash
# 网络RPC URLs
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your-api-key

# 私钥 (请使用测试私钥，不要使用真实资金的私钥)
PRIVATE_KEY=your-private-key
ADMIN_PRIVATE_KEY=your-admin-private-key
USER_PRIVATE_KEY=your-user-private-key

# Etherscan API密钥
ETHERSCAN_API_KEY=your-etherscan-api-key
```

## 部署到测试网

### Sepolia测试网部署

```bash
# 部署到Sepolia测试网
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# 验证合约
forge verify-contract <CONTRACT_ADDRESS> src/Bank.sol:Bank --etherscan-api-key $ETHERSCAN_API_KEY --chain sepolia
```

## 合约交互

### 存款操作

```bash
# 设置环境变量
export BANK_CONTRACT_ADDRESS=<deployed-contract-address>
export DEPOSIT_AMOUNT=1000000000000000000  # 1 ETH in wei

# 执行存款
forge script script/interactions/Deposit.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

### 管理员提取

```bash
# 设置提取金额
export WITHDRAW_AMOUNT=500000000000000000  # 0.5 ETH in wei

# 执行提取 (仅管理员)
forge script script/interactions/Withdraw.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
```

## 合约API

### 主要函数

- `deposit()`: 存款函数
- `withdraw(uint256 amount)`: 管理员提取函数  
- `getBalance(address user)`: 查询用户余额
- `getTopDepositors()`: 获取前3名存款用户
- `getTotalDeposits()`: 获取总存款额
- `getContractBalance()`: 获取合约余额

### 事件

- `Deposit(address indexed user, uint256 amount, uint256 newBalance)`
- `Withdraw(address indexed admin, uint256 amount)`
- `TopDepositorsUpdated(address[3] topUsers, uint256[3] topAmounts)`

## 安全特性

1. **访问控制**: 只有合约所有者可以提取资金
2. **重入保护**: 防止重入攻击
3. **输入验证**: 验证存款和提取金额
4. **溢出保护**: Solidity 0.8+内置溢出保护

## 测试覆盖

- ✅ 基本存款和提取功能
- ✅ 排行榜更新逻辑
- ✅ 权限控制测试
- ✅ 边界条件测试
- ✅ 模糊测试
- ✅ Gas优化测试
- ✅ 安全性测试

## Gas优化

合约已经过Gas优化：
- 高效的排行榜算法
- 最小化状态变量读写
- 优化的排序逻辑

## 开发指南

### 添加新功能

1. 在 `src/Bank.sol` 中实现新功能
2. 在 `src/interfaces/IBank.sol` 中添加接口
3. 在 `test/Bank.t.sol` 中添加测试
4. 运行测试确保功能正常

### 提交流程

1. 运行所有测试: `forge test`
2. 检查代码覆盖率: `forge coverage`
3. 检查Gas使用: `forge test --gas-report`
4. 提交代码

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 注意事项

⚠️ **重要提醒**:
- 这是一个演示项目，不建议在主网上使用真实资金
- 部署前请进行充分的安全审计
- 私钥管理请遵循最佳实践
- 测试网部署建议使用测试ETH