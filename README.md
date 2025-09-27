# Bank Smart Contract

一个基于以太坊的银行智能合约，支持存款、管理员提取和排行榜功能。

## 功能特性

### Bank合约 (基础版)
- ✅ **存款功能**: 用户可以通过Metamask等钱包直接向合约地址发送ETH进行存款
- ✅ **余额记录**: 合约记录每个地址的累计存款金额
- ✅ **管理员提取**: 仅合约所有者可以提取合约中的资金
- ✅ **排行榜**: 实时维护存款金额前3名的用户列表
- ✅ **安全保护**: 包含重入攻击防护和访问控制

### BigBank合约 (增强版)
- ✅ **最小存款限制**: 仅支持 ≥0.001 ether 的存款，使用modifier权限控制
- ✅ **继承Bank功能**: 完全兼容Bank合约的所有功能
- ✅ **Admin合约管理**: 支持Admin合约调用withdraw()方法
- ✅ **双重管理权限**: 合约owner和Admin合约都可以提取资金

### Admin合约 (管理系统)
- ✅ **独立所有权**: Admin合约有自己的Owner
- ✅ **BigBank管理**: 可以接收BigBank合约的管理权并操作
- ✅ **adminWithdraw功能**: 实现adminWithdraw(IBank bank)方法
- ✅ **IBank接口调用**: 通过IBank接口调用withdraw方法
- ✅ **资金转移**: 将Bank合约资金转移到Admin合约地址

## 技术栈

- **Solidity**: ^0.8.19
- **Foundry**: 开发和测试框架
- **Forge**: 编译和测试工具
- **Anvil**: 本地测试网络

## 项目结构

```
bank-foundry/
├── src/
│   ├── Bank.sol              # 基础Bank合约(实现IBank接口)
│   ├── BigBank.sol           # 增强版BigBank合约(继承Bank + 最小存款限制)
│   ├── Admin.sol             # Admin管理合约(adminWithdraw功能)
│   └── interfaces/
│       └── IBank.sol         # Bank合约接口定义
├── test/
│   ├── Bank.t.sol            # Bank合约单元测试
│   ├── BankFuzz.t.sol        # Bank合约模糊测试
│   ├── NewWorkflow.t.sol     # 完整工作流程测试
│   └── utils/
│       └── TestHelper.sol    # 测试辅助工具
├── script/
│   ├── Deploy.s.sol          # Bank合约部署脚本
│   ├── DeployLatestRequirements.s.sol  # 最新需求部署脚本
│   └── interactions/
│       ├── Deposit.s.sol     # 存款交互脚本
│       └── Withdraw.s.sol    # 提取交互脚本
├── foundry.toml              # Foundry配置
├── Makefile                  # 构建和部署工具
├── GITHUB_SETUP.md           # GitHub集成指南
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

# 运行完整工作流程测试
forge test --match-contract NewWorkflowTest -vv

# 查看测试覆盖率
forge coverage

# 查看Gas报告
forge test --gas-report

# 使用Makefile命令 (推荐)
make test              # 运行所有测试
make test-workflow     # 运行工作流程测试
make build             # 编译合约
make deploy-local      # 本地部署
```

### 4. 本地部署测试

```bash
# 启动本地测试网络
anvil

# 在新终端中部署Bank合约
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 或部署最新需求的完整合约组合(BigBank + Admin)  
forge script script/DeployLatestRequirements.s.sol --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
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

## 最新需求工作流程

### 完整的BigBank + Admin工作流程

按照最新需求，项目实现了以下架构：

1. **Bank合约** - 实现IBank接口的基础合约
2. **BigBank合约** - 继承Bank，添加≥0.001 ether最小存款限制
3. **Admin合约** - 有自己的Owner，实现adminWithdraw(IBank bank)功能

#### 工作流程步骤：

```bash
# 1. 部署所有合约
forge script script/DeployLatestRequirements.s.sol --rpc-url http://localhost:8545 --broadcast

# 2. BigBank合约管理权自动转移给Admin合约(部署脚本中完成)

# 3. 用户向BigBank存款(必须≥0.001 ether)
# 可以通过直接转账或调用deposit()函数

# 4. Admin合约Owner调用adminWithdraw()提取BigBank资金
# Admin合约通过IBank接口调用BigBank的withdraw()方法
# 资金被转移到Admin合约地址

# 5. Admin Owner可以进一步将资金提取到个人地址
```

#### 架构关系图：

```
IBank (interface)
    ↑
Bank (implements IBank)  
    ↑
BigBank (inherits Bank + MIN_DEPOSIT = 0.001 ether)
    ↓ (transferOwnership)
