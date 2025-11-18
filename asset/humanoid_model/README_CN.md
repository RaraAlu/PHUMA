# 自定义机器人集成指南

[English](README.md) | 简体中文

虽然我们目前支持 Unitree 人形机器人 (G1 和 H1-2)，但通过一些修改也可以集成自定义机器人。

## 必需文件

在此目录中创建一个新的机器人文件夹，包含以下内容:
- `meshes/` - 用于可视化的 STL 文件
- `config.yaml` - 机器人配置文件
- `custom.xml` - 带有脚后跟/脚趾关键点的 MuJoCo 机器人模型
- `scene.xml` (可选) - 可以从现有的 g1 或 h1_2 文件夹复制

## 主要挑战

### (1) 在 `custom.xml` 中添加脚后跟和脚趾关键点

PhySINK 需要脚后跟和脚趾关键点来进行准确的足部接触建模。这些关键点应该作为子体添加到机器人脚部的最低链接上。

**G1 中的参考实现:**
- [left_heel_keypoint](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/asset/humanoid_model/g1/custom.xml#L88-L90)
- [left_toe_keypoint](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/asset/humanoid_model/g1/custom.xml#L91-L93)
- [right_heel_keypoint](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/asset/humanoid_model/g1/custom.xml#L133-L135)
- [right_toe_keypoint](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/asset/humanoid_model/g1/custom.xml#L136-L138)

我们通过检查脚部网格的最低点来确定脚后跟和脚趾关键点的位置。脚后跟应该位于最后面/最低点，脚趾应该位于最前面/最低点。

![脚后跟和脚趾关键点可视化](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/docs/images/heel_toe_keypoints.png)

### (2) 创建 `config.yaml`

参考 [g1/config.yaml](https://github.com/DAVIAN-Robotics/PHUMA/blob/main/asset/humanoid_model/g1/config.yaml) 作为模板。大多数字段 (`root_pos`、`root_ori`、`dof_pos`、`body_names`、`joint_names`、`joint_limits`、`joint_velocity_limits`、`dof`) 都是从机器人 MJCF 文件中直接复制或重命名的实体。

**需要特别注意的两个关键字段:**

**`bone_mapping`**: 映射 SMPL-X 骨骼和机器人运动链之间的对应骨骼。每个条目是一个 4 元组: `[smpl_parent, smpl_child, robot_parent, robot_child]`

```yaml
bone_mapping:
  # 左腿
  - ['pelvis', 'left_hip', 'pelvis', 'left_hip_roll_link']
  - ['left_hip', 'left_knee', 'left_hip_roll_link', 'left_knee_link']
  - ['left_knee', 'left_ankle', 'left_knee_link', 'left_ankle_pitch_link']
  # 右腿、手臂...
```
这些骨骼对应关系用于在优化过程中计算骨骼长度和方向损失。

**`keypoints`**: 定义 SMPL-X 关键点与机器人身体框架之间的对应关系，用于位置匹配。

```yaml
keypoints:
  - { name: 'pelvis',                 body: 'pelvis' }
  - { name: 'left_hip_keypoint',      body: 'left_hip_roll_link' }
  - { name: 'left_knee_keypoint',     body: 'left_knee_link' }
  - { name: 'left_ankle_keypoint',    body: 'left_ankle_pitch_link' }
  - { name: 'left_heel_keypoint',     body: 'left_heel_keypoint' }
  - { name: 'left_toe_keypoint',      body: 'left_toe_keypoint' }
  # 右腿、躯干、手臂...
```
算法会最小化对应的 SMPL-X 关节点与这些机器人关键点之间的距离。

### (3) 更新重定向脚本并调优

在 `src/retarget/shape_adaptation.py` 和 `src/retarget/motion_adaptation.py` 的 argparse 选项中添加你的自定义 robot_name。

然后运行形状适配 (一次性执行):
```bash
python src/retarget/shape_adaptation.py \
    --project_dir $PROJECT_DIR \
    --robot_name your_robot_name
```

接着运行运动适配并启用可视化:
```bash
python src/retarget/motion_adaptation.py \
    --project_dir $PROJECT_DIR \
    --robot_name your_robot_name \
    --human_pose_file example/kick_chunk_0000 \
    --visualize 1
```

如果需要，可以结合可视化对你的特定机器人进行迭代式损失权重调优。

## 注意事项

- 确保 `custom.xml` 中的关键点位置准确，这对重定向质量至关重要
- `bone_mapping` 和 `keypoints` 的配置需要仔细检查，确保对应关系正确
- 建议先使用简单的示例运动(如 `kick`)进行测试，验证配置是否正确
- 可视化输出可以帮助你快速发现配置问题并进行调整

## 支持

如果在集成自定义机器人时遇到问题，请参考现有的 G1 和 H1-2 配置作为参考，或在项目仓库中提出 issue。
