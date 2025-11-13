# 🚀 PHUMA UV 快速参考

## 一键安装
```bash
# 克隆并设置
git clone https://github.com/DAVIAN-Robotics/PHUMA.git
cd PHUMA
pip install uv
./setup_uv.sh
source .venv/bin/activate
```

## 常用命令

### 环境管理
```bash
uv venv --python 3.9        # 创建虚拟环境
source .venv/bin/activate   # 激活 (Linux/Mac)
.venv\Scripts\activate      # 激活 (Windows)
deactivate                  # 退出
```

### 包管理
```bash
uv pip install package      # 安装包
uv pip install -e .         # 安装项目 (可编辑模式)
uv pip list                 # 列出已安装包
uv pip freeze               # 导出依赖
uv pip uninstall package    # 卸载包
```

### PHUMA 工作流
```bash
# 1. 运动筛选
python src/curation/preprocess_smplx.py \
    --project_dir $PWD \
    --human_pose_file "example/kick" \
    --visualize 1

# 2. 形状适配
python src/retarget/shape_adaptation.py \
    --project_dir $PWD \
    --robot_name g1

# 3. 运动适配
python src/retarget/motion_adaptation.py \
    --project_dir $PWD \
    --robot_name g1 \
    --human_pose_file "example/kick_chunk_0000" \
    --visualize 1
```

## 速度对比
- 安装依赖: **pip 120s → uv 10s** ⚡
- 依赖解析: **pip 15s → uv 1s** ⚡
- 虚拟环境: **conda 45s → uv 2s** ⚡

## 文档链接
- 详细指南: `UV_SETUP_GUIDE.md`
- 迁移总结: `UV_MIGRATION_SUMMARY.md`
- 项目主页: https://davian-robotics.github.io/PHUMA/

## 问题排查
```bash
# UV 未找到
python -m uv --version

# 清除缓存
uv cache clean

# 重新安装
uv pip install -e . --reinstall
```

---
💡 提示: UV 是 pip 的直接替代,所有 pip 命令都可用 `uv pip` 替换
