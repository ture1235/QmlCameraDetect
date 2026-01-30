# QmlCameraDetect
A QML-based camera app with a QML frontend and Python backend for YOLO model inference.
# FrameHandler 连接管理使用指南

## 性能优化设计

默认情况下,**FrameHandler 不会连接到视频流**,避免不必要的帧传输开销。

## 使用方式

### 1. 启用帧处理 (连接)

```python
# 在需要处理视频帧时启用
frame_handler.connect_to_source(video_sink)
```

### 2. 禁用帧处理 (断开连接)

```python
# 不需要处理帧时断开,节省性能
frame_handler.disconnect_from_source()
```

### 3. 切换连接状态

```python
# 在启用/禁用之间切换
frame_handler.toggle_connection()
```

### 4. 检查连接状态

```python
if frame_handler.is_connected:
    print("帧处理已启用")
else:
    print("帧处理已禁用")
```

## 在 main.py 中的使用示例

### 方案 A: 默认不启用 (推荐,性能最优)

```python
# main.py 中已经准备好 video_sink,但没有连接
# 需要时手动启用:
frame_handler.connect_to_source(video_sink)
```

### 方案 B: 立即启用

如果需要程序启动就处理帧,在 main.py 中取消注释:

```python
# 如果需要立即启用,取消下面这行的注释:
frame_handler.connect_to_source(video_sink)
```

## 从 QML 中控制 (高级)

可以在 QML 中添加按钮来切换:

```qml
Button {
    text: "Toggle Frame Processing"
    onClicked: frameHandler.toggle_connection()
}
```

## 性能对比

| 模式 | CPU 占用 | 适用场景 |
|------|---------|---------|
| 未连接 | 极低 | 不需要检测/处理时 |
| 已连接 | 中等 | 需要实时检测时 |

## 典型使用场景

### 场景1: 按需启用检测

```python
# 用户点击"开始检测"按钮
def start_detection():
    frame_handler.connect_to_source(video_sink)
    print("开始检测...")

# 用户点击"停止检测"按钮  
def stop_detection():
    frame_handler.disconnect_from_source()
    print("停止检测")
```

### 场景2: 录像时才启用

```python
# 开始录像时启用
on_record_start:
    frame_handler.connect_to_source(video_sink)

# 停止录像时禁用
on_record_stop:
    frame_handler.disconnect_from_source()
```

## 注意事项

1. ✅ 断开连接不会影响摄像头显示
2. ✅ 可以随时重新连接
3. ⚠️ 连接状态下会持续接收所有帧
4. 💡 建议只在需要时才连接
