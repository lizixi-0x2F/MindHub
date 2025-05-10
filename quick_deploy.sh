#!/bin/bash

# MindHub快速部署脚本
# 使用ios-deploy工具快速部署应用到iOS设备或模拟器

echo "===== MindHub快速部署工具 ====="

# 显示可用设备
echo "正在检查可用设备..."
xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad"

# 让用户选择部署目标
echo ""
echo "请选择部署方式:"
echo "1) 部署到真机设备"
echo "2) 部署到模拟器"
read -p "请输入选项 (1/2): " DEPLOY_OPTION

if [ "$DEPLOY_OPTION" == "1" ]; then
    # 检查是否有真机设备连接
    DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep -v "Simulator" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\2/')
    
    if [ -z "$DEVICE_ID" ]; then
        echo "错误: 未找到已连接的真机iOS设备，请确保设备已连接并解锁"
        exit 1
    fi
    
    DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep -v "Simulator" | head -1 | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\1/')
    echo "检测到设备: $DEVICE_NAME ($DEVICE_ID)"
    
    # 检查是否安装了ios-deploy
    if ! command -v ios-deploy &> /dev/null; then
        echo "正在安装ios-deploy工具..."
        npm install -g ios-deploy || { 
            echo "安装ios-deploy失败，尝试使用brew安装..."
            brew install ios-deploy || {
                echo "错误: 无法安装ios-deploy，请手动安装后重试"
                echo "可使用命令: npm install -g ios-deploy 或 brew install ios-deploy"
                exit 1
            }
        }
    fi
    
    echo "正在构建MindHub应用..."
    xcodebuild -project MindHub.xcodeproj -scheme MindHub -configuration Debug -derivedDataPath ./build
    
    # 查找构建出的.app文件
    APP_PATH=$(find ./build -name "*.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "错误: 未找到构建的.app文件"
        exit 1
    fi
    
    echo "找到应用: $APP_PATH"
    echo "正在安装到设备..."
    
    # 使用ios-deploy安装应用
    ios-deploy --bundle "$APP_PATH" --debug
    
    if [ $? -eq 0 ]; then
        echo "===== 部署成功 ====="
        echo "MindHub应用已安装到您的设备"
    else
        echo "===== 部署失败 ====="
        echo "请检查设备连接和权限设置"
    fi
    
else
    # 获取可用模拟器列表
    SIMULATORS=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep "Simulator" | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\2/')
    SIMULATOR_NAMES=$(xcrun xctrace list devices 2>&1 | grep -E "^iPhone|^iPad" | grep "Simulator" | sed -E 's/(.+) \(([A-Za-z0-9-]+)\) \(.+\)/\1/')
    
    # 显示模拟器列表
    echo "可用模拟器列表:"
    IFS=$'\n'
    SIMULATOR_ARRAY=($SIMULATORS)
    SIMULATOR_NAMES_ARRAY=($SIMULATOR_NAMES)
    
    for i in "${!SIMULATOR_ARRAY[@]}"; do
        echo "$((i+1))) ${SIMULATOR_NAMES_ARRAY[$i]} (${SIMULATOR_ARRAY[$i]})"
    done
    
    # 让用户选择模拟器
    read -p "请选择模拟器 (1-${#SIMULATOR_ARRAY[@]}): " SIMULATOR_CHOICE
    
    if [ -z "$SIMULATOR_CHOICE" ] || [ $SIMULATOR_CHOICE -lt 1 ] || [ $SIMULATOR_CHOICE -gt ${#SIMULATOR_ARRAY[@]} ]; then
        echo "无效选择，使用第一个模拟器"
        SIMULATOR_CHOICE=1
    fi
    
    SELECTED_SIMULATOR=${SIMULATOR_ARRAY[$((SIMULATOR_CHOICE-1))]}
    SELECTED_SIMULATOR_NAME=${SIMULATOR_NAMES_ARRAY[$((SIMULATOR_CHOICE-1))]}
    
    echo "选择了模拟器: $SELECTED_SIMULATOR_NAME"
    
    # 构建应用
    echo "正在构建MindHub应用..."
    xcodebuild -project MindHub.xcodeproj -scheme MindHub -configuration Debug -derivedDataPath ./build -destination "id=$SELECTED_SIMULATOR"
    
    # 查找构建出的.app文件
    APP_PATH=$(find ./build -name "*.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "错误: 未找到构建的.app文件"
        exit 1
    fi
    
    echo "找到应用: $APP_PATH"
    
    # 启动模拟器并安装应用
    echo "正在启动模拟器并安装应用..."
    xcrun simctl boot "$SELECTED_SIMULATOR" 2>/dev/null
    xcrun simctl install "$SELECTED_SIMULATOR" "$APP_PATH"
    
    # 启动应用
    echo "正在启动应用..."
    xcrun simctl launch "$SELECTED_SIMULATOR" com.yourdomain.MindHub || { 
        BUNDLE_ID=$(defaults read "$APP_PATH/Info" CFBundleIdentifier 2>/dev/null)
        if [ ! -z "$BUNDLE_ID" ]; then
            xcrun simctl launch "$SELECTED_SIMULATOR" "$BUNDLE_ID" || echo "启动应用失败"
        else
            echo "启动应用失败，无法确定Bundle ID"
        fi
    }
    
    echo "===== 部署完成 ====="
    echo "MindHub应用已成功安装到模拟器"
fi 