#!/bin/bash

# Bank合约Sepolia部署脚本
# 使用方法: ./deploy-sepolia.sh

set -e

echo "🚀 Bank合约Sepolia部署脚本"
echo "================================"
echo ""

# 检查.env文件
if [ ! -f .env ]; then
    echo "❌ 错误: .env文件不存在"
    echo "请先创建.env文件并配置必要的环境变量"
    echo ""
    echo "运行以下命令创建.env文件:"
    echo "  cp env.example .env"
    echo ""
    exit 1
fi

# 加载环境变量
source .env

# 检查必要的环境变量
if [ -z "$SEPOLIA_RPC_URL" ] || [ "$SEPOLIA_RPC_URL" == "https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY" ]; then
    echo "❌ 错误: SEPOLIA_RPC_URL未正确配置"
    echo "请在.env文件中设置您的Alchemy API密钥"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ] || [ "$PRIVATE_KEY" == "your_private_key_here" ]; then
    echo "❌ 错误: PRIVATE_KEY未正确配置"
    echo "请在.env文件中设置您的私钥"
    exit 1
fi

echo "✅ 环境变量检查通过"
echo ""

# 显示部署信息
echo "📋 部署信息:"
echo "  网络: Sepolia Testnet"
echo "  RPC: ${SEPOLIA_RPC_URL:0:50}..."
echo "  部署者地址: $(cast wallet address $PRIVATE_KEY)"
echo ""

# 检查余额
echo "💰 检查账户余额..."
BALANCE=$(cast balance $(cast wallet address $PRIVATE_KEY) --rpc-url $SEPOLIA_RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)
echo "  余额: $BALANCE_ETH ETH"

if [ $(echo "$BALANCE_ETH < 0.01" | bc) -eq 1 ]; then
    echo "⚠️  警告: 余额较低，可能不足以支付Gas费用"
    echo "  建议从faucet获取更多Sepolia ETH: https://sepoliafaucet.com/"
    echo ""
fi

# 询问是否继续
read -p "是否继续部署? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 部署已取消"
    exit 0
fi

echo ""
echo "🔨 开始编译合约..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

echo "✅ 编译成功"
echo ""

# 运行测试
echo "🧪 运行测试..."
forge test --match-contract BankTest

if [ $? -ne 0 ]; then
    echo "⚠️  警告: 测试失败"
    read -p "是否继续部署? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 部署已取消"
        exit 0
    fi
else
    echo "✅ 测试通过"
fi

echo ""
echo "🚀 开始部署Bank合约到Sepolia..."
echo ""

# 部署合约
if [ -z "$ETHERSCAN_API_KEY" ] || [ "$ETHERSCAN_API_KEY" == "your_etherscan_api_key_here" ]; then
    echo "⚠️  未配置Etherscan API密钥，将跳过合约验证"
    echo ""
    forge script script/Deploy.s.sol:DeployScript \
        --rpc-url $SEPOLIA_RPC_URL \
        --broadcast \
        -vvvv
else
    echo "✅ 将自动验证合约"
    echo ""
    forge script script/Deploy.s.sol:DeployScript \
        --rpc-url $SEPOLIA_RPC_URL \
        --broadcast \
        --verify \
        -vvvv
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "🎉 部署成功！"
    echo "================================"
    echo ""
    echo "📝 后续步骤:"
    echo "1. 检查 deployment-sepolia.json 文件查看部署地址"
    echo "2. 将合约地址添加到 .env 文件的 BANK_CONTRACT_ADDRESS"
    echo "3. 在 Sepolia Etherscan 查看合约: https://sepolia.etherscan.io/"
    echo "4. 使用交互脚本测试合约功能"
    echo ""
    echo "📚 查看完整部署指南: DEPLOYMENT_GUIDE.md"
    echo ""
else
    echo ""
    echo "================================"
    echo "❌ 部署失败"
    echo "================================"
    echo ""
    echo "请检查错误信息并重试"
    echo "常见问题:"
    echo "  - 余额不足"
    echo "  - RPC URL无效"
    echo "  - 私钥格式错误"
    echo ""
    echo "查看详细故障排除: DEPLOYMENT_GUIDE.md"
    echo ""
    exit 1
fi

