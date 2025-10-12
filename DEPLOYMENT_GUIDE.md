# Bank合约部署指南 - Sepolia测试网

## 📋 前置准备

### 1. 获取Sepolia测试网ETH

您需要一些Sepolia测试网ETH来支付Gas费用：

- **Sepolia Faucet**: https://sepoliafaucet.com/
- **Alchemy Sepolia Faucet**: https://sepoliafaucet.com/
- **Infura Sepolia Faucet**: https://www.infura.io/faucet/sepolia

### 2. 获取必要的API密钥

#### a. Alchemy RPC URL (推荐)
1. 访问 https://www.alchemy.com/
2. 注册/登录账户
3. 创建新的App，选择 Sepolia 网络
4. 复制 HTTPS URL（格式：`https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY`）

#### b. Etherscan API密钥（用于合约验证）
1. 访问 https://etherscan.io/
2. 注册/登录账户
3. 进入 API Keys 页面：https://etherscan.io/myapikey
4. 创建新的API密钥
5. 复制API密钥

### 3. 准备部署钱包

⚠️ **安全提醒**：
- 仅用于测试网，不要使用包含真实资金的钱包
- 永远不要将私钥提交到Git仓库
- 使用专门的测试钱包

获取您的私钥：
- **MetaMask**: 账户详情 -> 导出私钥
- **其他钱包**: 查看钱包的导出私钥选项

## 🔧 配置环境

### 步骤1: 创建.env文件

```bash
# 在项目根目录创建.env文件
cp env.example .env
```

### 步骤2: 编辑.env文件

打开 `.env` 文件并填入真实配置：

```bash
# Network RPC URLs
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY

# 私钥（去掉0x前缀或保留都可以）
PRIVATE_KEY=your_private_key_here

# Etherscan API密钥（用于合约验证）
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

### 步骤3: 验证配置

```bash
# 检查.env文件是否被git忽略
cat .gitignore | grep .env

# 应该看到 .env 在列表中
```

## 🚀 部署Bank合约

### 方法1: 使用Forge命令（推荐）

```bash
# 加载环境变量并部署
source .env
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

### 方法2: 使用Makefile

如果配置了Makefile：

```bash
make deploy-sepolia
```

### 方法3: 不进行验证的快速部署

如果暂时不需要验证合约：

```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  -vvvv
```

## 📝 部署后的步骤

### 1. 保存部署信息

部署成功后，您会看到类似输出：

```
## Setting up 1 EVM.
==========================
Chain 11155111

Estimated gas price: 2.000000007 gwei
Estimated total gas used for script: 1234567
Estimated amount required: 0.002469134008641969 ETH

==========================

##### sepolia
✅  [Success] Hash: 0x1234...abcd
Contract Address: 0xYourContractAddress
Block: 12345678
Paid: 0.002469134008641969 ETH (1234567 gas * 2.000000007 gwei)
```

**请保存以下信息**：
- 合约地址 (Contract Address)
- 交易哈希 (Hash)
- 部署区块 (Block)

### 2. 更新.env文件

将部署的合约地址添加到 `.env` 文件：

```bash
BANK_CONTRACT_ADDRESS=0xYourContractAddress
```

### 3. 在Etherscan上查看合约

访问: `https://sepolia.etherscan.io/address/YOUR_CONTRACT_ADDRESS`

## ✅ 验证合约（如果之前没有自动验证）

### 手动验证

```bash
forge verify-contract \
  YOUR_CONTRACT_ADDRESS \
  src/Bank.sol:Bank \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### 验证成功后

在Etherscan上您可以：
- 查看合约源代码
- 直接在网页上调用合约函数
- 查看所有交易历史

## 🧪 测试部署的合约

### 1. 检查合约owner

```bash
cast call $BANK_CONTRACT_ADDRESS "owner()" --rpc-url $SEPOLIA_RPC_URL
```

### 2. 进行测试存款

```bash
# 存入0.1 ETH
cast send $BANK_CONTRACT_ADDRESS "deposit()" \
  --value 0.1ether \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

### 3. 查询余额

```bash
# 查询您的存款余额
cast call $BANK_CONTRACT_ADDRESS "getBalance(address)(uint256)" YOUR_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL
```

### 4. 查询前3名存款用户

```bash
cast call $BANK_CONTRACT_ADDRESS "getTopDepositors()(address[3],uint256[3])" \
  --rpc-url $SEPOLIA_RPC_URL
```

## 📊 使用交互脚本

### 存款脚本

```bash
export BANK_CONTRACT_ADDRESS=0xYourContractAddress
export DEPOSIT_AMOUNT=1000000000000000000  # 1 ETH

forge script script/interactions/Deposit.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast
```

### 提取脚本（仅owner）

```bash
export WITHDRAW_AMOUNT=500000000000000000  # 0.5 ETH

forge script script/interactions/Withdraw.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast
```

## 🔍 故障排除

### 问题1: "insufficient funds for gas"

**解决方案**: 
- 确保您的钱包有足够的Sepolia ETH
- 从faucet获取更多测试ETH

### 问题2: "PRIVATE_KEY not found"

**解决方案**:
```bash
# 确保.env文件存在并包含PRIVATE_KEY
cat .env | grep PRIVATE_KEY

# 重新加载环境变量
source .env
```

### 问题3: "RPC URL not responding"

**解决方案**:
- 检查Alchemy API密钥是否正确
- 尝试使用其他RPC提供商（Infura, Ankr等）

### 问题4: 验证失败

**解决方案**:
```bash
# 等待几个区块后重试
sleep 30

# 重新运行验证命令
forge verify-contract \
  YOUR_CONTRACT_ADDRESS \
  src/Bank.sol:Bank \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch
```

## 📱 部署BigBank和Admin合约

如果您想部署完整的系统：

```bash
forge script script/DeployLatestRequirements.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

这将部署：
1. Bank合约
2. BigBank合约
3. Admin合约
4. 自动转移BigBank管理权给Admin合约

## 🎯 最佳实践

1. **测试优先**: 在部署前运行所有测试
   ```bash
   forge test
   ```

2. **Gas估算**: 在部署前估算Gas费用
   ```bash
   forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL
   ```

3. **备份信息**: 保存所有部署地址和交易哈希

4. **安全检查**: 
   - 确认部署账户地址
   - 检查合约owner是否正确
   - 验证初始状态

5. **文档记录**: 记录部署时间、网络、Gas费用等信息

## 🔗 有用的链接

- **Sepolia Etherscan**: https://sepolia.etherscan.io/
- **Sepolia Faucet**: https://sepoliafaucet.com/
- **Alchemy Dashboard**: https://dashboard.alchemy.com/
- **Foundry Book**: https://book.getfoundry.sh/
- **Chainlist (Sepolia RPC)**: https://chainlist.org/chain/11155111

## 💡 提示

- 部署到测试网是免费的（除了Gas费）
- 可以随时重新部署测试
- 建议先在本地测试网（Anvil）测试部署流程
- 部署后立即验证合约，方便后续交互

---

如有问题，请查看项目的README.md或提交Issue。

