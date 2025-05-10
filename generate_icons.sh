#!/bin/bash

# 定义图标基本颜色（RGB值）
R=90
G=150
B=250

# 定义图标输出目录
OUTPUT_DIR="MindHub/Assets.xcassets/AppIcon.appiconset"

# 确保输出目录存在
mkdir -p "$OUTPUT_DIR"

# 生成各种尺寸的图标

# 生成1024x1024基础图标
generate_base_icon() {
    echo "正在生成基础图标..."
    convert -size 1024x1024 xc:none -fill "rgb($R,$G,$B)" -draw "roundrectangle 0,0,1024,1024,200,200" "$OUTPUT_DIR/AppIcon-1024.png"
    
    # 在图标上添加文字
    convert "$OUTPUT_DIR/AppIcon-1024.png" -pointsize 400 -font "Arial-Bold" -gravity center -fill white -annotate +0+0 "M" "$OUTPUT_DIR/AppIcon-1024.png"
}

# 根据基础图标生成其他尺寸
generate_other_sizes() {
    echo "正在生成其他尺寸的图标..."
    
    # iPhone图标
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 40x40 "$OUTPUT_DIR/AppIcon-20@2x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 60x60 "$OUTPUT_DIR/AppIcon-20@3x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 58x58 "$OUTPUT_DIR/AppIcon-29@2x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 87x87 "$OUTPUT_DIR/AppIcon-29@3x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 80x80 "$OUTPUT_DIR/AppIcon-40@2x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 120x120 "$OUTPUT_DIR/AppIcon-40@3x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 120x120 "$OUTPUT_DIR/AppIcon-60@2x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 180x180 "$OUTPUT_DIR/AppIcon-60@3x.png"
    
    # iPad图标
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 20x20 "$OUTPUT_DIR/AppIcon-20.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 29x29 "$OUTPUT_DIR/AppIcon-29.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 40x40 "$OUTPUT_DIR/AppIcon-40.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 76x76 "$OUTPUT_DIR/AppIcon-76.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 152x152 "$OUTPUT_DIR/AppIcon-76@2x.png"
    convert "$OUTPUT_DIR/AppIcon-1024.png" -resize 167x167 "$OUTPUT_DIR/AppIcon-83.5@2x.png"
}

# 执行图标生成
if command -v convert >/dev/null 2>&1; then
    generate_base_icon
    generate_other_sizes
    echo "✅ 图标生成完成"
    echo "图标存储在 $OUTPUT_DIR 目录"
else
    echo "❌ 错误: 未找到ImageMagick命令'convert'"
    echo "请安装ImageMagick: brew install imagemagick"
    exit 1
fi 