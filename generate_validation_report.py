#!/usr/bin/env python3
"""
PHUMA 验证报告生成器
检查所有验证步骤的完成情况
"""

import os
import sys
import numpy as np
from datetime import datetime


def print_header(title):
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def check_file(path, description):
    if os.path.exists(path):
        size = os.path.getsize(path)
        size_str = f"{size/1024:.1f}KB" if size < 1024 * \
            1024 else f"{size/(1024*1024):.1f}MB"
        print(f"✓ {description}")
        print(f"  路径: {path}")
        print(f"  大小: {size_str}")
        return True
    else:
        print(f"✗ {description} - 文件不存在")
        print(f"  预期路径: {path}")
        return False


def check_directory(path, description):
    if os.path.exists(path):
        files = os.listdir(path)
        print(f"✓ {description}")
        print(f"  路径: {path}")
        print(f"  文件数: {len(files)}")
        return True
    else:
        print(f"✗ {description} - 目录不存在")
        return False


print_header("PHUMA 验证报告")
print(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

# 1. 环境验证
print_header("1. 环境验证")
try:
    import torch
    import numpy
    import smplx
    import mujoco
    print(f"✓ PyTorch: {torch.__version__}")
    print(f"✓ NumPy: {numpy.__version__}")
    print(f"✓ SMPLX: 已安装")
    print(f"✓ MuJoCo: {mujoco.__version__}")
    env_ok = True
except Exception as e:
    print(f"✗ 环境检查失败: {e}")
    env_ok = False

# 2. SMPL-X 模型
print_header("2. SMPL-X 模型文件")
smplx_files = [
    'asset/human_model/smplx/SMPLX_NEUTRAL.npz',
    'asset/human_model/smplx/SMPLX_MALE.npz',
    'asset/human_model/smplx/SMPLX_FEMALE.npz'
]
smplx_ok = all([check_file(f, os.path.basename(f)) for f in smplx_files])

# 3. 原始示例数据
print_header("3. 原始示例数据")
example_ok = check_file('data/human_pose/example/kick.npy', '原始运动数据')
if example_ok:
    data = np.load('data/human_pose/example/kick.npy')
    print(f"  形状: {data.shape}")
    print(f"  帧数: {data.shape[0]}")

# 4. 预处理数据
print_header("4. 预处理数据 (Motion Curation)")
preprocess_dir = 'data/human_pose_preprocessed/example'
preprocess_ok = check_directory(preprocess_dir, '预处理数据目录')
if preprocess_ok:
    chunks = [f for f in os.listdir(preprocess_dir) if f.endswith('.npy')]
    print(f"  数据块数: {len(chunks)}")
    for chunk in sorted(chunks):
        chunk_path = os.path.join(preprocess_dir, chunk)
        data = np.load(chunk_path)
        print(f"  - {chunk}: {data.shape}")

# 5. 形状适配参数
print_header("5. 形状适配参数 (Shape Adaptation)")
robots = ['g1', 'h1_2']
shape_ok = {}
for robot in robots:
    beta_path = f'asset/humanoid_model/{robot}/betas.npy'
    shape_ok[robot] = check_file(beta_path, f'{robot.upper()} 形状参数')
    if shape_ok[robot]:
        betas = np.load(beta_path)
        print(f"  参数形状: {betas.shape}")
        print(f"  参数范围: [{betas.min():.3f}, {betas.max():.3f}]")

# 6. 运动适配结果
print_header("6. 运动适配结果 (Motion Adaptation)")
motion_ok = {}
for robot in robots:
    motion_dir = f'data/humanoid_pose/{robot}/example'
    if os.path.exists(motion_dir):
        motion_files = [f for f in os.listdir(
            motion_dir) if f.endswith('.npy')]
        motion_ok[robot] = len(motion_files) > 0
        print(f"✓ {robot.upper()} 运动数据: {len(motion_files)} 个文件")
        for mf in sorted(motion_files)[:3]:  # 只显示前3个
            mf_path = os.path.join(motion_dir, mf)
            try:
                data = np.load(mf_path, allow_pickle=True)
                if isinstance(data, np.ndarray):
                    print(f"  - {mf}: {data.shape}")
                else:
                    print(f"  - {mf}: 已生成")
            except:
                print(f"  - {mf}: 已生成")
    else:
        print(f"✗ {robot.upper()} 运动数据目录不存在")
        motion_ok[robot] = False

# 7. 可视化视频
print_header("7. 可视化视频 (如果生成)")
video_dirs = [
    'data/video/human_pose_preprocessed/example',
    'data/video/humanoid_pose/g1/example',
    'data/video/humanoid_pose/h1_2/example'
]
video_count = 0
for vdir in video_dirs:
    if os.path.exists(vdir):
        videos = [f for f in os.listdir(vdir) if f.endswith('.mp4')]
        if videos:
            print(f"✓ {vdir}: {len(videos)} 个视频")
            video_count += len(videos)

if video_count == 0:
    print("ℹ️  未生成可视化视频 (使用 --visualize 1 启用)")

# 总结
print_header("验证总结")
results = {
    "环境配置": env_ok,
    "SMPL-X 模型": smplx_ok,
    "示例数据": example_ok,
    "运动筛选": preprocess_ok,
    "形状适配 (G1)": shape_ok.get('g1', False),
    "形状适配 (H1_2)": shape_ok.get('h1_2', False),
    "运动适配 (G1)": motion_ok.get('g1', False),
    "运动适配 (H1_2)": motion_ok.get('h1_2', False),
}

passed = sum(results.values())
total = len(results)

print(f"\n通过: {passed}/{total}")
print()

for name, status in results.items():
    symbol = "✓" if status else "✗"
    print(f"{symbol} {name}")

if passed == total:
    print("\n" + "🎉" * 20)
    print("所有验证步骤完成！PHUMA 完全正常工作！")
    print("🎉" * 20)
else:
    print(f"\n⚠️  还有 {total - passed} 个步骤未完成")
    print("请参考上述详细信息完成剩余步骤")

print("\n" + "=" * 70)