Admin (owner + adminWithdraw(IBank bank))
```

#### 核心特性验证：

- ✅ Bank实现IBank接口
- ✅ BigBank继承Bank并添加最小存款限制
- ✅ BigBank支持管理权转移
- ✅ Admin有独立的Owner
- ✅ Admin通过IBank接口调用withdraw方法
- ✅ 完整的工作流程测试通过

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

### Bank合约 (IBank接口)

- `deposit()`: 存款函数
- `withdraw(uint256 amount)`: 管理员提取函数  
- `getBalance(address user)`: 查询用户余额
- `getTopDepositors()`: 获取前3名存款用户
- `getTotalDeposits()`: 获取总存款额
- `getContractBalance()`: 获取合约余额
- `transferOwnership(address newOwner)`: 转移所有权

### BigBank合约 (继承Bank)

- `MIN_DEPOSIT`: 最小存款常量(0.001 ether)
- `deposit()`: 存款函数(增强版，带最小金额限制)
- `getMinDeposit()`: 获取最小存款要求
- `meetsMinDeposit(uint256 amount)`: 检查金额是否满足最小存款要求
- `transferOwnership(address newOwner)`: 转移所有权(可转给Admin合约)

### Admin合约

- `adminWithdraw(IBank bank)`: 从指定Bank合约提取所有资金
- `adminWithdrawAmount(IBank bank, uint256 amount)`: 从Bank合约提取指定金额
- `withdrawToOwner(uint256 amount)`: 将Admin合约资金提取给Owner
- `withdrawAllToOwner()`: 提取Admin合约所有资金给Owner
- `transferOwnership(address newOwner)`: 转移Admin合约所有权
- `getAdminInfo()`: 获取Admin合约信息
- `getBankInfo(IBank bank)`: 获取指定Bank合约信息

### 事件

- `Deposit(address indexed user, uint256 amount, uint256 newBalance)`
- `Withdraw(address indexed admin, uint256 amount)`
- `TopDepositorsUpdated(address[3] topUsers, uint256[3] topAmounts)`
- `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`
- `AdminWithdrawal(address indexed bankContract, uint256 amount, address indexed owner)`
- `FundsReceived(address indexed from, uint256 amount)`

## 安全特性

1. **访问控制**: 
   - Bank/BigBank: 只有合约所有者可以提取资金
   - Admin: 只有Admin Owner可以操作
2. **重入保护**: 所有资金操作都使用nonReentrant修饰符
3. **输入验证**: 
   - 验证存款和提取金额
   - BigBank强制最小存款限制
   - 地址零值检查
4. **溢出保护**: Solidity 0.8+内置溢出保护
5. **接口隔离**: Admin通过IBank接口操作，降低耦合
6. **权限分离**: BigBank管理权可转移给Admin合约

## 测试覆盖

### Bank合约测试
- ✅ 基本存款和提取功能
- ✅ 排行榜更新逻辑
- ✅ 权限控制测试
- ✅ 边界条件测试
- ✅ 模糊测试
- ✅ Gas优化测试
- ✅ 安全性测试

### BigBank合约测试
- ✅ 继承Bank功能验证
- ✅ 最小存款限制测试
- ✅ modifier权限控制测试
- ✅ 管理权转移测试

### Admin合约测试
- ✅ adminWithdraw功能测试
- ✅ IBank接口调用测试
- ✅ 权限控制测试
- ✅ 资金转移测试

### 完整工作流程测试
- ✅ Bank实现IBank接口验证
- ✅ BigBank继承Bank验证
- ✅ 端到端工作流程测试
- ✅ 错误场景测试
- ✅ 架构关系验证

## Gas优化

合约已经过Gas优化：
- 高效的排行榜算法
- 最小化状态变量读写
- 优化的排序逻辑

## 开发指南

### 添加新功能

#### 扩展Bank功能
1. 在 `src/Bank.sol` 中实现新功能
2. 在 `src/interfaces/IBank.sol` 中添加接口(如需要)
3. 在 `test/Bank.t.sol` 中添加测试
4. 如果BigBank需要继承新功能，更新 `src/BigBank.sol`

#### 扩展BigBank功能
1. 在 `src/BigBank.sol` 中实现BigBank特有功能
2. 在 `test/NewWorkflow.t.sol` 中添加相关测试
3. 确保最小存款限制得到正确应用

#### 扩展Admin功能
1. 在 `src/Admin.sol` 中实现新的管理功能
2. 确保通过IBank接口进行Bank合约操作
3. 在 `test/NewWorkflow.t.sol` 中添加相关测试

### 测试策略

1. **单元测试**: 测试单个合约的功能
2. **集成测试**: 测试合约间的交互
3. **工作流程测试**: 测试完整的业务流程
4. **模糊测试**: 测试边界条件和异常情况

### 提交流程

1. 运行所有测试: `forge test`
2. 运行工作流程测试: `forge test --match-contract NewWorkflowTest -vv`
3. 检查代码覆盖率: `forge coverage`
4. 检查Gas使用: `forge test --gas-report`
5. 确保编译无警告: `forge build`
6. 提交代码

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

### 最新需求相关注意事项

1. **BigBank最小存款限制**: 所有存款必须≥0.001 ether，否则交易会失败
2. **管理权转移**: BigBank部署后应将管理权转移给Admin合约
3. **Admin操作**: Admin合约通过IBank接口操作，确保了合约间的松耦合
4. **测试环境**: 建议使用NewWorkflow测试验证完整工作流程
5. **合约升级**: 如需修改需求，建议重新部署而非尝试升级合约

### 部署顺序

推荐的部署顺序：
1. 部署Bank合约(可选，用于对比)
2. 部署BigBank合约  
3. 部署Admin合约
4. 将BigBank管理权转移给Admin合约
5. 测试完整工作流程