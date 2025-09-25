# Bank合约部署指南

## 快速开始

### 1. 项目验证

```bash
# 编译合约
forge build

# 运行测试
forge test

# 查看测试覆盖率
forge coverage
```

### 2. 本地部署测试

#### 启动本地测试网络

```bash
# 在终端1中启动Anvil
anvil
```

这将启动一个本地的以太坊测试网络，默认端口8545，并提供10个测试账户。

#### 部署合约

```bash
# 在终端2中部署合约 (使用Anvil默认账户)
forge script script/Deploy.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### 3. 合约交互测试

#### 设置环境变量

```bash
# 创建.env文件
cp env.example .env

# 编辑.env文件，设置合约地址
export BANK_CONTRACT_ADDRESS=<部署后的合约地址>
export DEPOSIT_AMOUNT=1000000000000000000  # 1 ETH
export WITHDRAW_AMOUNT=500000000000000000   # 0.5 ETH
```

#### 测试存款

```bash
# 用户存款
forge script script/interactions/Deposit.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

#### 测试管理员提取

```bash
# 管理员提取
forge script script/interactions/Withdraw.s.sol \
  --rpc-url http://localhost:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

## 测试网部署

### Sepolia测试网部署

1. **准备工作**
   ```bash
   # 获取Sepolia测试ETH
   # 访问: https://sepoliafaucet.com/
   
   # 设置环境变量
   export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/your-api-key"
   export PRIVATE_KEY="your-private-key"
   export ETHERSCAN_API_KEY="your-etherscan-api-key"
   ```

2. **部署命令**
   ```bash
   forge script script/Deploy.s.sol \
     --rpc-url $SEPOLIA_RPC_URL \
     --broadcast \
     --verify \
     --private-key $PRIVATE_KEY
   ```

3. **验证部署**
   ```bash
   # 如果自动验证失败，可以手动验证
   forge verify-contract <CONTRACT_ADDRESS> \
     src/Bank.sol:Bank \
     --etherscan-api-key $ETHERSCAN_API_KEY \
     --chain sepolia
   ```

## 使用Makefile简化操作

项目包含了Makefile来简化常见操作：

```bash
# 查看所有可用命令
make help

# 完整开发流程
make dev

# 启动本地演示
make demo-local

# 部署到本地
make deploy-local

# 运行测试
make test
```

## 合约功能验证

### 基础功能测试

1. **存款测试**
   - 直接转账到合约地址
   - 调用deposit()函数
   - 验证余额更新

2. **排行榜测试**
   - 多用户存款
   - 检查前3名排序
   - 验证排名更新

3. **管理员功能测试**
   - 测试withdraw()权限
   - 验证非管理员无法提取
   - 测试所有权转移

### 前端集成测试

如果要与前端集成，合约提供以下接口：

```javascript
// 存款
await bank.deposit({ value: ethers.utils.parseEther("1.0") });

// 查询余额
const balance = await bank.getBalance(userAddress);

// 获取前3名
const [addresses, amounts] = await bank.getTopDepositors();

// 管理员提取
await bank.withdraw(ethers.utils.parseEther("0.5"));
```

## 安全注意事项

1. **私钥管理**
   - 永远不要在代码中硬编码私钥
   - 使用环境变量或安全的密钥管理系统
   - 测试网使用专用测试账户

2. **合约安全**
   - 已实现重入攻击防护
   - 包含访问控制机制
   - 进行了充分的单元测试

3. **Gas优化**
   - 排行榜更新算法已优化
   - 建议在gas价格低时进行大额存款

## 故障排除

### 常见问题

1. **编译错误**
   ```bash
   # 清理并重新编译
   forge clean
   forge build
   ```

2. **测试失败**
   ```bash
   # 查看详细错误信息
   forge test -vvv
   ```

3. **部署失败**
   - 检查网络连接
   - 确认账户余额充足
   - 验证RPC URL正确

4. **Gas不足**
   - 增加gas limit
   - 检查网络拥堵情况

### 获取帮助

- 查看Foundry文档: https://book.getfoundry.sh/
- 检查项目README.md
- 查看测试用例了解使用方法

## 下一步

1. **集成前端界面**
2. **添加更多功能** (如利息计算)
3. **实现治理机制**
4. **考虑升级模式**
5. **进行安全审计**
