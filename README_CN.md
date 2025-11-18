# PHUMA: 基于物理的人形机器人运动数据集

[![arXiv](https://img.shields.io/badge/arXiv-2510.26236-b31b1b.svg)](https://arxiv.org/abs/2510.26236)
[![项目主页](https://img.shields.io/badge/Project_Page-Visit-blue.svg)](https://davian-robotics.github.io/PHUMA/)
[![Hugging Face](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-Dataset-yellow)](https://huggingface.co/datasets/DAVIAN-Robotics/PHUMA)

[English](README.md) | 简体中文

> [Kyungmin Lee\*](https://kyungminn.github.io/), [Sibeen Kim\*](https://sibisibi.github.io/), [Minho Park](https://pmh9960.github.io/), [Hyunseung Kim](https://mynsng.github.io/), [Dongyoon Hwang](https://godnpeter.github.io/), [Hojoon Lee](https://joonleesky.github.io/), and [Jaegul Choo](https://sites.google.com/site/jaegulchoo/)
> 
> **DAVIAN Robotics, KAIST AI**  
> arXiv 2025. (\* 表示同等贡献)

PHUMA 利用大规模人类运动数据，通过精心的数据筛选和物理约束的重定向技术，克服了物理伪影问题，创建了高质量的人形机器人运动数据集。

## 🚀 快速开始

### 环境要求
- Python 3.9 或 3.10
- CUDA 12.4 (推荐)
- `uv` 包管理器

### 安装步骤

#### 方式 1: 使用 uv (推荐 - 快速且现代)

1. **克隆仓库:**
   ```bash
   git clone https://github.com/DAVIAN-Robotics/PHUMA.git
   cd PHUMA
   ```

2. **安装 uv (如果尚未安装):**
   
   **推荐方式: 官方安装脚本 (独立安装，不依赖 Python):**
   ```bash
   # Linux/macOS
   curl -LsSf https://astral.sh/uv/install.sh | sh
   
   # Windows PowerShell
   powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```
   
   **备选方式: 通过 pip 安装:**
   ```bash
   pip install uv
   ```

3. **创建虚拟环境并安装依赖:**
   ```bash
   # 使用 Python 3.9 创建虚拟环境
   uv venv --python 3.9
   
   # 激活虚拟环境
   source .venv/bin/activate  # Linux/Mac
   # Windows 系统: .venv\Scripts\activate
   
   # 安装所有依赖 (uv 比 pip 快得多!)
   uv pip install -e .
   ```

#### 方式 2: 使用 conda + pip (传统方式)

1. **克隆仓库:**
   ```bash
   git clone https://github.com/DAVIAN-Robotics/PHUMA.git
   cd PHUMA
   ```

2. **配置环境:**
   ```bash
   conda create -n phuma python=3.9 -y
   conda activate phuma
   ```

3. **安装依赖 (通过 pyproject.toml 管理):**
   ```bash
   pip install -e .
   # 或使用非可编辑模式:
   # pip install .
   ```

### 前置准备工作

#### **下载 SMPL-X 模型** (必需!)

在运行数据处理流程之前，你需要下载 SMPL-X 模型文件:

1. 访问 [SMPL-X 官方网站](https://smpl-x.is.tue.mpg.de/)
2. 注册并下载以下文件:
   - `SMPLX_FEMALE.npz` 和 `SMPLX_FEMALE.pkl`
   - `SMPLX_MALE.npz` 和 `SMPLX_MALE.pkl`  
   - `SMPLX_NEUTRAL.npz` 和 `SMPLX_NEUTRAL.pkl`
3. 将所有下载的文件放置在 `asset/human_model/smplx/` 目录下

**验证安装:**
```bash
ls -la asset/human_model/smplx/
```

## 📊 数据处理流程

### 1. 基于物理的运动筛选

我们的物理感知筛选流程从人类运动数据中过滤出有问题的动作，以确保物理合理性。

#### **1-1) 起始数据:** 

我们从论文中描述的 Humanoid-X 集合开始。更多细节请参考 [Humanoid-X 仓库](https://github.com/sihengz02/UH-1)。如果你想复现 PHUMA 数据集，一个实用的起点是 [Motion-X](https://github.com/IDEA-Research/Motion-X)，它提供了关于 SMPL-X 姿态数据收集的优秀文档。

<details>
<summary><strong>ⅰ) 预处理 SMPL-X 数据格式</strong></summary>

Motion-X 生成的 SMPL-X 数据格式为 (N, 322)，但 PHUMA 需要 (N, 69) 格式，仅关注身体姿态，排除面部、手部等。如果你正在处理 Motion-X 数据，可以使用我们的预处理脚本进行转换:

此脚本将:
- 递归查找输入文件夹中的所有 `.npy` 文件
- 通过提取 `[transl, global_orient, body_pose]` 将 Motion-X 格式 (N, 322) 转换为 PHUMA 格式 (N, 69)
- 在输出文件夹中保留目录结构 (例如 `aist/subset_0008/`)

</details>

```bash
python src/curation/preprocess_motionx_format.py \
    --human_pose_folder /path_to_motionx_folder/subfolder \ # motionx_folder_path/humanml
    --output_dir data/human_pose
```

#### **1-2) 调整筛选阈值:**

默认阈值经过调整，可以保留具有腾空阶段的动作(例如跳跃)，同时过滤掉物理上不合理的动作。这意味着 PHUMA 中的某些动作可能包含轻微的穿透或悬浮伪影。如果你需要针对特定运动类型(例如仅步行)进行更严格的过滤，可以调整阈值:

<details>
<summary>单文件版本</summary>

- **处理单个文件:**
```bash
# 设置项目目录
PROJECT_DIR="[替换为你的工作目录]/PHUMA"
cd $PROJECT_DIR

# 我们提供了示例数据: data/human_pose/example/kick.npy
human_pose_file="example/kick"

python src/curation/preprocess_smplx.py \
    --project_dir $PROJECT_DIR \
    --human_pose_file $human_pose_file \
    --foot_contact_threshold 0.8 \  # 默认: 0.6. 增加此值可过滤更多悬浮/穿透
    --visualize 0
```

- **处理文件夹:**

</details>

```bash
# 设置项目目录
PROJECT_DIR="[替换为你的工作目录]/PHUMA"
cd $PROJECT_DIR

human_pose_folder='data/human_pose/example'

python src/curation/preprocess_smplx_folder.py \
    --project_dir $PROJECT_DIR \
    --human_pose_folder $human_pose_folder \
    --foot_contact_threshold 0.8 \  # 默认: 0.6. 增加此值可过滤更多悬浮/穿透
    --visualize 0
```

<details>
<summary>输出详情</summary>

- 预处理后的运动片段: `example/kick_chunk_0000.npy` 和 `example/kick_chunk_0001.npy` 保存在 `data/human_pose_preprocessed/` 目录下
- 如果设置 `--visualize 1`，还会保存 `example/kick_chunk_0000.mp4` 和 `example/kick_chunk_0001.mp4` 到 `data/video/human_pose_preprocessed/` 目录

所有可调参数列表，请查看 `src/curation/preprocess_smplx.py`。
</details>

### 2. 物理约束的运动重定向

为了解决重定向过程中引入的伪影，我们使用 **PhySINK**，这是我们的物理约束重定向方法，它将筛选后的人类运动适配到人形机器人，同时强制执行物理合理性。

#### **2-1) 形状适配 (一次性设置):**
```bash
# 找到最适合给定人形机器人的 SMPL-X 形状
# 此过程只需执行一次，可用于所有运动文件
python src/retarget/shape_adaptation.py \
    --project_dir $PROJECT_DIR \
    --robot_name g1
```

**输出:** 形状参数保存到 `asset/humanoid_model/g1/betas.npy`

#### **2-2) 运动适配:**

此步骤使用 PhySINK 优化将人类运动重定向到机器人运动。你可以处理单个文件或整个文件夹。

<details>
<summary>单文件版本</summary>

- **处理单个文件:**

```bash
# 使用前一步骤筛选的数据，针对 Unitree G1 人形机器人

human_pose_preprocessed_file="example/kick_chunk_0000"

python src/retarget/motion_adaptation.py \
    --project_dir $PROJECT_DIR \
    --robot_name g1 \
    --human_pose_file $human_pose_preprocessed_file
```

- **处理文件夹 (支持多进程):**

</details>

```bash
human_pose_preprocessed_folder="data/human_pose_preprocessed/example"

python src/retarget/motion_adaptation_multiprocess.py \
    --project_dir $PROJECT_DIR \
    --robot_name g1 \
    --human_pose_folder $human_pose_preprocessed_folder \
    --gpu_ids 0,1,2,3 \
    --processes_per_gpu 2
```

<details>
<summary>详细说明</summary>

**多进程参数:**
- `--gpu_ids`: 逗号分隔的 GPU ID (例如 `0,1,2,3`)。如果未指定，使用 `--device` (默认: `cuda:0`)。
- `--processes_per_gpu`: 每个 GPU 的并行进程数 (默认: 1)。
  - **推荐值**: RTX 3090 (24GB) 使用 1-2，A100 (40GB+) 使用 2-4
  - 总工作进程数 = `len(gpu_ids) × processes_per_gpu`
  - 示例: `--gpu_ids 0,1,2,3 --processes_per_gpu 2` → 总共 8 个工作进程
- `--num_workers`: 手动覆盖总工作进程数 (默认: 从 GPU 设置自动计算)
  - 使用 `-1` 以使用所有可用 CPU 核心 (仅 CPU 处理)

**其他选项:**
- `--visualize`: 设置为 `1` 生成可视化视频 (默认: `0`)
- `--fps`: 输出视频帧率 (默认: `30`)
- `--num_iter_dof`: 优化迭代次数 (默认: `3001`)
- `--lr_dof`: DOF 优化学习率 (默认: `0.005`)
- 查看所有可用选项: `python src/retarget/motion_adaptation_multiprocess.py --help`

**输出:** 
- 重定向后的人形机器人运动数据: `data/humanoid_pose/g1/kick_chunk_0000.npy`
  - 格式: 包含 `root_trans`、`root_ori`、`dof_pos` 和 `fps` 的字典
- 如果设置 `--visualize 1`，还会保存 `data/video/humanoid_pose/g1/kick_chunk_0000.mp4`

</details>

#### **✩ 自定义机器人支持:** 

我们支持 Unitree G1 和 H1-2，但你也可以将运动重定向到自定义人形机器人。详见我们的[自定义机器人集成指南](asset/humanoid_model/README.md)。

## 🎯 运动跟踪与评估

要复现我们报告的定量结果，请使用 `data/split/` 中提供的数据划分:
- `phuma_train.txt`
- `phuma_test.txt` 
- `unseen_video.txt`

LAFAN1 重定向数据: 可在[此处](https://huggingface.co/datasets/lvhaidong/LAFAN1_Retargeting_Dataset)获取。

LocoMuJoCo 重定向数据: 可在[此处](https://github.com/robfiras/loco-mujoco)获取。

对于运动跟踪和路径跟随任务，我们使用 [MaskedMimic](https://github.com/NVlabs/ProtoMotions) 的代码库。

## ❓ 常见问题 

<details>
<summary>FAQ 列表</summary>

**Q: 你们计划发布原始或预处理的人类姿态文件吗?**

A: 遗憾的是，由于许可证问题，我们无法发布 PHUMA Train/Test (`phuma_train.txt` 和 `phuma_test.txt`) 的人类姿态文件。但是，我们将很快发布 PHUMA Video (`unseen_video.txt`) 的 SMPL 人类姿态文件！我们还没有发布它们，因为当前代码库仅支持 SMPL-X。我们将很快更新 SMPL 处理代码并同时发布数据。

**Q: 我想用你们的代码处理自定义 SMPL-X 文件，但方向处理似乎有所不同。**

A: 对于 SMPL-X 处理，我们主要遵循 [Motion-X](https://github.com/IDEA-Research/Motion-X) 的代码。以 AMASS 为例，我们遵循[此代码](https://github.com/IDEA-Research/Motion-X/tree/main/mocap-dataset-process)(除了面部运动增强，因为我们专注于运动)。

**Q: PHUMA 中的某些动作似乎有轻微的穿透或悬浮。我做错了什么吗?**

A: 筛选阶段的默认阈值经过调整，可以保留具有腾空阶段的动作(例如跳跃)，同时过滤掉物理上不合理的动作。这种权衡意味着某些动作可能包含轻微的伪影。如果你需要针对特定运动类型(例如仅步行)进行更严格的过滤，可以调整筛选阈值，例如 `--foot_contact_threshold`。详见**调整筛选阈值**部分。

**Q: 我可以使用 PHUMA 流程将动作重定向到自定义人形机器人吗?**

A: 可以！虽然 PHUMA 数据集是为 Unitree G1 和 H1-2 提供的，但你可以通过遵循我们的[自定义机器人集成指南](asset/humanoid_model/README.md)，将 PhySINK 重定向流程用于自定义机器人。该指南涵盖了添加脚后跟/脚趾关键点、创建配置文件以及为你的机器人调整重定向过程。

</details>

## 📝 引用

如果你在研究中使用此数据集或代码，请引用我们的论文:

```bibtex
@article{lee2025phuma,
  title={PHUMA: Physically-Grounded Humanoid Locomotion Dataset},
  author={Kyungmin Lee and Sibeen Kim and Minho Park and Hyunseung Kim and Dongyoon Hwang and Hojoon Lee and Jaegul Choo},
  journal={arXiv preprint arXiv:2510.26236},
  year={2025},
}
```

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

本项目基于以下优秀的开源项目:
- [SMPL-X](https://smpl-x.is.tue.mpg.de/)
- [Motion-X](https://github.com/IDEA-Research/Motion-X)
- [MuJoCo](https://mujoco.org/)
- [PyTorch](https://pytorch.org/)
